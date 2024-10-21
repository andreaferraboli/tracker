import json
from datetime import datetime, timedelta
import random
categorie = [
    "Carne",
    "Pesce",
    "Pasta, Pane e Sughi",
    "Verdura",
    "Frutta",
    "Latticini",
    "Legumi",
    "Acqua",
    "Dolci",
    "Bevande"
]

get_random_categoria = lambda: random.choice(categorie)
# Funzione che crea un singolo oggetto nel formato richiesto
def transform_product(item):
    product = item["product"]

    return {
        "unitWeight": float(product["productInfos"]["WEIGHT_SELLING"])/1000,
        "purchaseDate": "",  # Inserisci qui la data di acquisto se disponibile
        "quantity": item["quantity"],
        "quantityOwned": item["quantity"],
        "productId": str(product["productId"]),
        "totalPrice": round(product["price"] * item["quantity"], 2),  # Prezzo totale calcolato
        "productName": product["name"],
        "supermarket": "Eurospin",  # Inserisci qui il nome del supermercato se disponibile
        "unit": product["productInfos"]["UNITA_DI_MISURA_FISCALE"],
        "price": product["price"],
        "unitPrice": product["price"],
        "imageUrl": product["mediaURLMedium"],
        "totalWeight": round(float(product["productInfos"]["WEIGHT_SELLING"]) * item["quantity"], 2),
        "macronutrients": {
            "Proteins": 6.9,  # Valori ipotetici, inserisci i macronutrienti corretti se disponibili
            "Carbohydrates": 71,
            "Energy": 468,
            "Fiber": 2,
            "Fats": 17,
            "Sugars": 24
        },
        "category": get_random_categoria(),  # Categoria ipotetica, modifica secondo necessità
        "barcode": product["codeVariant"],
        "expirationDate": (datetime.now() + timedelta(days=random.randint(1, 365))).strftime('%Y-%m-%d')  # Data di scadenza casuale da oggi in poi  # Inserisci qui la data di scadenza se disponibile
    }

# Funzione principale per trasformare il file JSON
def transform_json_file(input_file, output_file):
    # Legge il file di input
    with open(input_file, 'r') as f:
        data = json.load(f)

    # Trasforma ogni prodotto
    transformed_data = [transform_product(item) for item in data]

    # Scrive il nuovo array di oggetti nel file di output
    with open(output_file, 'w') as f:
        json.dump(transformed_data, f, indent=4)

# Esegui la funzione
input_file = 'products.json'  # Nome del file di input
output_file = 'output.json'  # Nome del file di output

transform_json_file(input_file, output_file)
