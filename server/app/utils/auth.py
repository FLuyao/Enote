from datetime import datetime, timedelta
import jwt
from flask import current_app

# 生成token
def generate_token(username):
    payload = {
        'username': username,
    }
    secret_key = current_app.config['JWT_SECRET_KEY']
    token = jwt.encode(payload, secret_key, algorithm='HS256')
    return token
# 解析token
def decode_token(token):
    try:
        secret_key = current_app.config['JWT_SECRET_KEY']
        payload = jwt.decode(token, secret_key, algorithms=['HS256'])
        return payload
    except jwt.InvalidTokenError:
        return {'error': '当前令牌无效'}
