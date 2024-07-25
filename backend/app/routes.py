from flask import Blueprint, render_template, abort, current_app, jsonify, request, url_for, redirect
from flask_login import LoginManager, login_user
from jinja2 import TemplateNotFound
from werkzeug.utils import safe_join
from pymongo import MongoClient
import jwt
import datetime
import hashlib
from .services import search_nearby_places, get_place_details, summarize_places_with_gpt
from .utils import *
import os
import datetime
from bson import ObjectId

exclude_place_ids = []

main = Blueprint('main', __name__)

uri = "mongodb://localhost:27017/"
client = MongoClient(uri)
db = client["ddoobugi"]
db_route = db["Route"]
db_user = db["User"]
SECRET_KEY = os.getenv("SECRET_KEY")

def decode_token(token):
    user_info = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
    user = db_user.find_one({"email": user_info["email"]})
    return user

@main.route('/')
def index():
    return "<h1>Hello, World!</h1>"

@main.post('/register')
def register():
    email = request.json["email"]
    password = request.json["password"]
    name = request.json["name"]
    pw_hash = hashlib.sha256(password.encode('utf-8')).hexdigest()

    is_exist = db_user.find_one({"email": email})
    if (is_exist):
        return jsonify({"result" : "email already exist"})
    else:
        db_user.insert_one({"email": email, "password": pw_hash, "name": name})
        return jsonify({"result": "success"})


@main.post('/login')
def login():
    print("/login")

    print("request json : ",end="")
    print(request.get_json())
    print("request data : ", end="")
    print(request.get_data())
    print("request form : ", request.form)
    print("request args : ", request.args)

    email = request.json["email"]
    password = request.json["password"]
    pw_hash = hashlib.sha256(password.encode('utf-8')).hexdigest()

    user = db_user.find_one({"email": email})
    if not user:
        return 'user not exist'
    if user["password"] == pw_hash:
        payload = {
            "email" : email,
            "exp" : datetime.datetime.now() + datetime.timedelta(14)
        }
        token = jwt.encode(payload, SECRET_KEY, algorithm='HS256')#.decode('utf-8')

        return jsonify({"result" : "success", "token" : token})
    else :
        return jsonify({"result" : "fail", "msg" : "password incorrect!"})

@main.route('/chat')
def chat():
    try:
        token = request.json["token"]
        user = decode_token(token)
        print(type(user))
        print(user)
        return "chat"
    except Exception as e:
        return e

@main.route('/chat/search', methods=['POST'])
def search():
    print("/chat/search")
    global exclude_place_ids
    auth_header = request.headers.get('Authorization', None)
    # print("auth header : ", auth_header)
    data = request.json
    # 토큰을 json으로 받을 경우
    # token = data["token"]
    user_input = data["chat"]
    lat = data["lat"]
    lon = data["lon"]
    rid = data["rid"]
    addr = data["address"]
    
    result = get_bearer_token(auth_header)
    user = decode_token(result)
    # print("user : ", user)
    # print("result : ", result)

    # 루트 처음 시작 시 rid 없음 / 새 루트 생성
    if (rid == "" or rid == None): 
        print("새 루트 생성")
        now_utc = datetime.now(timezone.utc)
        new_route = {
            "uid" : str(user["_id"]),
            "name" : "new route",
            "created_date" : now_utc,
            "updated_date" : now_utc,
            "address" : addr,
            "image" : "",
            "waypoints" : [

            ],
            "chat_history" : {
                "user_chat" : [

                ],
                "ai_chat" : [

                ]
            }
        }
        try : # rid가 없을 시 새 루트 생성 / 채팅 저장 / 아이디 받아오기
            result = db_route.insert_one(new_route)
            rid = str(result.inserted_id)
            print("새 루트 id : ", rid)
            object_rid = ObjectId(str(rid))
            updated = db_route.find_one_and_update(
                {"_id" : object_rid},
                {"$push" : {"chat_history.user_chat" : user_input}}
                )
        except Exception as e:
            print("==== error section 1 ====")
            return e
    # 이미 존재하는 루트일시 유저 채팅 저장
    else : 
        try:
            print("rid : ", rid)
            object_rid = ObjectId(str(rid))
            updated = db_route.find_one_and_update(
                {"_id" : object_rid},
                {"$push" : {"chat_history.user_chat" : user_input}}
                )
            # print(updated)
        except Exception as e:
            print("==== error section 2 ====")
            return e

    object_rid = ObjectId(str(rid))
    updated = db_route.find_one({"_id": object_rid})

    # received_exclude_place_ids = data["visited"]
    received_exclude_place_ids = []
    for p in updated["waypoints"]:
        received_exclude_place_ids.append(p)
    print("exclude : ", received_exclude_place_ids)

    exclude_place_ids.extend(received_exclude_place_ids)

    google_maps_api_key = os.getenv('GOOGLE_MAPS_API_KEY')

    try:
        nearby_places = search_nearby_places(lat, lon, google_maps_api_key)
        if not nearby_places:
            print("==== error section 3 ====")
            return jsonify({"error": "No nearby places found."}), 404
        
        nearby_places = [place for place in nearby_places if place['place_id'] not in exclude_place_ids]

        prompt = make_prompt(user_input, lat, lon, nearby_places)
                
        summarized_info, place_ids, json_data= summarize_places_with_gpt(prompt)
        print("received json : ", json_data)
        detailed_places = [get_place_details(place_id, os.getenv('GOOGLE_MAPS_API_KEY')) for place_id in place_ids]
        
        # return jsonify({"places": detailed_places, "place_info": summarized_info, "model_output": summarized_info, "place_ids": place_ids})
        updated = db_route.find_one_and_update(
                {"_id" : object_rid},
                {"$push" : {"chat_history.ai_chat" : {"places" : json_data}}}
                )
        return jsonify({
            "rid" : rid, 
            "places" : json_data
        })
    
    except Exception as e:
        print("==== error section 4 ====")
        return jsonify({"error": e}), 500


@main.post("/chat/select")
def select():
    print("/chat/select")
    auth_header = request.headers.get('Authorization', None)
    try :
        rid = request.json["rid"]
        pid = request.json["pid"]
        print("rid : ", rid)
        print("pid : ", pid)
        # user = decode_token(get_bearer_token(auth_header))
        route = db_route.find_one({"_id" : ObjectId(str(rid))})
        print(route)
    except Exception as e:
        return {"result" : "fail", "msg" : "invalid token"}

    # route["_id"] = type(route["_id"])
    print("===============")
    return (jsonify({"result" : "success"}))

@main.route("/token")
def token():
    received = request.headers["Authorization"]
    print(received)

    return ("you sent me token : "+ received)
