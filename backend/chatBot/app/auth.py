from flask import Blueprint, render_template, redirect, url_for, request, flash
from flask_login import login_user, logout_user, login_required
from .models import users
from . import login_manager

auth = Blueprint('auth', __name__)

@login_manager.user_loader
def load_user(user_id):
    return next((user for user in users.values() if user.id == user_id), None)

@auth.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        user = users.get(username)

        if user and user.password == password:
            login_user(user)
            return redirect(url_for('main.index'))
        else:
            flash('Invalid username or password')
    
    return render_template('login.html')

@auth.route('/logout')
@login_required
def logout():
    logout_user()
    return redirect(url_for('auth.login'))
