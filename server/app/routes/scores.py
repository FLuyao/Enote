from flask import Blueprint, request, jsonify
from flask_pymongo import PyMongo
from bson.objectid import ObjectId
from gridfs import GridFS
from datetime import datetime

scores_bp = Blueprint('scores', __name__)

@scores_bp.route('/scores', methods=['POST'])
def upload_score():
    title = request.form.get('title')
    composer = request.form.get('composer')
    file = request.files['file']

    if not title or not file:
        return jsonify({'message': 'Title and file are required'}), 400

    # 存储文件到 GridFS
    fs = GridFS(PyMongo().db)
    file_id = fs.put(file, filename=file.filename)

    # 存储元数据
    score = {
        'title': title,
        'composer': composer,
        'fileId': file_id,
        'createdAt': datetime.now()
    }
    score_id = PyMongo().db.scores.insert_one(score).inserted_id

    return jsonify({'message': 'Score uploaded', 'scoreId': str(score_id)}), 201

@scores_bp.route('/scores/<file_id>', methods=['GET'])
def download_score(file_id):
    fs = GridFS(PyMongo().db)
    file = fs.get(ObjectId(file_id))
    return file.read(), 200, {'Content-Type': 'application/xml'}