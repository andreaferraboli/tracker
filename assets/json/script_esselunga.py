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

# Funzione per convertire il prodotto dal formato originale a quello richiesto
def convert_product(product):
    return {
        "unitWeight": float(product["displayableProduct"]["unitValue"]) / 1000,  # Convertiamo i grammi in chilogrammi
        "purchaseDate": datetime.now().strftime('%Y-%m-%d'),  # Data di acquisto attuale,  # Da compilare successivamente
        "quantity": product["displayableProduct"]["quantity"],
        "buyQuantity": 0,
        "quantityOwned": 0,
        "productId": str(product["displayableProduct"]["productId"]),
        "totalPrice": product["displayableProduct"]["price"],
        "productName": product["displayableProduct"]["description"],
        "supermarket": "Esselunga",  # Basato sull'informazione "companyCode"
        "unit": "KG",
        "price": product["displayableProduct"]["price"],
        "unitPrice": product["displayableProduct"]["price"] / product["displayableProduct"]["quantity"],
        "imageUrl": product["displayableProduct"]["imageURL"],
        "totalWeight": float(product["displayableProduct"]["unitValue"]) / 1000,  # In chilogrammi  # In grammi
        "macronutrients": {  # Dati fittizi per ora
            "Proteins": 0.0,
            "Carbohydrates": 0.0,
            "Energy": 0.0,
            "Fiber": 0.0,
            "Fats": 0.0,
            "Sugars": 0.0
        },
        "category": get_random_categoria(),  # Categoria esempio
        "barcode": product["displayableProduct"]["code"] if product["displayableProduct"]["code"] else "N/A",
        "expirationDate": (datetime.now().replace(year=datetime.now().year + 1)).strftime('%Y-%m-%d')  # Data di scadenza fittizia un anno avanti
    }

# Carichiamo il file originale (es. 'original_products.json')
with open('esselunga.json', 'r') as f:
    original_data = json.load(f)

# Convertiamo ogni prodotto nel nuovo formato
converted_products = [convert_product(item) for item in original_data]

# Salviamo i prodotti convertiti in un nuovo file JSON (es. 'converted_products.json')
with open('esselunga_output.json', 'w') as f:
    json.dump(converted_products, f, indent=4)

print("Conversione completata e salvata in 'converted_products.json'.")
