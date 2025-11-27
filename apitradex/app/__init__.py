# __init__.py
import os
from flask import Flask
from flask_cors import CORS
from dotenv import load_dotenv
from .extensions import init_extensions, db
from .routes import bp as api_bp
from .models import Rol

# Cargar variables de entorno
load_dotenv()

def create_app():
    app = Flask(__name__)

    # -------------------------------
    # CONFIGURACIÓN DESDE VARIABLES DE ENTORNO
    # -------------------------------
    app.config["SQLALCHEMY_DATABASE_URI"] = os.getenv(
        "DATABASE_URL",
        "mysql+pymysql://root:041124@localhost:3306/tradex2"  # Fallback para desarrollo
    )
    app.config["SECRET_KEY"] = os.getenv("SECRET_KEY", "dev-secret-key-change-in-production")
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

    # Inicializa extensiones (db, etc.)
    init_extensions(app)

    # CORS desde variable de entorno
    cors_origins = os.getenv("CORS_ORIGINS", "http://localhost:*,http://127.0.0.1:*").split(",")
    CORS(
        app,
        resources={r"/api/*": {"origins": cors_origins}},
        supports_credentials=False,
        methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        allow_headers=["Content-Type", "Authorization"]
    )

    # Crear tablas + seed de roles (no rompe nada aunque ya creaste la BD con script)
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
