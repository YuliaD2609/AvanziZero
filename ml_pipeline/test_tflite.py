import os
os.environ["TF_USE_LEGACY_KERAS"] = "1"
import json
import numpy as np
import tensorflow as tf
from transformers import AutoTokenizer

# Mappa etichette
tags_to_ids = {"O": 0, "B-PROD": 1, "I-PROD": 2, "B-QTY": 3}
ids_to_tags = {v: k for k, v in tags_to_ids.items()}

# Carica tokenizer e modello TFLite
print("Caricamento tokenizer...")
tokenizer = AutoTokenizer.from_pretrained("./pytorch_model")

print("Caricamento modello TFLite...")
interpreter = tf.lite.Interpreter(model_path="models/receipt_ner_distilbert.tflite")
interpreter.allocate_tensors()

input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

def predict(text):
    tokens = text.split()
    tokenized = tokenizer(
        tokens, is_split_into_words=True, 
        padding='max_length', truncation=True, max_length=32,
        return_tensors="tf"
    )
    
    input_ids = tf.cast(tokenized["input_ids"], tf.int32)
    attention_mask = tf.cast(tokenized["attention_mask"], tf.int32)
    
    # In TFLite, gli input devono corrispondere all'indice esatto
    for detail in input_details:
        if "input_ids" in detail['name']:
            interpreter.set_tensor(detail['index'], input_ids)
        elif "attention_mask" in detail['name']:
            interpreter.set_tensor(detail['index'], attention_mask)
            
    interpreter.invoke()
    
    output_data = interpreter.get_tensor(output_details[0]['index'])
    predictions = np.argmax(output_data, axis=-1)[0]
    
    word_ids = tokenized.word_ids()
    
    print(f"\n--- TEST: '{text}' ---")
    prev_idx = None
    for idx, word_idx in enumerate(word_ids):
        if word_idx is None or word_idx == prev_idx:
            continue
        tag = ids_to_tags[predictions[idx]]
        word = tokens[word_idx]
        print(f"{word:<20} -> {tag}")
        prev_idx = word_idx

print("\n--- RISULTATI DEL MODELLO ---")
predict("LATTE ESL BIO INT1L")
predict("CAROTE SAN ROCCO IT")
predict("COCA COLA ZERO 1.5L 2")
predict("SCONTO FIDELITY -1.50")
