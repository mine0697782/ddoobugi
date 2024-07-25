from flask import Blueprint, render_template, request, jsonify, current_app
from flask_login import login_required
from .services import search_nearby_places, get_place_details, summarize_places_with_gpt
import re

main = Blueprint('main', __name__)

exclude_place_ids = []

@main.route('/')
@login_required
def index():
    return render_template('index.html', api_key=current_app.config['GOOGLE_MAPS_API_KEY'])

@main.route('/search', methods=['POST'])
@login_required
def search():
    global exclude_place_ids
    data = request.json
    lat = data.get("lat")
    lng = data.get("lng")
    received_exclude_place_ids = data.get("exclude_place_ids", [])
    user_input = data.get("user_input", "")

    exclude_place_ids.extend(received_exclude_place_ids)

    try:
        nearby_places = search_nearby_places(lat, lng, current_app.config['GOOGLE_MAPS_API_KEY'])
        if not nearby_places:
            return jsonify({"error": "No nearby places found."}), 404

        nearby_places = [place for place in nearby_places if place['place_id'] not in exclude_place_ids]
        prompt = f'''
        사용자의 입력: {user_input}

        사용자의 좌표는 ({lat}, {lng})입니다. 주어진 장소 정보는 {nearby_places}입니다. 
        주어진 장소 정보들 중에서 리뷰와 평점, 거리 등에 따라 그리고 사용자의 입력에 따른 3개의 장소를 추천해줘, 그리고 다음과 같은 정보를 간결하고 보기좋게 나열해줘 각각 항목 이후에 줄바꿈도 해줘.
        답변의 형식은 이름과 값의 쌍으로 구성된 딕셔너리 형태로 줘.
        예시를 줄게

        [
            {{
                "이름": "국민대학교",
                "평점": 4.5,
                "리뷰요약": "서울의 유명 대학교로, 넓은 캠퍼스와 다양한 산책로가 있어 산책하기에 좋습니다.",
                "거리": "약 1.1km",
                "이유": "넓은 캠퍼스와 자연환경",
                "주소": "서울특별시 성북구 정릉로 77",
                "place_id": "ChIJ77_K3R29fDURvJJ7pOnAfN4"
            }},
            {{
                "이름": "정릉종합사회복지관",
                "평점": 3.9,
                "리뷰요약": "커뮤니티 센터로, 복지관 주변에 산책로와 공원이 있어 산책하기 좋습니다.",
                "거리": "약 0.6km",
                "이유": "주변에 산책로와 공원",
                "주소": "서울특별시 성북구 솔샘로5길 92",
                "place_id": "ChIJzcA9deO8fDURrCFrBxkM1QY"
            }},
            {{
                "이름": "솔샘터널",
                "평점": 4.4,
                "리뷰요약": "주변에 자연경관이 아름다워 산책하기 좋은 장소입니다.",
                "거리": "약 1.4km",
                "이유": "아름다운 자연경관",
                "주소": "서울특별시 강북구 미아동",
                "place_id": "ChIJd08_k_e8fDURYeoKW3a58cE"
            }}
        ]
        이런식으로 주면돼 다른 양식은 안돼 무조건 이 양식으로 줘
        양식은 고정이야 명심해 , 절대 빠트리거나 다른 단어나 문장을 추가하지마
        '''

                
        summarized_info, place_ids, json_data= summarize_places_with_gpt(prompt, current_app.config)
        print(json_data)
        detailed_places = [get_place_details(place_id, current_app.config['GOOGLE_MAPS_API_KEY']) for place_id in place_ids]

        return jsonify({"places": detailed_places, "place_info": summarized_info, "model_output": summarized_info, "place_ids": place_ids})
    except Exception as e:
        return jsonify({"error": str(e)}), 500
