"""
Configuración de fixtures de pytest para testing
"""
import pytest
from app import create_app
from app.extensions import db
from app.models import Rol, Usuario, Vehiculo, Ruta


@pytest.fixture(scope='function')
def app():
    """Crea instancia de aplicación para tests"""
    import os
    # Forzar SQLite en memoria para tests
    os.environ['DATABASE_URL'] = 'sqlite:///:memory:'
    
    from app import create_app as _create_app
    app = _create_app()
    
    app.config.update({
        'TESTING': True,
        'SQLALCHEMY_DATABASE_URI': 'sqlite:///:memory:',
        'WTF_CSRF_ENABLED': False,
        'SERVER_NAME': 'localhost:5000',
    })
    
    with app.app_context():
        db.create_all()
        
        # Verificar si ya existen roles antes de crearlos
        if Rol.query.count() == 0:
            roles = [
                Rol(nombre='Administrador'),
                Rol(nombre='Cliente'),
                Rol(nombre='Conductor')
            ]
            for rol in roles:
                db.session.add(rol)
            db.session.commit()
        
        yield app
        
        # Limpiar todo
        db.session.remove()
        db.drop_all()


@pytest.fixture
def client(app):
    """Cliente de pruebas HTTP"""
    return app.test_client()


@pytest.fixture
def runner(app):
    """CLI runner para comandos"""
    return app.test_cli_runner()


@pytest.fixture
def usuario_admin(app):
    """Fixture de usuario administrador"""
    from werkzeug.security import generate_password_hash
    
    with app.app_context():
        rol = Rol.query.filter_by(nombre='Administrador').first()
        if not rol:
            rol = Rol(nombre='Administrador')
            db.session.add(rol)
            db.session.commit()
            db.session.refresh(rol)
        
        usuario = Usuario(
            email='admin@tradex.com',
            password_hash=generate_password_hash('admin123'),
            nombre_completo='Admin Test',
            role_id=rol.id
        )
        db.session.add(usuario)
        db.session.commit()
        
        # Refresh para evitar DetachedInstanceError
        db.session.refresh(usuario)
        yield usuario
        
        # Cleanup
        db.session.delete(usuario)
        db.session.commit()


@pytest.fixture
def usuario_cliente(app):
    """Fixture de usuario cliente"""
    from werkzeug.security import generate_password_hash
    
    with app.app_context():
        rol = Rol.query.filter_by(nombre='Cliente').first()
        if not rol:
            rol = Rol(nombre='Cliente')
            db.session.add(rol)
            db.session.commit()
            db.session.refresh(rol)
        
        usuario = Usuario(
            email='cliente@example.com',
            password_hash=generate_password_hash('pass123'),
            nombre_completo='Cliente Test',
            role_id=rol.id,
            telefono='3001234567'
        )
        db.session.add(usuario)
        db.session.commit()
        
        db.session.refresh(usuario)
        yield usuario
        
        # Cleanup
        db.session.delete(usuario)
        db.session.commit()
