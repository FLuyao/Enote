from flask import Flask
from flask_socketio import SocketIO
from flask_pymongo import PyMongo
from .config import Config

mongo = PyMongo()
socketio = SocketIO(cors_allowed_origins="*")

def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)

    # 初始化 MongoDB
    mongo.init_app(app)

    # 初始化 SocketIO
    socketio.init_app(app)

    # 注册路由
    from .routes.auth import auth_bp
    from .routes.scores import scores_bp
    from .routes.omr import omr_bp
    app.register_blueprint(auth_bp)
    app.register_blueprint(scores_bp)
    app.register_blueprint(omr_bp)

    # 启动变更流监听
    from .change_stream import start_change_stream_listener
    app.before_first_request_funcs.append(start_change_stream_listener)

    return app
