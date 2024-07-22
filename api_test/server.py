import os
import requests
import random
from flask import Flask, render_template, request, jsonify
from dotenv import load_dotenv

# 환경 변수 로드
load_dotenv()

# Flask 앱 설정
app = Flask(__name__)

# Google Maps API 설정
google_maps_api_key = os.getenv("GOOGLE_MAPS_API_KEY")

def search_nearby_places(lat, lng, radius=10000, place_type="point_of_interest"):
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
        print(f"Nearby Places Response: {results}")  # 디버그: 응답 출력
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
    print(f"Place Details URL: {response.url}")  # 디버그: 요청 URL 출력
    if response.status_code == 200:
        result = response.json().get('result', {})
        print(f"Place Details Response: {result}")  # 디버그: 응답 출력
        return result
    else:
        print(f"Error fetching place details: {response.status_code}, {response.text}")  # 디버그: 오류 세부 정보 출력
    return {}

@app.route('/')
def index():
    return render_template('index.html', api_key=google_maps_api_key)

@app.route('/search', methods=['POST'])
def search():
    data = request.json
    lat = data.get("lat")
    lng = data.get("lng")

    try:
        # 주변 장소를 검색
        nearby_places = search_nearby_places(lat, lng, place_type="point_of_interest")  # 다른 유형으로 변경
        if not nearby_places:
            return jsonify({"error": "No nearby places found."}), 404

        random_places = random.sample(nearby_places, min(len(nearby_places), 3))
        place_ids = [place['place_id'] for place in random_places]
        detailed_places = [get_place_details(place_id) for place_id in place_ids]

        # 디버깅: 자세한 장소 정보를 콘솔에 출력
        print("Detailed Places Information:")
        for place in detailed_places:
            print(f"Name: {place.get('name')}, Rating: {place.get('rating', 'N/A')}, Address: {place.get('formatted_address', 'N/A')}, Reviews: {', '.join([review.get('text', '') for review in place.get('reviews', [])])}")

        # GPT를 위한 장소 정보 준비
        place_info_list = [
            f"Name: {place.get('name')}, Rating: {place.get('rating', 'N/A')}, Address: {place.get('formatted_address', 'N/A')}, Reviews: {', '.join([review.get('text', '') for review in place.get('reviews', [])])}"
            for place in detailed_places
        ]
        place_info = "\n".join(place_info_list)

        return jsonify({"places": detailed_places, "place_info": place_info})
    except Exception as e:
        print(f"Exception: {str(e)}")  # 디버깅: 예외 출력
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)
