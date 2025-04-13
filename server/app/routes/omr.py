from flask import Blueprint, request, jsonify, send_file
import subprocess
import time 
from werkzeug.utils import secure_filename
import os


omr_bp = Blueprint('omr', __name__)


@omr_bp.route('/omr', methods=['POST'])
def do_omr():
    if 'file' not in request.files:
        return jsonify({'error': '没有文件部分'}), 400

    file = request.files['file']

    if file.filename == '':
        return jsonify({'error': '未选择文件'}), 400

    if file:
        # 1. 保存上传的文件
        time_flag = time.strftime(r"%Y%m%d%H%M%S")
        filename, ext = os.path.splitext(file.filename)
        new_filename = secure_filename(f"{filename}_{time_flag}{ext}")
        folder_path = "src/audiveris/omr_tmp"
        os.makedirs(folder_path, exist_ok=True)
        file_path = os.path.join(folder_path, new_filename)
        file.save(file_path)
        env = os.environ.copy()
        env['TESSDATA_PREFIX'] = 'src\\audiveris\\tessdata'

        # 2. 调用 audiveris 命令行进行 OMR
        command = [
            'src\\audiveris\\bin\\audiveris.bat',
            '@src/audiveris/cli.txt',
            f'src/audiveris/omr_tmp/{new_filename}'
        ]
        print("omr识别开始")
        process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, env=env)
        stdout, stderr = process.communicate()
        process.wait()
        print("omr识别结束\n", stdout, stderr, "over")

        # 3. 假设 audiveris 会在同路径下生成 .mxl 文件
        #    例如把 .ext(可能是png/jpg/pdf) 替换为 .mxl
        base_name = os.path.splitext(new_filename)[0]
        print(base_name)  # filename_时间戳
        BASE_DIR = os.path.dirname(os.path.abspath(__file__))  # app/routes
        SERVER_DIR = os.path.abspath(os.path.join(BASE_DIR, "..", ".."))  # 回到 server/
        mxl_file_path = os.path.join(SERVER_DIR, "src", "audiveris", "output", f"{base_name}.mxl")
        print(mxl_file_path)

        if os.path.exists(mxl_file_path):
            # 4. 把 MXL 文件作为附件发回给客户端
            return send_file(
                mxl_file_path,
                mimetype="application/vnd.recordare.musicxml",
                as_attachment=True,
                download_name=f"{base_name.split("_")[0]}.mxl"  # 下载时客户端看到的文件名
            )
        else:
            return jsonify({"error": "MXL 文件未生成"}), 500

    return jsonify({'error': '文件格式不支持'}), 400

