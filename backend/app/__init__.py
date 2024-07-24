from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from dotenv import load_dotenv
import os

def create_app():
    app = Flask(__name__)
    app.secret_key = os.getenv("SECRET_KEY")

    from .routes import main as main_blueprint
    app.register_blueprint(main_blueprint)

    return app
