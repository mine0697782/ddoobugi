import os
import re
import requests
import random
from flask import Flask, render_template, request, jsonify
from dotenv import load_dotenv
from langchain_openai import AzureChatOpenAI
from langchain_core.messages import HumanMessage, SystemMessage
from langchain_core.prompts import ChatPromptTemplate
import json

# 환경 변수 로드
load_dotenv()

# Flask 앱 설정
app = Flask(__name__)

# Google Maps API 설정
google_maps_api_key = os.getenv("GOOGLE_MAPS_API_KEY")
model_name = os.getenv("AZURE_OPENAI_DEPLOYMENT")
api_key = os.getenv("AZURE_OPENAI_API_KEY")
endpoint = os.getenv("AZURE_OPENAI_ENDPOINT")
api_version = os.getenv("OPENAI_API_VERSION")
# OpenAI 설정
exclude_place_ids = []

def search_nearby_places(lat, lng, radius=1000, place_type="point_of_interest"):
    url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
    params = {
        "location": f"{lat},{lng}",
        "radius": radius,  # 반경(미터 단위)
        "key": google_maps_api_key,
        "language": "ko",
        "type": place_type
    }

    response = requests.get(url, params=params)
    print(f"Request URL: {response.url}")  # 디버그: 요청 URL 출력
    if response.status_code == 200:
        results = response.json().get('results', [])
        #print(f"Nearby Places Response: {results}")  # 디버그: 응답 출력
        if not results:
            print(f"Error Message: {response.json().get('error_message', 'No places found')}")
        return results
    else:
        print(f"Error fetching nearby places: {response.status_code}, {response.text}")  # 디버그: 오류 세부 정보 출력
    return []

def get_place_details(place_id):
    url = "https://maps.googleapis.com/maps/api/place/details/json"
    params = {
        "place_id": place_id,
        "fields": "name,rating,formatted_address,reviews,geometry",
        "key": google_maps_api_key,
        "language": "ko"
    }
    response = requests.get(url, params=params)
    #print(f"Place Details URL: {response.url}")  # 디버그: 요청 URL 출력
    if response.status_code == 200:
        result = response.json().get('result', {})
        #print(f"Place Details Response: {result}")  # 디버그: 응답 출력
        return result
    else:
        print(f"Error fetching place details: {response.status_code}, {response.text}")  # 디버그: 오류 세부 정보 출력
    return {}

def summarize_places_with_gpt(place_info):
    prompt = f"다음 장소에 대한 정보를 간결하고 깔끔하게 한국어로 요약해주세요 선정이유도 포함하되, place_id는 빼주세요.:\n{place_info}"
    model = AzureChatOpenAI(
    azure_deployment=model_name,
    openai_api_key=api_key,
    api_version=api_version,
    temperature=0.7
    )
    model_output = model.invoke(prompt)

    return model_output.content.strip()

@app.route('/')
def index():
    return render_template('index.html', api_key=google_maps_api_key)

@app.route('/search', methods=['POST'])
def search():
    global exclude_place_ids
    data = request.json
    lat = data.get("lat")
    lng = data.get("lng")
    received_exclude_place_ids = data.get("exclude_place_ids", [])
    user_input = data.get("user_input", "")

    # 전역 변수 업데이트
    exclude_place_ids.extend(received_exclude_place_ids)

    print(f"Received exclude_place_ids: {received_exclude_place_ids}")
    print(f"Updated global exclude_place_ids: {exclude_place_ids}")
    try:
        # 주변 장소를 검색
        nearby_places = search_nearby_places(lat, lng)
        if not nearby_places:
            return jsonify({"error": "No nearby places found."}), 404

        # 제외할 장소 필터링
        nearby_places = [place for place in nearby_places if place['place_id'] not in exclude_place_ids]
        
        # GPT에게 제공할 프롬프트 작성
        prompt = f"사용자의 입력: {user_input}\n\n사용자의 좌표는 ({lat}, {lng})입니다. 주어진 장소 정보는 {nearby_places}입니다. 주어진 장소 정보들 중에서 리뷰와 평점, 거리 등에 따라 그리고 사용자의 입력에 따른 3개의 장소를 추천해줘, 그리고 다음과 같은 정보를 간결하고 보기좋게 나열해줘 각각 항목 이후에 줄바꿈도 해줘 - 이름, 평점, 리뷰요약, 거리, 이유, 주소, place_id\n"
        model = AzureChatOpenAI(
            azure_deployment=model_name,
            openai_api_key=api_key,
            api_version=api_version,
            temperature=0.7
        )
        response = model.invoke(prompt)
        model_output = response.content.strip()
        place_ids_1 = re.findall(r'- \*\*place_id\*\*:? *([A-Za-z0-9_-]+)', model_output)
        place_ids_2 = re.findall(r'- \*\*place_id:\*\*? *([A-Za-z0-9_-]+)', model_output)
        place_ids_3 = re.findall(r'place_id:\s*([A-Za-z0-9_-]+)', model_output)

        place_ids = place_ids_1 + place_ids_2 + place_ids_3
        print(place_ids)# 모델 출력에서 장소 이름을 추출 (예시로 정규식을 사용)
        #place_names = re.findall(r'name: (.*?),', model_output)
        print(model_output)
        # 검색된 장소와 비교하여 해당 이름의 place_id를 찾기
        #place_ids = [place['place_id'] for place in nearby_places if place['name'] in place_names]

        detailed_places = [get_place_details(place_id) for place_id in place_ids]
        
        # GPT를 위한 장소 정보 준비
        place_info_list = [
            f"Name: {place.get('name')}, Rating: {place.get('rating', 'N/A')}, Address: {place.get('formatted_address', 'N/A')}, Reviews: {', '.join([review.get('text', '') for review in place.get('reviews', [])])}"
            for place in detailed_places
        ]
        place_info = "\n".join(place_info_list)

        #summarized_info = summarize_places_with_gpt(place_info)
        summarized_info = summarize_places_with_gpt(model_output)


        return jsonify({"places": detailed_places, "place_info": summarized_info, "model_output": model_output, "place_ids": place_ids})
    except Exception as e:
        print(f"Exception: {str(e)}")
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)
