# __init__.py
from flask import Flask
from flask_cors import CORS
from .extensions import init_extensions, db
from .routes import bp as api_bp
from .models import Rol

def create_app():
    app = Flask(__name__)
    app.config["SQLALCHEMY_DATABASE_URI"] = "sqlite:///logistica.db"
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

    # Inicializa extensiones (db, etc.)
    init_extensions(app)

    # CORS: permite front en localhost/127.0.0.1 (cubre Flutter web dev)
    CORS(
        app,
        resources={r"/api/*": {"origins": [
            "http://localhost:*",
            "http://127.0.0.1:*"
        ]}},
        supports_credentials=False,
        methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        allow_headers=["Content-Type", "Authorization"]
    )

    # Crear tablas + seed de roles
    with app.app_context():
        db.create_all()
        if Rol.query.count() == 0:
            db.session.add_all([
                Rol(nombre="Admin"),
                Rol(nombre="Cliente"),
                Rol(nombre="Conductor")
            ])
            db.session.commit()

    # Blueprint API
    app.register_blueprint(api_bp)

    @app.route("/")
    def alive():
        return "OK", 200

    return app
