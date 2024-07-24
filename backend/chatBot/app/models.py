from flask_login import UserMixin

class User(UserMixin):
    def __init__(self, id, username, password):
        self.id = id
        self.username = username
        self.password = password

# 임시 사용자 데이터베이스
users = {
    "user1": User(id="1", username="user1", password="password1"),
    "user2": User(id="2", username="user2", password="password2"),
}
