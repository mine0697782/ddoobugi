from flask import Flask, render_template, request, jsonify
import os
import re
import requests
from dotenv import load_dotenv
from langchain_openai import AzureChatOpenAI
from langchain_core.messages import HumanMessage, SystemMessage
from geopy.distance import geodesic
import random
from langchain.chains import LLMChain
from langchain.prompts import PromptTemplate
from functools import lru_cache
import json

# Load environment variables
load_dotenv()

# Azure OpenAI settings
model_name = os.getenv("AZURE_OPENAI_DEPLOYMENT")
api_key = os.getenv("AZURE_OPENAI_API_KEY")
endpoint = os.getenv("AZURE_OPENAI_ENDPOINT")
api_version = os.getenv("OPENAI_API_VERSION")

# Google Maps API settings
google_maps_api_key = os.getenv("GOOGLE_MAPS_API_KEY")

app = Flask(__name__)

# 저장할 파일 경로
PLACES_FILE = 'places.json'

# 장소를 파일에 저장하는 함수
def save_places_to_file(places):
    with open(PLACES_FILE, 'w', encoding='utf-8') as f:
        json.dump(places, f, ensure_ascii=False, indent=4)

# 파일에서 장소를 불러오는 함수
def load_places_from_file():
    if os.path.exists(PLACES_FILE):
        with open(PLACES_FILE, 'r', encoding='utf-8') as f:
            return json.load(f)
    return []

# 키워드 추출 함수
def extract_keywords(text):
    text = text.lower()
    expression = r".*keywords:(.+?)$"
    if re.search(expression, text):
        keywords = re.sub(expression, r"\1", text, flags=re.S)
        if keywords is not None and len(keywords) > 0:
            return [re.sub(r"\.$", "", k.strip()) for k in keywords.strip().split(',')]
    return []

# ChatGPT 모델에 입력 텍스트 전달 후 주요 키워드를 추출
def extract_keywords_from_chat(chat, input_text):
    resp = chat.invoke([
                SystemMessage(content=
                        "You extract the main keywords in the text and extract these into a comma separated list. Please prefix the keywords with 'Keywords:'"),
                HumanMessage(content=input_text)
            ])
    answer = resp.content
    return answer

@lru_cache(maxsize=100)
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
    open_places = [place for place in places_info if place['open_now']]
    for place in open_places:
        place_location = (place['lat'], place['lng'])
        place['distance'] = geodesic(user_location, place_location).meters
    random.shuffle(open_places)
    top_places = open_places[:]
    places_str = "\n".join([
        f"{i+1}. Name: {place['name']}, Address: {place['address']}, Rating: {place['rating']}, "
        f"User Ratings: {place['user_ratings_total']}, Open Now: {place['open_now']}, Distance: {place['distance']} meters"
        for i, place in enumerate(top_places)
    ])
    prompt_template = PromptTemplate(
        input_variables=["places"], 
        template="Here are some places:\n{places}\n\nRecommend the top 3 places based on closest distance and highest rating."
    )
    chain = LLMChain(llm=chat, prompt=prompt_template)
    response = chain.invoke({"places": places_str})
    if isinstance(response, dict):
        recommendation_text = response.get("text", "")
        recommended_place_names = recommendation_text.split("\n")
    else:
        recommended_place_names = []
    recommended_places = []
    for place_name in recommended_place_names:
        for place in top_places:
            if place_name.strip() in place['name'] and place not in recommended_places:
                recommended_places.append(place)
                break
        if len(recommended_places) >= 3:
            break
    return recommended_places

def generate_comment_for_place(chat, place, keywords):
    place_str = f"Name: {place['name']}, Address: {place['address']}, Rating: {place['rating']}, " \
                f"User Ratings: {place['user_ratings_total']}, Open Now: {place['open_now']}, Distance: {place['distance']} meters"
    prompt_template = PromptTemplate(
        input_variables=["place", "keywords"],
        template="Here is a place:\n{place}\n\nAnd this is a Keywords in sentences searched by users:\n{keywords}\n\nGive a detailed and engaging comment about this place in Korean. Describe why this place is worth visiting."
                 "Please do not directly mention distance, rating, number of reviews, etc."
                 "Please specify what this place does"
                 "And print the keywords you got."
                 "Please respond in a legible manner."
    )
    chain = LLMChain(llm=chat, prompt=prompt_template)
    response = chain.invoke({"place": place_str, "keywords": ", ".join(keywords)})
    if isinstance(response, dict):
        comment = response.get("text", "")
    else:
        comment = response
    return comment

@app.route('/')
def index():
    return render_template('index.html', google_maps_api_key=google_maps_api_key)

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

@app.route('/place')
def place():
    return render_template('place.html', google_maps_api_key=google_maps_api_key)

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
                "open_now": place.get("opening_hours", {}).get("open_now", False),
                "lat": place["geometry"]["location"]["lat"],
                "lng": place["geometry"]["location"]["lng"]
            })
        chat = AzureChatOpenAI(
            azure_deployment=model_name,
            openai_api_key=api_key,
            api_version=api_version,
            temperature=0.9
        )
        answer = extract_keywords_from_chat(chat, query)
        extracted_keywords = extract_keywords(answer)
        recommended_places = recommend_places(chat, places_info, user_location)
        comments = [generate_comment_for_place(chat, place, extracted_keywords) for place in recommended_places]
        for place, comment in zip(recommended_places, comments):
            place["comment"] = comment
        return jsonify(recommendations=recommended_places, results=places_info)
    else:
        return jsonify(results=[])

@app.route('/save_place', methods=['POST'])
def save_place():
    data = request.json
    places = load_places_from_file()
    places.append(data)
    save_places_to_file(places)
    return jsonify({"message": "Place saved successfully"}), 201

@app.route('/delete_place', methods=['POST'])
def delete_place():
    data = request.json
    index = data.get('index')
    places = load_places_from_file()
    if 0 <= index < len(places):
        places.pop(index)
        save_places_to_file(places)
        return jsonify({"message": "Place deleted successfully"}), 200
    return jsonify({"message": "Invalid index"}), 400

@app.route('/saved_places', methods=['GET'])
def saved_places():
    places = load_places_from_file()
    return jsonify(places)

@app.route('/show_saved_places')
def show_saved_places():
    return render_template('saved_places.html')

@app.route('/search_restroom', methods=['POST'])
def search_restroom():
    data = request.json
    user_lat = data.get("latitude")
    user_lng = data.get("longitude")
    user_location = (user_lat, user_lng)
    query = "화장실"
    result = search_place(query)
    if result and "results" in result:
        places_info = []
        for place in result["results"]:
            places_info.append({
                "name": place["name"],
                "address": place.get("formatted_address", "N/A"),
                "rating": place.get("rating", "N/A"),
                "user_ratings_total": place.get("user_ratings_total", "N/A"),
                "open_now": place.get("opening_hours", {}).get("open_now", False),
                "lat": place["geometry"]["location"]["lat"],
                "lng": place["geometry"]["location"]["lng"]
            })
        for place in places_info:
            place_location = (place['lat'], place['lng'])
            place['distance'] = geodesic(user_location, place_location).meters
        sorted_places = sorted(places_info, key=lambda x: x['distance'])
        top_places = sorted_places[:3]
        return jsonify(recommendations=top_places, results=places_info)
    else:
        return jsonify(results=[])

if __name__ == '__main__':
    app.run(debug=True)
