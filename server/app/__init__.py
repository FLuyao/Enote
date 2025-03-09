from flask import Flask
from flask_pymongo import PyMongo
from .config import Config

mongo = PyMongo()

def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)

    # 初始化 MongoDB
    mongo.init_app(app)

    # 注册路由
    from .routes.auth import auth_bp
    from .routes.scores import scores_bp
    app.register_blueprint(auth_bp)
    app.register_blueprint(scores_bp)

    return app