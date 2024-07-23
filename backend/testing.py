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
    # 필터링: 현재 열려 있는 장소만 포함
    open_places = [place for place in places_info if place['open_now']]

    # 사용자 위치로부터 각 장소까지의 거리 계산
    for place in open_places:
        place_location = (place['lat'], place['lng'])
        place['distance'] = geodesic(user_location, place_location).meters

    # 장소를 무작위로 섞음
    #random.shuffle(open_places)
    # 거리와 평점 기준으로 장소 정렬
    sorted_places = sorted(open_places, key=lambda x: (x['distance'], -x['rating']))

    # 장소들을 선택하여 LLMChain의 입력으로 사용
    #top_places = open_places[:]
    top_places = sorted_places[:]
    places_str = "\n".join([
        f"{i+1}. Name: {place['name']}, Address: {place['address']}, Rating: {place['rating']}, "
        f"User Ratings: {place['user_ratings_total']}, Open Now: {place['open_now']}, Distance: {place['distance']} meters"
        for i, place in enumerate(top_places)
    ])

    # 프롬프트 템플릿 생성
    prompt_template = PromptTemplate(
        input_variables=["places"], 
        template="Here are some places:\n{places}\n\nRecommend the top 3 places based on closest distance and highest rating. Basically, recommend in order of distance, but if the number of reviews is overwhelmingly high, recommend that place first."
    )

    # LLMChain 생성
    chain = LLMChain(llm=chat, prompt=prompt_template)

    # 추천 생성
    response = chain.invoke({"places": places_str})

    # 응답이 딕셔너리 형식으로 반환될 경우 직접 필요한 정보를 추출
    if isinstance(response, dict):
        recommendation_text = response.get("text", "")
        recommended_place_names = recommendation_text.split("\n")  # 응답에서 장소 이름을 추출하는 로직 필요
    else:
        recommended_place_names = []  # 오류 처리

    # 추천 장소
    recommended_places = []
    for place_name in recommended_place_names:
        # 장소 이름이 응답에 포함되어 있는 경우, 상위 10개 장소 리스트에서 찾아 추가
        for place in top_places:
            if place_name.strip() in place['name'] and place not in recommended_places:
                recommended_places.append(place)
                break
        if len(recommended_places) >= 3:
            break

    return recommended_places

    


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


def generate_recommendation_comment(chat, recommended_places):
    # 장소들에 대한 정보를 문자열로 변환.
    places_str = "\n".join([
        f"{i+1}. Name: {place['name']}, Address: {place['address']}, Rating: {place['rating']}, "
        f"User Ratings: {place['user_ratings_total']}, Open Now: {place['open_now']}, Distance: {place['distance']} meters"
        for i, place in enumerate(recommended_places)
    ])

    # 프롬프트 템플릿 생성
    prompt_template = PromptTemplate(
        input_variables=["places"],
        template="Here are some recommended places:\n{places}\n\nProvide a brief overall comment on why these places are recommended, considering their ratings, user reviews, and distances. Please use appropriate line breaks for readability. Please give a creative answer and give it with Korean."
    )

    # LLMChain 생성
    chain = LLMChain(llm=chat, prompt=prompt_template)

    # 종합 코멘트 생성
    response = chain.invoke({"places": places_str})

    # 응답이 딕셔너리 형식으로 반환될 경우 직접 필요한 정보를 추출.
    if isinstance(response, dict):
        overall_comment = response.get("text", "")
    else:
        overall_comment = response

    return overall_comment

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
            temperature=1.5
        )
        
        recommended_places = recommend_places(chat, places_info, user_location)
        overall_comment = generate_recommendation_comment(chat, recommended_places)
        
        return jsonify(recommendations=recommended_places, results=places_info, comment=overall_comment)
    else:
        return jsonify(results=[])


if __name__ == '__main__':
    app.run(debug=True)