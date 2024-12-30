import json
import requests
from datetime import datetime, timedelta
import random
import uuid

# Lista delle categorie predefinite
categorie = ['meat', 'fish', 'pasta_bread_rice', 'sauces_condiments', 'vegetables', 'fruit', 'dairy_products', 'water', 'dessert', 'salty_snacks', 'drinks']


# Funzione per inviare la richiesta API e ottenere le categorie
def get_categories_for_products(product_names):
    print(f"DEBUG: get_categories_for_products - product_names: {product_names}") # Debug Print
    # Header e URL per la richiesta API
    headers = {
        "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiYTg0OTM3MjMtYjBlYy00MTk3LTg3M2UtZWY1Mzk2YTgzY2UzIiwidHlwZSI6ImFwaV90b2tlbiJ9.MPYFcsuJEx8UJxYfr7xlZST4gsowHtg7CNFQ7ciP6_E"}

    url = "https://api.edenai.run/v2/workflow/02ee8630-3ee4-43f0-ae57-7d4876d3d95f/execution/"
    payload = {"listNameProducts":product_names,"listCategories":categorie}
    print(f"DEBUG: get_categories_for_products - payload: {payload}") # Debug Print

    response = requests.post(url, json=payload, headers=headers)
    print(f"DEBUG: get_categories_for_products - POST response status: {response.status_code}") # Debug Print
    print(f"DEBUG: get_categories_for_products - POST response text: {response.text}") # Debug Print
    result = json.loads(response.text)
    id=result['id']
    print(f"DEBUG: get_categories_for_products - id: {id}") # Debug Print

    headers = {
        "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiYTg0OTM3MjMtYjBlYy00MTk3LTg3M2UtZWY1Mzk2YTgzY2UzIiwidHlwZSI6ImFwaV90b2tlbiJ9.MPYFcsuJEx8UJxYfr7xlZST4gsowHtg7CNFQ7ciP6_E"}

    url = "https://api.edenai.run/v2/workflow/02ee8630-3ee4-43f0-ae57-7d4876d3d95f/execution/"
    url = f"https://api.edenai.run/v2/workflow/02ee8630-3ee4-43f0-ae57-7d4876d3d95f/execution/{id}/"

    response = requests.get(url, headers=headers)
    print(f"DEBUG: get_categories_for_products - GET response status (first): {response.status_code}") # Debug Print
    print(f"DEBUG: get_categories_for_products - GET response text (first): {response.text}") # Debug Print
    while response.json()['content']['status'] != "succeeded":
        response = requests.get(url, headers=headers)
        print(f"DEBUG: get_categories_for_products - GET response status (loop): {response.status_code}") # Debug Print
        print(f"DEBUG: get_categories_for_products - GET response text (loop): {response.text}") # Debug Print

    if response.status_code == 200:
        try:
            # Parsing della risposta per estrarre il testo generato
            generated_text = response.json()['content']['results']['text__chat']['results'][0]['generated_text']
            print(f"DEBUG: get_categories_for_products - generated_text: {generated_text}")  # Debug Print
            # Converti il testo JSON in una lista effettiva di categorie
            categories_list = json.loads(generated_text)
            print(f"DEBUG: get_categories_for_products - categories_list: {categories_list}") # Debug Print
            return categories_list
        except (KeyError, json.JSONDecodeError) as e:
            print(f"Errore nella risposta dell'API: {e}")
            return []
    else:
        print(f"Errore nella richiesta API: {response.status_code}")
        return []

# Funzione che crea un singolo oggetto prodotto con categoria assegnata
def transform_product(item, category_map, index):
    print(f"DEBUG: transform_product - item: {item}, category_map: {category_map}, index: {index}") # Debug Print
    product = item["product"]
    product_name = product["name"]

    # Controlla che l'indice non superi la lunghezza di category_map
    category = category_map[index] if index < len(category_map) else "meat"
    print(f"DEBUG: transform_product - category: {category}")  # Debug Print

    transformed_product = {
        "unitWeight": float(product["productInfos"]["WEIGHT_SELLING"]) / 1000,
        "purchaseDate": datetime.today().strftime("%Y-%m-%d"),  # Data di acquisto, se disponibile
        "quantity": item["quantity"],
        "buyQuantity": 0,
        "quantityOwned": 0,
        "quantityUnitOwned": 0,
        "quantityWeightOwned": 0,
        "store": "fridge",
        "productId": uuid.uuid4().__str__(),
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
    print(f"DEBUG: transform_product - transformed_product: {transformed_product}") # Debug Print
    return transformed_product

# Funzione principale per trasformare il file JSON
def transform_json_file(input_file, output_file):
    print(f"DEBUG: transform_json_file - input_file: {input_file}, output_file: {output_file}")  # Debug Print
    # Legge il file di input
    with open(input_file, 'r') as f:
        data = json.load(f)
    print(f"DEBUG: transform_json_file - data loaded: {data}") # Debug Print

    # Colleziona i nomi dei prodotti
    product_names = [item["product"]["name"] for item in data]
    print(f"DEBUG: transform_json_file - product_names: {product_names}") # Debug Print

    # Ottiene le categorie dai nomi dei prodotti
    category_map = get_categories_for_products(product_names)
    if not isinstance(category_map, list):
        print("Errore: la risposta delle categorie non è una lista.")
        return
    print(f"DEBUG: transform_json_file - category_map received: {category_map}") # Debug Print


    # Trasforma ogni prodotto con la categoria assegnata
    transformed_data = [transform_product(item, category_map, index) for index, item in enumerate(data)]
    print(f"DEBUG: transform_json_file - transformed_data: {transformed_data}") # Debug Print


    # Scrive il nuovo array di oggetti nel file di output
    with open(output_file, 'w') as f:
        json.dump(transformed_data, f, indent=4)
    print(f"DEBUG: transform_json_file - output file written") # Debug Print


# Esegui la funzione
input_file = 'products.json'  # Nome del file di input
output_file = 'output.json'  # Nome del file di output

transform_json_file(input_file, output_file)