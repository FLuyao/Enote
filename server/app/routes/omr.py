from flask import Blueprint, request, jsonify, send_file
import subprocess
import time 
from werkzeug.utils import secure_filename
import os


omr_bp = Blueprint('omr', __name__)


@omr_bp.route('/omr', methods = ['POST'])
def do_omr():
    """处理 MusicXML 文件上传"""
    if 'file' not in request.files:
        return jsonify({'error': '没有文件部分'}), 400

    file = request.files['file']

    if file.filename == '':
        return jsonify({'error': '未选择文件'}), 400
    if file: 
        # 处理文件
        time_flag = time.strftime(r"%Y%m%d%H%M%S")
        filename, ext = os.path.splitext(file.filename)
        new_filename = secure_filename(f"{filename}_{time_flag}{ext}")
        folder_path = "src/audiveris/omr_tmp" 
        os.makedirs(folder_path, exist_ok=True)
        file_path = os.path.join(folder_path, new_filename)
        file.save(file_path)

        command = ['src\\audiveris\\bin\\audiveris.bat', '@src/audiveris/cli.txt', f'src/audiveris/omr_tmp/{new_filename}']
        print("omr识别开始")
        process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

        stdout, stderr = process.communicate()

        process.wait()
        print("omr识别结束\n", stdout, stderr, "over")
        return ({"message": "omr识别成功"})
    return jsonify({'error': '文件格式不支持'}), 400


