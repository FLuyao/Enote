from flask import Blueprint, request, jsonify
from bson.objectid import ObjectId
from gridfs import GridFS
from datetime import datetime
from .. import mongo, socketio
from ..change_stream import send_change_to_client
import base64

scores_bp = Blueprint('scores', __name__)

# 同步曲谱数据
@scores_bp.route('/scores/sync', methods=['POST'])
def sync_score():
    client_files = request.files  # 获取客户端上传的所有文件
    fs = GridFS(mongo.db)  # 初始化 GridFS

    # 获取 JSON 数据中的元数据
    scores_metadata = request.json.get('scores', [])

    # 创建一个字典来存储元数据，以便快速查找
    metadata_dict = {metadata['scoreId']: metadata for metadata in scores_metadata}

    for score_id, file in client_files.items():
        # 获取文件名作为元数据的一部分
        filename = file.filename

        # 获取 JSON 数据中的元数据
        metadata = metadata_dict.get(score_id)

        if not metadata:
            return jsonify({'message': f'元数据未提供或不匹配文件 {score_id}'}), 400

        # 提取元数据字段
        creat_time = metadata.get('createTime')
        modify_time = metadata.get('modifyTime')
        device_id = metadata.get('deviceId')
        composer = metadata.get('composer')
        collection_id = metadata.get('collectionId')
        collection_name = metadata.get('collectionName')
        order_no = metadata.get('orderNo')

        # 构建客户端曲谱数据
        client_score = {
            'scoreId': score_id,
            'fileId': None,
            'name': filename,
            'createTime': creat_time,
            'accessTime': modify_time,
            'deviceId': device_id,
            'composer': composer,
            'collectionId': collection_id,
            'collectionName': collection_name,
            'orderNo': order_no,
        }


        # 构建客户端曲谱数据
        client_score = {
            'scoreId': score_id,
            'fileId': None,
            'name': filename,
            'createTime': creat_time,
            'accessTime': modify_time,
            'deviceId': device_id,
            'composer': composer,
            'collectionId': collection_id,
            'collectionName': collection_name,
            'orderNo': order_no,
        }

        # 获取服务端的曲谱数据
        server_score = mongo.db.scores.find_one({'_id': ObjectId(score_id)})
        if server_score:
            # 比较设备ID
            if server_score['lastDeviceId'] == client_score['lastDeviceId']:
                # 同一设备，更新云端数据
                result = mongo.db.scores.update_one(
                    {'_id': ObjectId(score_id)},
                    {'$set': client_score}
                )
                # 存储文件到 GridFS
                file_id = fs.put(file, filename=filename)
                client_score['fileId'] = file_id  # 更新文件ID
                # 通知客户端曲谱已更新
                send_change_to_client({
                    '_id': ObjectId(score_id),
                    'operationType': 'update',
                    'fullDocument': client_score
                })
                return jsonify({'message': '曲谱已同步'}), 200
            else:
                # 不同设备，询问用户要保留哪一版本
                return jsonify({
                    'message': '版本冲突',
                    'serverScore': server_score,
                    'clientScore': client_score,
                    'options': ['保留云端版本', '保留本地版本']
                }), 409
        else:
            # 如果服务端没有该曲谱，则新增
            file_id = fs.put(file, filename=filename)
            client_score['fileId'] = file_id  # 更新文件ID
            result = mongo.db.scores.insert_one(client_score)
            if result.inserted_id:
                # 通知客户端曲谱已新增
                send_change_to_client({
                    '_id': result.inserted_id,
                    'operationType': 'insert',
                    'fullDocument': client_score
                })
                return jsonify({'message': '曲谱已作为新条目同步'}), 201

    return jsonify({'message': '同步已完成'}), 200

# 处理用户选择
@scores_bp.route('/scores/resolve_conflict', methods=['POST'])
def resolve_conflict():
    data = request.json
    score_id = data.get('scoreId')
    resolution = data.get('resolution')  # 用户的选择：'保留云端版本' 或 '保留本地版本'

    fs = GridFS(mongo.db)

    if resolution == '保留云端版本':
        # 保留云端版本
        server_score = mongo.db.scores.find_one({'_id': ObjectId(score_id)})

        # 获取云端文件
        server_file = fs.get(ObjectId(server_score['fileId']))
        server_file_data = server_file.read()

        # 发送云端文件和元数据给客户端，将二进制文件编码为 Base64 字符串
        return jsonify({
            'message': '云端版本',
            'score': server_score,
            'fileData': base64.b64encode(server_file_data).decode('utf-8') if server_file.content_type == 'application/vnd.recordare.musicxml+xml' else server_file_data
        }), 200
    elif resolution == '保留本地版本':
        # 保留本地版本
        client_score = data.get('clientScore')

        if not client_score:
            return jsonify({'message': '客户端曲谱数据未提供'}), 400

        # 获取客户端文件
        file = request.files.get(score_id)

        if not file:
            return jsonify({'message': '客户端文件未提供'}), 400

        # 存储文件到 GridFS
        file_id = fs.put(file, filename=file.filename)
        client_score['fileId'] = file_id  # 更新文件ID

        # 更新或插入服务端数据
        result = mongo.db.scores.update_one(
            {'_id': ObjectId(score_id)},
            {'$set': client_score},
        )
        if result.modified_count > 0:
            # 通知客户端曲谱已更新
            send_change_to_client({
                '_id': ObjectId(score_id),
                'operationType': 'update',
                'fullDocument': client_score
            })
            return jsonify({'message': '保留客户端曲谱成功，已同步到云端'}), 200
        else:
            return jsonify({'message': '更新曲谱失败'}), 500

    return jsonify({'message': '无效的解析选项'}), 400

# 删除曲谱数据
@scores_bp.route('/scores/delete', methods=['POST'])
def delete_score():
    data = request.json
    score_id = data.get('scoreId')

    if not score_id:
        return jsonify({'message': '曲谱ID未提供'}), 400

    fs = GridFS(mongo.db)

    # 获取服务端的曲谱数据
    server_score = mongo.db.scores.find_one({'_id': ObjectId(score_id)})
    if server_score:
        # 删除文件从 GridFS
        fs.delete(ObjectId(server_score['fileId']))

        # 删除记录从 MongoDB
        result = mongo.db.scores.delete_one({'_id': ObjectId(score_id)})
        if result.deleted_count > 0:
            # 通知客户端曲谱已删除
            send_change_to_client({
                '_id': ObjectId(score_id),
                'operationType': 'delete'
            })
            return jsonify({'message': '曲谱已删除'}), 200
        else:
            return jsonify({'message': '删除曲谱失败'}), 500
    else:
        return jsonify({'message': '曲谱不存在'}), 404

