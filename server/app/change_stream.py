from flask_socketio import emit
from bson.json_util import dumps
from . import mongo, socketio
import threading
import logging

# 设置日志记录
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# 设置变更流
try:
    change_stream = mongo.db.scores.watch()
    logger.info("变更流已成功初始化")
except Exception as e:
    logger.error(f"初始化变更流时出错: {e}")
    raise

def send_change_to_client(change):
    try:
        # 将变更信息转换为 JSON 字符串
        change_json = dumps(change)
        # 使用 emit 方法发送变更信息给所有连接的客户端
        emit('score_change', change_json, broadcast=True)
        logger.info("变更信息已成功发送给客户端")
    except Exception as e:
        logger.error(f"发送变更信息时出错: {e}")

def start_change_stream_listener():
    @socketio.on('connect')
    def handle_connect():
        logger.info("客户端连接成功")

    @socketio.on('disconnect')
    def handle_disconnect():
        logger.info("客户端断开连接")

    def listen_to_changes():
        try:
            for change in change_stream:
                send_change_to_client(change)
        except Exception as e:
            logger.error(f"监听变更流时出错: {e}")
            # 重新初始化变更流
            try:
                change_stream.close()
                change_stream = mongo.db.scores.watch()
                logger.info("变更流已重新初始化")
            except Exception as e:
                logger.error(f"重新初始化变更流时出错: {e}")

    # 启动一个单独的线程来监听变更流
    listener_thread = threading.Thread(target=listen_to_changes)
    listener_thread.daemon = True  # 设置为守护线程
    listener_thread.start()
    logger.info("变更流监听器已启动")

