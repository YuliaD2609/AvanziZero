import json
import random
import os

# Definisce le liste di prodotti base
FRUTTA_VERDURA = [
    "MELA", "MELE", "BANANA", "BANANE", "POMODORO", "POMODORI", "INSALATA", "PATATE",
    "CIPOLLA", "CIPOLLE", "CAROTE", "ZUCCHINE", "LIMONE", "LIMONI", "PESCA", "PESCHE",
    "UVA", "FRAGOLE", "MELANZANE", "PEPERONI", "AGLIO", "RADICCHIO", "KIWI", "RUCOLA",
    "SPINACI", "BROCCOLI", "CAVOLFIORE", "VERZA", "MANDARINI", "ARANCE", "PERA", "PERE",
    "CETRIOLI", "ZACCHINE BIO", "POMODORO CILIEGINO", "CAROTE BIO", "PATATE NOVELLE"
]

LATTICINI = [
    "LATTE", "MOZZARELLA", "BURRO", "YOGURT", "FORMAGGIO", "PARMIGIANO", "GRANA",
    "UOVA", "PANNA", "STRACCHINO", "RICOTTA", "SOTTILETTE", "MASCARPONE", "GORGONZOLA",
    "PROVOLONE", "PECORINO", "LATTE INTERO", "LATTE P.S.", "YOGURT BIANCO", "YOGURT FRUTTA",
    "BURRO CHIARIFICATO", "LATTE DI SOIA", "BEVANDA AVENA"
]

CARNE_PESCE = [
    "POLLO", "MANZO", "MAIALE", "CARNE", "SALAME", "PROSCIUTTO", "TONNO", "SALMONE",
    "PESCE", "HAMBURGER", "WURSTEL", "MORTADELLA", "PANCETTA", "SALSICCIA", "BRESAOLA",
    "SGOMBRO", "MERLUZZO", "BRANZINO", "ORATA", "PETTO DI POLLO", "FETTINE DI VITELLO",
    "COPPA DI PARMA", "PROSCIUTTO CRUDO", "PROSCIUTTO COTTO", "SALAME MILANO"
]

SECCO_PASTA = [
    "PASTA", "SPAGHETTI", "PENNE", "FUSILLI", "MACCHERONI", "RISO", "PANE", "PIADINA",
    "FARINA", "ZUCCHERO", "SALE", "OLIO", "ACETO", "BISCOTTI", "CEREALI", "CAFFE",
    "NUTELLA", "MARMELLATA", "FETTE BISCOTTATE", "CRACKERS", "PASSATA", "PESTO",
    "MAIONESE", "KETCHUP", "LENTICCHIE", "SFOGLIA", "RISO ARBORIO", "PASTA INTEGRALE",
    "FARINA 00", "ZUCCHERO DI CANNA", "OLIO EVO", "ACETO BALSAMICO", "CAFFE LAVAZZA",
    "CAFFE BORBONE", "BISCOTTI MULINO BIANCO", "TONNO RIO MARE"
]

BEVANDE = [
    "ACQUA", "COCA COLA", "VINO", "BIRRA", "SUCCO", "FANTA", "SPRITE", "ESTATHE",
    "THE", "ACQUA NATURALE", "ACQUA FRIZZANTE", "BIRRA MORETTI", "BIRRA HEINEKEN",
    "VINO ROSSO", "VINO BIANCO", "SUCCO DI MELA", "SUCCO DI ARANCIA", "COCA ZERO"
]

IGIENE = [
    "CARTA IGIENICA", "DETERSIVO", "SAPONE", "SHAMPOO", "DENTIFRICIO", "SPUGNA",
    "CARTA CASA", "BAGNOSCHIUMA", "SGRASSATORE", "CANDEGGINA", "AMMORBIDENTE",
    "DEODORANTE", "PANNOLINI", "SALVASLIP", "DENTIFRICIO COLGATE", "SHAMPOO PANTENE",
    "BAGNOSCHIUMA NIVEA", "SGRASSATORE CHANTECLAIR", "DETERSIVO PIATTI"
]

ALL_PRODUCTS = FRUTTA_VERDURA + LATTICINI + CARNE_PESCE + SECCO_PASTA + BEVANDE + IGIENE

SUPERMARKET_BRANDS = ["COOP", "MAXI", "CONAD", "ESSELUNGA", "PAM", "LIDL", "EUROSPIN", "CARREFOUR", "MD", "PENNY", "CRAI", "DESPAR", "IPER", "FAMILA"]
PRODUCT_MODIFIERS = ["SAN", "ROCCO", "VALLE", "FATTORIA", "MULINO", "BARILLA", "MUTTI", "FERRERO", "IT", "IGP", "DOP", "DOC", "BIO", "EXTRA", "PREMIUM", "NOSTRANO", "PREC", "LORIANA", "VVERDEB", "ITALIA"]

