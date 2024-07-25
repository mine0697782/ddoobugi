from flask import Blueprint, render_template, abort, current_app, jsonify, request, url_for, redirect
from flask_login import LoginManager, login_user
from jinja2 import TemplateNotFound
from werkzeug.utils import safe_join
from pymongo import MongoClient
import jwt
import datetime
import hashlib
from .services import search_nearby_places, get_place_details, summarize_places_with_gpt

import os

exclude_place_ids = []

main = Blueprint('main', __name__)

uri = "mongodb://localhost:27017/"
client = MongoClient(uri)
db = client["ddoobugi"]
db_user = db["User"]
SECRET_KEY = os.getenv("SECRET_KEY")

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
    token = request.json["token"]
    user_info = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
    user = db_user.find_one({"email": user_info["email"]})
    print(type(user))
    print(user)
    return "chat"

# @main.route('/name')
# def api_valid():
#     # token_receive = request.cookies.get("mytoken")
#     try :
#         token_receive = request.json["token"]
#         print("header: ", request.headers)
#         print("toekn : ", token_receive)
#     except KeyError:
#         print("token is not exist")
#         return "token is not exist"
#     except Exception as e:
#         print("error : ", e)
#         return ("error : ", e)
        

    # try:
    #     payload = jwt.decode(token_receive, SECRET_KEY, algorithms=["HS256"])
    #     print(payload)

    #     userinfo = db_user.find_one({"email": payload["email"]})
    #     return jsonify({"result" : "success", "name" : userinfo["name"]})
    # except jwt.ExpiredSignatureError:
    #     return jsonify({"result" : "fail", "msg" : "login expired"})
    # except jwt.exceptions.DecodeError:
    #     return jsonify({"result" : "fail", "msg" : "login info is not valid"})


# @main.route('/users')
# def get_users():
#     users = db_user.find({})
#     res = []
#     for u in users:
#         res.append(u["name"])
#         print(u)
#     return jsonify({"result" : res})