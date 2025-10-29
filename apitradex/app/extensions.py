from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from sqlalchemy import event

db = SQLAlchemy()

def init_extensions(app):
    CORS(app)

    db.init_app(app)

    # Activar llaves foráneas en SQLite
    with app.app_context():
        from sqlalchemy.engine import Engine
        @event.listens_for(Engine, "connect")
        def _set_sqlite_pragma(dbapi_connection, connection_record):
            try:
                cursor = dbapi_connection.cursor()
                cursor.execute("PRAGMA foreign_keys=ON")
                cursor.close()
            except Exception:
                pass
