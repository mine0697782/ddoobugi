import os
import re
import requests
from flask import Flask, render_template, request, jsonify
from dotenv import load_dotenv
from langchain_openai import AzureChatOpenAI
from langchain_core.messages import HumanMessage, SystemMessage

# 환경 변수 로드
load_dotenv()

# Flask 앱 설정
app = Flask(__name__)

# Azure OpenAI 설정
model_name = os.getenv("AZURE_OPENAI_DEPLOYMENT")
api_key = os.getenv("AZURE_OPENAI_API_KEY")
endpoint = os.getenv("AZURE_OPENAI_ENDPOINT")
api_version = os.getenv("AZURE_OPENAI_API_VERSION")

# Google Maps API 설정
google_maps_api_key = os.getenv("GOOGLE_MAPS_API_KEY")

def extract_location(text):
    # 텍스트에서 위치 추출 (예시: 서울, 부산 등)
    expression = r"Location:(.+)"
    match = re.search(expression, text)
    if match:
        location = match.group(1).strip()
        return location
    return None

def get_coordinates(location):
    url = "https://maps.googleapis.com/maps/api/geocode/json"
    params = {
        "address": location,
        "key": google_maps_api_key
    }
    response = requests.get(url, params=params)
    if response.status_code == 200:
        data = response.json()
        if data['results']:
            location_data = data['results'][0]['geometry']['location']
            return location_data['lat'], location_data['lng']
    return None, None

@app.route('/')
def index():
    return render_template('index.html', api_key=google_maps_api_key)

@app.route('/chat', methods=['POST'])
def chat():
    data = request.json
    user_input = data.get("input_text")

    try:
        chat = AzureChatOpenAI(
            azure_deployment=model_name,
            openai_api_key=api_key,
            api_version=api_version,
            temperature=0
        )

        # ChatGPT에게 질문에 대한 답변을 요청
        resp = chat.invoke([
            SystemMessage(content="You are a helpful assistant."),
            HumanMessage(content=user_input)
        ])
        answer = resp.content
        location = extract_location(answer)

        lat, lng = None, None
        if location:
            lat, lng = get_coordinates(location)

        return jsonify({"answer": answer, "location": location, "lat": lat, "lng": lng})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)