def add_noise(word):
    """Introduce errori OCR tipici."""
    if random.random() < 0.1:
        return word.replace("O", "0")
    if random.random() < 0.1:
        return word.replace("I", "1")
    if random.random() < 0.1:
        return word.replace("B", "8")
    if random.random() < 0.05 and len(word) > 3:
        # Rimuove un carattere casuale
        return word[:len(word)//2] + word[len(word)//2 + 1:]
    return word

def generate_receipt_item():
    """Genera una riga di scontrino annotata."""
    tokens = []
    ner_tags = []
    
    # Calcola la probabilità per la quantità
    has_qty = random.random() > 0.3
    qty_first = random.random() > 0.5
    
    qty = str(random.randint(1, 5))
    if random.random() > 0.7:
        qty += "x"
    elif random.random() > 0.8:
        qty += "pz"
        
    product = random.choice(ALL_PRODUCTS)
    product_tokens = product.split()
    
    # Applica modificatori al prodotto
    if random.random() > 0.4:
        # Seleziona modificatori casuali
        mods = random.sample(PRODUCT_MODIFIERS, k=random.randint(1, 2))
        product_tokens.extend(mods)
        
    # Applica rumore simulato ai token
    product_tokens = [add_noise(t) for t in product_tokens]
    
    # Prepara rumore da etichettare come O
    extra_noise = []
    # Inserisce nomi di brand da ignorare
    if random.random() > 0.6:
        extra_noise.append(random.choice(SUPERMARKET_BRANDS))
        
    if random.random() > 0.7:
        extra_noise.append(f"{random.randint(10,99)}-{random.randint(1,9)}")
    if random.random() > 0.8:
        extra_noise.append(f"{random.randint(100,500)}g")
    if random.random() > 0.9:
        extra_noise.append(str(random.randint(1000,9999)))
        
    price = f"{random.randint(0, 20)},{random.randint(10, 99)}"
    iva_code = random.choice(["", " B", " C", " D", " IVA"])
    price += iva_code
    
    # Compone la riga finale con i token
    if has_qty and qty_first:
        tokens.append(qty)
        ner_tags.append("B-QTY")
        
    for i, pt in enumerate(product_tokens):
        tokens.append(pt)
        ner_tags.append("B-PROD" if i == 0 else "I-PROD")
        
    if has_qty and not qty_first:
        tokens.append(qty)
        ner_tags.append("B-QTY")
        
    # Inserisce token di rumore ed extra
    for noise in extra_noise:
        tokens.append(noise)
        ner_tags.append("O")
        
    tokens.append(price)
    ner_tags.append("O")
    
    return {"tokens": tokens, "ner_tags": ner_tags}

def generate_garbage_line():
    """Genera una riga di puro rumore (sconti, totale, iva, marche supermercati)."""
    supermercati = ["COOP", "MAXI", "CONAD", "ESSELUNGA", "PAM", "LIDL", "EUROSPIN", "CARREFOUR", "MD", "PENNY", "CRAI", "DESPAR", "IPER", "FAMILA"]
    
    options = [
        ["SCONTO", "SOCI", "-1,50"],
        ["SCONTO", "35%", "CLIENTI", "-0,39"],
        ["TOTALE", "EURO", "15,40"],
        ["PAGAMENTO", "BANCOMAT", "15,40"],
        ["NS", "SACCHETTO", "COMPOST", "0,01", "D"],
        ["RESTO", "0,00"],
        ["TRANSAZIONE", "POS", "OK"],
        ["PUNTI", "FIDATY", "150"],
        ["OFFERTA", "PROMO", "-2,00"],
        ["C:","IVA","10%"],
        ["REPARTO", "GASTRONOMIA"],
        [random.choice(supermercati)],
        [random.choice(supermercati), "ITALIA", "SPA"],
        ["SCANSIONATO", "CON", "CAMSCANNER"],
        ["ARRIVEDERCI", "E", "GRAZIE"],
        [str(random.randint(1000, 9999)), "B"],
        ["VIA", "ROMA", "15", "TEL", "02123456"]
    ]
    tokens = random.choice(options)
    ner_tags = ["O"] * len(tokens)
    return {"tokens": tokens, "ner_tags": ner_tags}

def main():
    dataset = []
    NUM_EXAMPLES = 200000
    
    print(f"Generazione dataset sintetico massivo ({NUM_EXAMPLES} esempi)...")
    for _ in range(NUM_EXAMPLES):
        # Aggiunge una riga di puro rumore con probabilità del 15%
        if random.random() < 0.15:
            dataset.append(generate_garbage_line())
        else:
            dataset.append(generate_receipt_item())
            
    with open("receipt_dataset.json", "w", encoding="utf-8") as f:
        json.dump(dataset, f, indent=2, ensure_ascii=False)
        
    print(f"Generato 'receipt_dataset.json' con {len(dataset)} esempi!")

if __name__ == "__main__":
    main()
