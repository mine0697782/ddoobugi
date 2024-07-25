from flask import jsonify

def get_bearer_token(auth_header):
    if auth_header is None:
        return jsonify({"message": "Missing Authorization Header"}), 401

    parts = auth_header.split()
    if parts[0].lower() != 'bearer':
        return jsonify({"message": "Authorization header must start with Bearer"}), 401
    elif len(parts) == 1:
        return jsonify({"message": "Token not found"}), 401
    elif len(parts) > 2:
        return jsonify({"message": "Authorization header must be Bearer token"}), 401

    token = parts[1]
    return token


def make_prompt(user_input, lat, lon, nearby_places):
    return f'''
        사용자의 입력: {user_input}

        사용자의 좌표는 ({lat}, {lon})입니다. 주어진 장소 정보는 {nearby_places}입니다. 
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