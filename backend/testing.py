from flask import Flask, render_template, request, jsonify
import os
import re
import requests
from dotenv import load_dotenv
from langchain_openai import AzureChatOpenAI
from langchain_core.messages import HumanMessage, SystemMessage

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
    query = request.json.get("query")
    result = search_place(query)
    if result and "results" in result:
        return jsonify(results=result["results"])
    else:
        return jsonify(results=[])

if __name__ == '__main__':
    app.run(debug=True)
