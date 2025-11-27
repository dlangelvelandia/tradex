"""
Tests para autenticación y login
"""
import pytest
from werkzeug.security import check_password_hash


class TestAutenticacion:
    """Suite de tests para login y seguridad"""
    
    def test_login_exitoso(self, client, usuario_admin):
        """Test: Login con credenciales correctas"""
        response = client.post('/api/login', json={
            'email': 'admin@tradex.com',
            'password': 'admin123'
        })
        
        assert response.status_code == 200
        data = response.get_json()
        assert 'id' in data
        assert 'nombre_completo' in data
        assert 'rol' in data
        assert data['email'] == 'admin@tradex.com'
    
    def test_login_password_incorrecta(self, client, usuario_admin):
        """Test: Login con password incorrecta"""
        response = client.post('/api/login', json={
            'email': 'admin@tradex.com',
            'password': 'password_incorrecta'
        })
        
        assert response.status_code == 401
        data = response.get_json()
        assert 'credenciales' in data['error'].lower()
    
    def test_login_usuario_inexistente(self, client):
        """Test: Login con email no registrado"""
        response = client.post('/api/login', json={
            'email': 'noexiste@example.com',
            'password': 'cualquier_password'
        })
        
        assert response.status_code == 401
    
    def test_login_sin_email(self, client):
        """Test: Login sin email"""
        response = client.post('/api/login', json={
            'password': 'password123'
        })
        
        assert response.status_code == 400
    
    def test_login_sin_password(self, client):
        """Test: Login sin password"""
        response = client.post('/api/login', json={
            'email': 'test@example.com'
        })
        
        assert response.status_code == 400
    
    def test_password_hasheado_correctamente(self, app):
        """Test: Verificar que passwords se hashean"""
        from werkzeug.security import generate_password_hash
        from app.models import Usuario, Rol
        from app.extensions import db
        
        with app.app_context():
            rol = Rol.query.first()
            password_plain = 'mipassword123'
            
            usuario = Usuario(
                email='hash@test.com',
                password_hash=generate_password_hash(password_plain),
                nombre_completo='Hash Test',
                role_id=rol.id
            )
            db.session.add(usuario)
            db.session.commit()
            
            # Verificar que NO se guarda en texto plano
            assert usuario.password_hash != password_plain
            
            # Verificar que el hash es válido
            assert check_password_hash(usuario.password_hash, password_plain)
            
            # Verificar que password incorrecta no valida
            assert not check_password_hash(usuario.password_hash, 'password_incorrecta')
