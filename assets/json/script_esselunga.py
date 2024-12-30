import json
from datetime import datetime, timedelta
import random
import requests

# Lista delle categorie predefinite
categorie = [
    "drinks",
    "vegetables",
    "legumes",
    "fruit",
    "dairy_products",
    "pasta_bread_rice",
    "meat",
    "fish",
    "water",
    "dessert",
    "sauces_condiments",
    "salty_snacks"
]

# Funzione per inviare la richiesta API e ottenere le categorie
def get_categories_for_products(product_names):
    # Header e URL per la richiesta API
    headers = {
        "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiYTg0OTM3MjMtYjBlYy00MTk3LTg3M2UtZWY1Mzk2YTgzY2UzIiwidHlwZSI6ImFwaV90b2tlbiJ9.MPYFcsuJEx8UJxYfr7xlZST4gsowHtg7CNFQ7ciP6_E"}

    url = "https://api.edenai.run/v2/workflow/02ee8630-3ee4-43f0-ae57-7d4876d3d95f/execution/"
    payload = {"listNameProducts": product_names, "listCategories": categorie}

    response = requests.post(url, json=payload, headers=headers)
    result = json.loads(response.text)
    id = result['id']
    headers = {
        "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiYTg0OTM3MjMtYjBlYy00MTk3LTg3M2UtZWY1Mzk2YTgzY2UzIiwidHlwZSI6ImFwaV90b2tlbiJ9.MPYFcsuJEx8UJxYfr7xlZST4gsowHtg7CNFQ7ciP6_E"
    }
    url = f"https://api.edenai.run/v2/workflow/02ee8630-3ee4-43f0-ae57-7d4876d3d95f/execution/{id}/"

    response = requests.get(url, headers=headers)
    while response.json()['content']['status'] != "succeeded":
        response = requests.get(url, headers=headers)

    if response.status_code == 200:
        try:
            # Parsing della risposta per estrarre il testo generato
            generated_text = response.json()['content']['results']['text__chat']['results'][0]['generated_text']
            # Converti il testo JSON in una lista effettiva di categorie
            return json.loads(generated_text)
        except (KeyError, json.JSONDecodeError) as e:
            print(f"Errore nella risposta dell'API: {e}")
            return []
    else:
        print(f"Errore nella richiesta API: {response.status_code}")
        return []

# Funzione per convertire il prodotto dal formato originale a quello richiesto
def convert_product(product, category_map, index):
    category = category_map[index] if index < len(category_map) else "Sconosciuta"
    return {
        "unitWeight": float(product["displayableProduct"]["unitValue"]) / 1000,  # Convertiamo i grammi in chilogrammi
        "purchaseDate": datetime.now().strftime('%Y-%m-%d'),  # Data di acquisto attuale
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
        "totalWeight": float(product["displayableProduct"]["unitValue"]) / 1000,  # In chilogrammi
        "macronutrients": {  # Dati fittizi per ora
            "Proteins": 0.0,
            "Carbohydrates": 0.0,
            "Energy": 0.0,
            "Fiber": 0.0,
            "Fats": 0.0,
            "Sugars": 0.0
        },
        "category": category,  # Assegna la categoria ricevuta o "Sconosciuta" come default
        "barcode": product["displayableProduct"]["code"] if product["displayableProduct"]["code"] else "",
        "expirationDate": (datetime.now() + timedelta(days=random.randint(1, 365))).strftime('%Y-%m-%d'),
        "store": "Esselunga",
        "quantityUnitOwned": 0,
        "quantityWeightOwned": 0.0,
        "selectedQuantity": 0
    }

# Carichiamo il file originale (es. 'original_products.json')
with open('esselunga.json', 'r') as f:
    original_data = json.load(f)

# Colleziona i nomi dei prodotti
product_names = [item["displayableProduct"]["description"] for item in original_data]

# Ottiene le categorie dai nomi dei prodotti
category_map = get_categories_for_products(product_names)
if not isinstance(category_map, list):
    print("Errore: la risposta delle categorie non è una lista.")
    category_map = ["Sconosciuta"] * len(original_data)

# Convertiamo ogni prodotto nel nuovo formato
converted_products = [convert_product(item, category_map, index) for index, item in enumerate(original_data)]

# Salviamo i prodotti convertiti in un nuovo file JSON (es. 'converted_products.json')
with open('esselunga_output.json', 'w') as f:
    json.dump(converted_products, f, indent=4)

print("Conversione completata e salvata in 'converted_products.json'.")
