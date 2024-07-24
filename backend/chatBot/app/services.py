import requests
import re
from langchain_openai import AzureChatOpenAI

def search_nearby_places(lat, lng, google_maps_api_key, radius=1000, place_type="point_of_interest"):
    url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
    params = {
        "location": f"{lat},{lng}",
        "radius": radius,
        "key": google_maps_api_key,
        "language": "ko",
        "type": place_type
    }

    response = requests.get(url, params=params)
    if response.status_code == 200:
        return response.json().get('results', [])
    return []

def get_place_details(place_id, google_maps_api_key):
    url = "https://maps.googleapis.com/maps/api/place/details/json"
    params = {
        "place_id": place_id,
        "fields": "name,rating,formatted_address,reviews,geometry",
        "key": google_maps_api_key,
        "language": "ko"
    }
    response = requests.get(url, params=params)
    if response.status_code == 200:
        return response.json().get('result', {})
    return {}

def summarize_places_with_gpt(prompt, config):
    model = AzureChatOpenAI(
        azure_deployment=config['AZURE_OPENAI_DEPLOYMENT'],
        openai_api_key=config['AZURE_OPENAI_API_KEY'],
        api_version=config['OPENAI_API_VERSION'],
        temperature=0.7
    )
    response = model.invoke(prompt)
    model_output = response.content.strip()
    
    place_ids_1 = re.findall(r'- \*\*place_id\*\*:? *([A-Za-z0-9_-]+)', model_output)
    place_ids_2 = re.findall(r'- \*\*place_id:\*\*? *([A-Za-z0-9_-]+)', model_output)
    place_ids_3 = re.findall(r'place_id:\s*([A-Za-z0-9_-]+)', model_output)

    place_ids = place_ids_1 + place_ids_2 + place_ids_3
    return model_output, place_ids
