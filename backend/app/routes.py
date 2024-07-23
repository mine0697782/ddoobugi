from flask import Blueprint, render_template, abort, current_app
from jinja2 import TemplateNotFound
from werkzeug.utils import safe_join
import os

main = Blueprint('main', __name__)

@main.route('/')
def index():
    return "Hello, World!"

@main.route('/<page>')
def show(page):
    try:
        # 안전하게 경로를 결합
        template_path = os.path.join('pages', f'{page}.html')
        # print(template_path)

        full_template_path = os.path.join(current_app.root_path, 'templates', template_path)
        # print(f"Looking for template at: {full_template_path}")

        # 템플릿 경로가 존재하는지 확인
        if not os.path.isfile(full_template_path):
            # print(f"Template not found: {full_template_path}")
            abort(404)
        # print('return')
        return render_template(template_path)
    except TemplateNotFound:
        # print('not found')
        abort(404)