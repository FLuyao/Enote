from flask import Blueprint, request, jsonify
from bson.objectid import ObjectId
from gridfs import GridFS
from .. import mongo
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

    responses = []

    for score_id, file in client_files.items():
        # 获取文件名作为元数据的一部分
        filename = file.filename

        # 获取 JSON 数据中的元数据
        metadata = metadata_dict.get(score_id)

        if not metadata:
            responses.append({'message': f'元数据未提供或不匹配文件 {score_id}', 'scoreId': score_id, 'status': 400})
            continue

        # 提取元数据字段
        score_id = metadata.get('scoreId')  
        user_id = metadata.get('Userid')
        title = metadata.get('Title')
        creat_time = metadata.get('Create_time')
        modify_time = metadata.get('Modify_time')
        mxl_path = metadata.get('MxlPath')
        image = metadata.get('Image')

        # 构建客户端曲谱数据
        client_score = {
            'scoreId': score_id,
            'fileId': None,
            'userId': user_id,
            'title': title,
            'createTime': creat_time,
            'modifyTime': modify_time,
            'mxl_path': mxl_path,
            'image': image,
        }

        # 获取服务端的曲谱数据
        server_score = mongo.db.scores.find_one({'scoreId': score_id})  # 使用 scoreId 查询
        if server_score:
            # 比较修改时间
            if client_score['modifyTime'] > server_score['modifyTime']:
                # 客户端版本更新，更新云端数据
                result = mongo.db.scores.update_one(
                    {'scoreId': score_id},  # 使用 scoreId 更新
                    {'$set': client_score}
                )
                # 存储文件到 GridFS
                file_id = fs.put(file, filename=filename)
                client_score['fileId'] = file_id  # 更新文件ID
                responses.append({'message': '曲谱已同步', 'scoreId': score_id, 'status': 200})
            elif client_score['modifyTime'] < server_score['modifyTime']:
                # 服务端版本较新，覆盖客户端数据
                # 获取文件数据
                file_data = fs.get(ObjectId(server_score['fileId'])).read()
                # 将文件数据编码为 Base64
                file_data_base64 = base64.b64encode(file_data).decode('utf-8')
                # 返回文件和元数据
                responses.append({
                    'message': '服务端版本较新，须覆盖客户端',
                    'serverScore': server_score,
                    'fileData': file_data_base64,
                    'scoreId': score_id,
                    'status': 200
                })
            else:
                # 修改时间相同，不需要更新
                responses.append({'message': '曲谱已同步，无更改', 'scoreId': score_id, 'status': 200})
        else:
            # 如果服务端没有该曲谱，则新增
            file_id = fs.put(file, filename=filename)
            client_score['fileId'] = file_id  # 更新文件ID
            result = mongo.db.scores.insert_one(client_score)
            if result.inserted_id:
                responses.append({'message': '曲谱已作为新条目同步', 'scoreId': score_id, 'status': 201})
            else:
                responses.append({'message': '插入曲谱失败', 'scoreId': score_id, 'status': 500})

    # 检查是否有任何错误
    for response in responses:
        if response['status'] not in [200, 201]:
            response['status'] = 500  # 统一错误状态码

    return jsonify({'responses': responses}), 200

# 删除曲谱数据
@scores_bp.route('/scores/delete', methods=['POST'])
def delete_score():
    data = request.json
    score_id = data.get('scoreId')

    if not score_id:
        return jsonify({'message': '曲谱ID未提供'}), 400

    fs = GridFS(mongo.db)

    # 获取服务端的曲谱数据
    server_score = mongo.db.scores.find_one({'scoreId': score_id})  # 使用 scoreId 查询
    if server_score:
        # 删除文件从 GridFS
        fs.delete(ObjectId(server_score['fileId']))

        # 删除记录从 MongoDB
        result = mongo.db.scores.delete_one({'scoreId': score_id})  # 使用 scoreId 删除
        if result.deleted_count > 0:
            return jsonify({'message': '曲谱已删除', 'scoreId': score_id}), 200
        else:
            return jsonify({'message': '删除曲谱失败', 'scoreId': score_id}), 500
    else:
        return jsonify({'message': '曲谱不存在', 'scoreId': score_id}), 404
