import json
import requests
from datetime import datetime, timedelta
import random

# Lista delle categorie predefinite
categorie = [
    "Carne",
    "Pesce",
    "Pasta, Pane e Riso",
    "Sughi e Condimenti",
    "Verdura",
    "Frutta",
    "Latticini",
    "Acqua",
    "Dolci",
    "Snack Salati",
    "Bevande"
]

# Funzione per inviare la richiesta API e ottenere le categorie
def get_categories_for_products(product_names):
    # Header e URL per la richiesta API
    headers = {"Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiYTg0OTM3MjMtYjBlYy00MTk3LTg3M2UtZWY1Mzk2YTgzY2UzIiwidHlwZSI6ImFwaV90b2tlbiJ9.MPYFcsuJEx8UJxYfr7xlZST4gsowHtg7CNFQ7ciP6_E"}

    url = "https://api.edenai.run/v2/workflow/02ee8630-3ee4-43f0-ae57-7d4876d3d95f/execution/"
    payload = {"listNameProducts":product_names,"listCategories":categorie}

    response = requests.post(url, json=payload, headers=headers)
    result = json.loads(response.text)
    id=result['id']
    headers = {
        "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiYTg0OTM3MjMtYjBlYy00MTk3LTg3M2UtZWY1Mzk2YTgzY2UzIiwidHlwZSI6ImFwaV90b2tlbiJ9.MPYFcsuJEx8UJxYfr7xlZST4gsowHtg7CNFQ7ciP6_E"
    }
    url = f"https://api.edenai.run/v2/workflow/02ee8630-3ee4-43f0-ae57-7d4876d3d95f/execution/{id}/"

    response = requests.get(url, headers=headers)
    while response.json()['content']['status'] != "success":
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

# Funzione che crea un singolo oggetto prodotto con categoria assegnata
def transform_product(item, category_map, index):
    product = item["product"]
    product_name = product["name"]

    # Controlla che l'indice non superi la lunghezza di category_map
    category = category_map[index] if index < len(category_map) else "Sconosciuta"

    return {
        "unitWeight": float(product["productInfos"]["WEIGHT_SELLING"]) / 1000,
        "purchaseDate": "",  # Data di acquisto, se disponibile
        "quantity": item["quantity"],
        "buyQuantity": 0,
        "quantityOwned": random.randint(0, 5),
        "productId": str(product["productId"]),
        "totalPrice": round(product["price"] * item["quantity"], 2),  # Prezzo totale calcolato
        "productName": product_name,
        "supermarket": "Eurospin",  # Supermercato, se disponibile
        "unit": product["productInfos"]["UNITA_DI_MISURA_FISCALE"],
        "price": product["price"],
        "unitPrice": product["price"],
        "imageUrl": product["mediaURLMedium"],
        "totalWeight": round(float(product["productInfos"]["WEIGHT_SELLING"]) * item["quantity"] / 1000, 3),
        "macronutrients": {
            "Proteins": 6.9,  # Valori ipotetici
            "Carbohydrates": 71,
            "Energy": 468,
            "Fiber": 2,
            "Fats": 17,
            "Sugars": 24
        },
        "category": category,  # Assegna la categoria ricevuta o "Sconosciuta" come default
        "barcode": product["codeVariant"],
        "expirationDate": (datetime.now() + timedelta(days=random.randint(1, 365))).strftime('%Y-%m-%d')  # Data scadenza casuale
    }

# Funzione principale per trasformare il file JSON
def transform_json_file(input_file, output_file):
    # Legge il file di input
    with open(input_file, 'r') as f:
        data = json.load(f)

    # Colleziona i nomi dei prodotti
    product_names = [item["product"]["name"] for item in data]

    # Ottiene le categorie dai nomi dei prodotti
    category_map = get_categories_for_products(product_names)
    if not isinstance(category_map, list):
        print("Errore: la risposta delle categorie non è una lista.")
        return

    # Trasforma ogni prodotto con la categoria assegnata
    transformed_data = [transform_product(item, category_map, index) for index, item in enumerate(data)]

    # Scrive il nuovo array di oggetti nel file di output
    with open(output_file, 'w') as f:
        json.dump(transformed_data, f, indent=4)

# Esegui la funzione
input_file = 'products.json'  # Nome del file di input
output_file = 'output.json'  # Nome del file di output

transform_json_file(input_file, output_file)
