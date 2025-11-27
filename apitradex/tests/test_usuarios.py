"""
Tests para endpoints de usuarios
"""
import pytest
from app.models import Usuario


class TestUsuariosAPI:
    """Suite de tests para API de usuarios"""
    
    def test_crear_usuario_exitoso(self, client):
        """Test: Crear usuario con datos válidos"""
        response = client.post('/api/usuarios', json={
            'email': 'nuevo@example.com',
            'password': 'password123',
            'rol': 'Cliente',
            'nombre_completo': 'Usuario Nuevo',
            'telefono': '3001234567'
        })
        
        assert response.status_code == 201
        data = response.get_json()
        assert 'id' in data
        assert data['id'] > 0
    
    def test_crear_usuario_email_duplicado(self, client, usuario_cliente):
        """Test: No permitir emails duplicados"""
        response = client.post('/api/usuarios', json={
            'email': 'cliente@example.com',  # Ya existe
            'password': 'pass456',
            'rol': 'Cliente',
            'nombre_completo': 'Otro Usuario'
        })
        
        assert response.status_code == 409
        data = response.get_json()
        assert 'Email ya registrado' in data['error']
    
    def test_crear_usuario_sin_email(self, client):
        """Test: Email es obligatorio"""
        response = client.post('/api/usuarios', json={
            'password': 'pass123',
            'rol': 'Cliente',
            'nombre_completo': 'Sin Email'
        })
        
        assert response.status_code == 400
        data = response.get_json()
        assert 'email' in data['error'].lower()
    
    def test_crear_usuario_sin_password(self, client):
        """Test: Password es obligatorio"""
        response = client.post('/api/usuarios', json={
            'email': 'test@example.com',
            'rol': 'Cliente',
            'nombre_completo': 'Sin Password'
        })
        
        assert response.status_code == 400
    
    def test_listar_usuarios(self, client, usuario_admin, usuario_cliente):
        """Test: Listar usuarios con paginación"""
        response = client.get('/api/usuarios?page=1&per_page=10')
        
        assert response.status_code == 200
        data = response.get_json()
        assert 'data' in data
        assert 'total' in data
        assert data['total'] >= 2
        assert len(data['data']) >= 2
    
    def test_obtener_usuario_existente(self, client, usuario_cliente):
        """Test: Obtener usuario por ID"""
        response = client.get(f'/api/usuarios/{usuario_cliente.id}')
        
        assert response.status_code == 200
        data = response.get_json()
        assert data['email'] == 'cliente@example.com'
        assert data['nombre_completo'] == 'Cliente Test'
    
    def test_obtener_usuario_inexistente(self, client):
        """Test: Error 404 para usuario que no existe"""
        response = client.get('/api/usuarios/99999')
        
        assert response.status_code == 404
        data = response.get_json()
        assert 'no encontrado' in data['error'].lower()
    
    def test_actualizar_usuario(self, client, usuario_cliente):
        """Test: Actualizar datos de usuario"""
        response = client.put(f'/api/usuarios/{usuario_cliente.id}', json={
            'nombre_completo': 'Cliente Actualizado',
            'telefono': '3009876543'
        })
        
        assert response.status_code == 200
        data = response.get_json()
        assert data['message'] == 'Usuario actualizado'
    
    def test_eliminar_usuario(self, client, usuario_cliente):
        """Test: Eliminar usuario"""
        usuario_id = usuario_cliente.id
        
        response = client.delete(f'/api/usuarios/{usuario_id}')
        
        assert response.status_code == 200
        data = response.get_json()
        assert data['message'] == 'Usuario eliminado'
        
        # Verificar que ya no existe
        response_get = client.get(f'/api/usuarios/{usuario_id}')
        assert response_get.status_code == 404
    
    def test_filtrar_usuarios_por_rol(self, client, usuario_admin, usuario_cliente):
        """Test: Filtrar usuarios por rol"""
        response = client.get('/api/usuarios?rol=Cliente')
        
        assert response.status_code == 200
        data = response.get_json()
        # Todos los usuarios deben ser clientes
        for usuario in data['data']:
            assert usuario['rol'] == 'Cliente'
