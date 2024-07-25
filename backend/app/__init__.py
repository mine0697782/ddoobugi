from flask import Flask
import os
from config import Config

def create_app():
    app = Flask(__name__)
    app.secret_key = os.getenv("SECRET_KEY")
    app.config.from_object(Config)

    from .routes import main as main_blueprint
    app.register_blueprint(main_blueprint)

    return app
