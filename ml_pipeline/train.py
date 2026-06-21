import os
os.environ["TF_USE_LEGACY_KERAS"] = "1" # Obbligatorio per TF 2.16+ e Transformers
os.environ["PYTORCH_CUDA_ALLOC_CONF"] = "max_split_size_mb:32"

import json
import numpy as np
import torch
from torch.utils.data import Dataset, DataLoader
from transformers import AutoTokenizer, AutoModelForTokenClassification
from transformers import TFAutoModelForTokenClassification
import tensorflow as tf
import argparse

# Mappa etichette (BIO)
tags_to_ids = {"O": 0, "B-PROD": 1, "I-PROD": 2, "B-QTY": 3}
ids_to_tags = {v: k for k, v in tags_to_ids.items()}
NUM_LABELS = len(tags_to_ids)

class ReceiptDataset(Dataset):
    def __init__(self, data, tokenizer, max_len=32):
        self.data = data
        self.tokenizer = tokenizer
        self.max_len = max_len
        
    def __len__(self):
        return len(self.data)
        
    def __getitem__(self, idx):
        item = self.data[idx]
        tokens = item["tokens"]
        ner_tags = item["ner_tags"]
        
        tokenized_inputs = self.tokenizer(
            tokens, is_split_into_words=True, 
            padding='max_length', truncation=True, max_length=self.max_len,
            return_tensors="pt"
        )
        
        word_ids = tokenized_inputs.word_ids()
        label_ids = []
        previous_word_idx = None
        
        for word_idx in word_ids:
            if word_idx is None:
                label_ids.append(-100) # Ignora nel calcolo della loss PyTorch
            elif word_idx != previous_word_idx:
                label_ids.append(tags_to_ids[ner_tags[word_idx]])
            else:
                tag = ner_tags[word_idx]
                if tag == "B-PROD": tag = "I-PROD"
                label_ids.append(tags_to_ids[tag])
            previous_word_idx = word_idx
            
        input_ids = tokenized_inputs["input_ids"].squeeze(0)
        attention_mask = tokenized_inputs["attention_mask"].squeeze(0)
        labels = torch.tensor(label_ids, dtype=torch.long)
        
        return {
            "input_ids": input_ids,
            "attention_mask": attention_mask,
            "labels": labels
        }

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--epochs", type=int, default=2)
    args = parser.parse_args()

    model_checkpoint = "distilbert-base-multilingual-cased"
    print(f"Caricamento Tokenizer da {model_checkpoint}...")
    tokenizer = AutoTokenizer.from_pretrained(model_checkpoint)
    
    print("Caricamento Dataset 'receipt_dataset.json'...")
    with open("receipt_dataset.json", "r", encoding="utf-8") as f:
        data = json.load(f)
        
    # Split 90/10
    np.random.shuffle(data)
    split_idx = int(len(data) * 0.9)
    train_data = data[:split_idx]
    val_data = data[split_idx:]
    
    train_dataset = ReceiptDataset(train_data, tokenizer)
    train_loader = DataLoader(train_dataset, batch_size=16, shuffle=True)
    
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"\n--- INIZIO TRAINING SU: {torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'CPU (No GPU)'} ---\n")
    if torch.cuda.is_available():
        torch.cuda.empty_cache()
    
    model = AutoModelForTokenClassification.from_pretrained(
        model_checkpoint, num_labels=NUM_LABELS
    ).to(device)
    
    optimizer = torch.optim.AdamW(model.parameters(), lr=2e-5)
    
    model.train()
    for epoch in range(5):
        print(f"Epoca {epoch+1}/5")
        total_loss = 0
        optimizer.zero_grad()
        
        for batch_idx, batch in enumerate(train_loader):
            input_ids = batch["input_ids"].to(device)
            attention_mask = batch["attention_mask"].to(device)
            labels = batch["labels"].to(device)
            
            outputs = model(input_ids=input_ids, attention_mask=attention_mask, labels=labels)
            loss = outputs.loss
            
            loss.backward()
            optimizer.step()
            optimizer.zero_grad()
            
            total_loss += loss.item()
            if batch_idx % 200 == 0:
                print(f" Batch {batch_idx}/{len(train_loader)} - Loss: {loss.item():.4f}")
                
        print(f"Fine Epoca {epoch+1} - Loss media: {total_loss/len(train_loader):.4f}\n")
        
    print("Salvataggio dei pesi PyTorch in locale...")
    model.save_pretrained("./pytorch_model")
    tokenizer.save_pretrained("./pytorch_model")
    
    print("\n--- INIZIO FASE DI ESPORTAZIONE IN TFLITE ---\n")
    print("1. Caricamento pesi PyTorch dentro TensorFlow (Ponte TF)...")
    # L'opzione from_pt=True è la magia che carica i tensori PyTorch nel grafo Keras
    tf_model = TFAutoModelForTokenClassification.from_pretrained("./pytorch_model", from_pt=True)
    
    print("2. Creazione della funzione di serving per TFLite...")
    @tf.function(input_signature=[
      tf.TensorSpec(shape=[1, 32], dtype=tf.int32, name="input_ids"),
      tf.TensorSpec(shape=[1, 32], dtype=tf.int32, name="attention_mask")
    ])
    def serving_fn(input_ids, attention_mask):
        return tf_model(input_ids=input_ids, attention_mask=attention_mask)

    print("3. Compressione e Quantizzazione TFLite (INT8)...")
    converter = tf.lite.TFLiteConverter.from_concrete_functions(
        [serving_fn.get_concrete_function()], tf_model
    )
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS, tf.lite.OpsSet.SELECT_TF_OPS]
    
    tflite_model = converter.convert()
    
    os.makedirs("models", exist_ok=True)
    tflite_path = os.path.join("models", "receipt_ner_distilbert.tflite")
    with open(tflite_path, "wb") as f:
        f.write(tflite_model)
        
    print(f"\n[SUCCESSO] Il tuo modello IBRIDO è pronto per il telefono: {tflite_path}")

if __name__ == "__main__":
    main()
