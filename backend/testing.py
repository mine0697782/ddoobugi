from flask import Flask, render_template, request, jsonify
import os
import re
import requests
from dotenv import load_dotenv
from langchain_openai import AzureChatOpenAI
from langchain_core.messages import HumanMessage, SystemMessage
from geopy.distance import geodesic

# 환경 변수 로드
load_dotenv()

# Azure OpenAI 설정
model_name = os.getenv("AZURE_OPENAI_DEPLOYMENT")
api_key = os.getenv("AZURE_OPENAI_API_KEY")
endpoint = os.getenv("AZURE_OPENAI_ENDPOINT")
api_version = os.getenv("OPENAI_API_VERSION")

# Google Maps API 설정
google_maps_api_key = os.getenv("GOOGLE_MAPS_API_KEY")

app = Flask(__name__)

def extract_keywords(text):
    text = text.lower()
    expression = r".*keywords:(.+?)$"
    if re.search(expression, text):
        keywords = re.sub(expression, r"\1", text, flags=re.S)
        if keywords is not None and len(keywords) > 0:
            return [re.sub(r"\.$", "", k.strip()) for k in keywords.strip().split(',')]
    return []

def extract_keywords_from_chat(chat, input_text):
    resp = chat.invoke([
                SystemMessage(content=
                        "You extract the main keywords in the text and extract these into a comma separated list. Please prefix the keywords with 'Keywords:'"),
                HumanMessage(content=input_text)
            ])
    answer = resp.content
    return answer

def search_place(query):
    url = "https://maps.googleapis.com/maps/api/place/textsearch/json"
    params = {
        "query": query,
        "key": google_maps_api_key,
        "language": "ko"
    }
    response = requests.get(url, params=params)
    if response.status_code == 200:
        return response.json()
    else:
        return None

def recommend_places(chat, places_info, user_location):
    # Calculate the distance of each place from the user's location
    for place in places_info:
        place_location = (place['lat'], place['lng'])
        place['distance'] = geodesic(user_location, place_location).meters

    # Sort places by distance and rating
    sorted_places = sorted(places_info, key=lambda x: (x['distance'], -x['rating']))

    # Prepare the top 3 recommended places
    top_places = sorted_places[:3]
    places_str = "\n".join([f"{i+1}. Name: {place['name']}, Address: {place['address']}, Rating: {place['rating']}, User Ratings: {place['user_ratings_total']}, Open Now: {place['open_now']}, Distance: {place['distance']} meters" for i, place in enumerate(top_places)])
    prompt = f"Here are some places:\n{places_str}\n\nRecommend the top 3 places based on closest distance and highest rating."
    resp = chat.invoke([
        SystemMessage(content=prompt),
        HumanMessage(content="")
    ])
    recommended_places = [place for place in top_places]  # 추천된 장소 목록 반환
    return recommended_places

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/extract_keywords', methods=['POST'])
def extract_keywords_route():
    chat = AzureChatOpenAI(
        azure_deployment=model_name,
        openai_api_key=api_key,
        api_version=api_version,
        temperature=0
    )
    user_input = request.json.get("input_text")
    answer = extract_keywords_from_chat(chat, user_input)
    extracted_keywords = extract_keywords(answer)
    return jsonify(keywords=extracted_keywords)

@app.route('/search', methods=['POST'])
def search():
    data = request.json
    query = data.get("query")
    user_lat = data.get("latitude")
    user_lng = data.get("longitude")
    user_location = (user_lat, user_lng)

    result = search_place(query)
    if result and "results" in result:
        places_info = []
        for place in result["results"]:
            places_info.append({
                "name": place["name"],
                "address": place.get("formatted_address", "N/A"),
                "rating": place.get("rating", "N/A"),
                "user_ratings_total": place.get("user_ratings_total", "N/A"),
                "open_now": place.get("opening_hours", {}).get("open_now", "N/A"),
                "lat": place["geometry"]["location"]["lat"],
                "lng": place["geometry"]["location"]["lng"]
            })
        
        chat = AzureChatOpenAI(
            azure_deployment=model_name,
            openai_api_key=api_key,
            api_version=api_version,
            temperature=0
        )
        
        recommended_places = recommend_places(chat, places_info, user_location)
        return jsonify(recommendations=recommended_places, results=result["results"])
    else:
        return jsonify(results=[])

if __name__ == '__main__':
    app.run(debug=True)