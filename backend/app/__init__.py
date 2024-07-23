from flask import Flask
from flask_sqlalchemy import SQLAlchemy

def create_app():
    app = Flask(__name__)

    # 여기에 설정이나 초기화를 추가할 수 있습니다.
    app.config['SECRET_KEY'] = 'your_secret_key'

    from .routes import main as main_blueprint
    app.register_blueprint(main_blueprint)

    return app
