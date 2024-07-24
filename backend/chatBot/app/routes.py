from flask import render_template, request, jsonify, current_app as app
from .services import search_nearby_places, get_place_details, summarize_places_with_gpt
import re

exclude_place_ids = []

@app.route('/')
def index():
    return render_template('index.html', api_key=app.config['GOOGLE_MAPS_API_KEY'])

@app.route('/search', methods=['POST'])
def search():
    global exclude_place_ids
    data = request.json
    lat = data.get("lat")
    lng = data.get("lng")
    received_exclude_place_ids = data.get("exclude_place_ids", [])
    user_input = data.get("user_input", "")

    exclude_place_ids.extend(received_exclude_place_ids)

    try:
        nearby_places = search_nearby_places(lat, lng, app.config['GOOGLE_MAPS_API_KEY'])
        if not nearby_places:
            return jsonify({"error": "No nearby places found."}), 404

        nearby_places = [place for place in nearby_places if place['place_id'] not in exclude_place_ids]

        prompt = f"사용자의 입력: {user_input}\n\n사용자의 좌표는 ({lat}, {lng})입니다. 주어진 장소 정보는 {nearby_places}입니다. 주어진 장소 정보들 중에서 리뷰와 평점, 거리 등에 따라 그리고 사용자의 입력에 따른 3개의 장소를 추천해줘, 그리고 다음과 같은 정보를 간결하고 보기좋게 나열해줘 각각 항목 이후에 줄바꿈도 해줘 - 이름, 평점, 리뷰요약, 거리, 이유, 주소, place_id\n"
        
        summarized_info, place_ids = summarize_places_with_gpt(prompt, app.config)

        detailed_places = [get_place_details(place_id, app.config['GOOGLE_MAPS_API_KEY']) for place_id in place_ids]

        return jsonify({"places": detailed_places, "place_info": summarized_info, "model_output": summarized_info, "place_ids": place_ids})
    except Exception as e:
        return jsonify({"error": str(e)}), 500
