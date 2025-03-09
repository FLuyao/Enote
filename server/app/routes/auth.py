from flask import Blueprint, request, jsonify
from bson.objectid import ObjectId
from datetime import datetime
import jwt
import bcrypt
from ..utils.auth import generate_token
from .. import mongo

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/register', methods=['POST'])
def register():
    data = request.json
    username = data.get('username')
    password = data.get('password')

    if not username or not password:
        return jsonify({'message': '昵称和密码为必填项'}), 400
    
    if mongo.db.users.find_one({'username': username}):
        return jsonify({'message': '用户已存在'}), 400
    
    # 加密密码
    hashed_password = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())

    # 创建用户文档
    user = {
        'username': username,
        'password': hashed_password,
        'last_login': None,
        'sync_enabled': False
    }
    user_id = mongo.db.users.insert_one(user).inserted_id
    return jsonify({'message': '注册成功', 'userId': str(user_id)}), 201

@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.json
    username = data.get('username')
    password = data.get('password')
    sync_enabled = data.get('sync_enabled', False)

    user = mongo.db.users.find_one({'username': username})
    if not user:
        return jsonify({'message': '用户不存在'}), 404

    # 验证密码
    if not bcrypt.checkpw(password.encode('utf-8'), user['password']):
        return jsonify({'message': '密码错误'}), 401

    # 更新用户登录时间
    mongo.db.users.update_one(
        {'_id': ObjectId(user['_id'])},
        {'$set': {'last_login': datetime.now(), 'sync_enabled': sync_enabled}})

    # 生成 JWT 令牌
    token = generate_token(username)
    return jsonify({'token': token}), 200