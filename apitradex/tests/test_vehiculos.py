"""
Tests para endpoints de vehículos
"""
import pytest
from app.models import Vehiculo


class TestVehiculosAPI:
    """Suite de tests para API de vehículos"""
    
    def test_crear_vehiculo_exitoso(self, client):
        """Test: Crear vehículo con datos válidos"""
        response = client.post('/api/vehiculos', json={
            'placa': 'ABC123',
            'modelo': 'Chevrolet NPR',
            'capacidad_kg': 3500.00,
            'capacidad_m3': 15.50,
            'estado': 'disponible'
        })
        
        assert response.status_code == 201
        data = response.get_json()
        assert 'id' in data
    
    def test_crear_vehiculo_placa_duplicada(self, client):
        """Test: No permitir placas duplicadas"""
        # Crear primer vehículo
        client.post('/api/vehiculos', json={
            'placa': 'XYZ789',
            'modelo': 'Hino 816',
            'capacidad_kg': 5000.00,
            'estado': 'disponible'
        })
        
        # Intentar crear con misma placa
        response = client.post('/api/vehiculos', json={
            'placa': 'XYZ789',  # Duplicada
            'modelo': 'Otro Modelo',
            'capacidad_kg': 3000.00,
            'estado': 'disponible'
        })
        
        assert response.status_code == 409
        data = response.get_json()
        assert 'Placa ya registrada' in data['error']
    
    def test_listar_vehiculos(self, client):
        """Test: Listar vehículos con paginación"""
        # Crear algunos vehículos
        for i in range(3):
            client.post('/api/vehiculos', json={
                'placa': f'VEH{i:03d}',
                'modelo': f'Modelo {i}',
                'capacidad_kg': 3000.00,
                'estado': 'disponible'
            })
        
        response = client.get('/api/vehiculos?page=1&per_page=10')
        
        assert response.status_code == 200
        data = response.get_json()
        assert 'data' in data
        assert len(data['data']) >= 3
    
    def test_actualizar_estado_vehiculo(self, client):
        """Test: Cambiar estado de vehículo"""
        # Crear vehículo
        create_response = client.post('/api/vehiculos', json={
            'placa': 'EST001',
            'modelo': 'Test Modelo',
            'capacidad_kg': 4000.00,
            'estado': 'disponible'
        })
        vehiculo_id = create_response.get_json()['id']
        
        # Actualizar estado
        response = client.put(f'/api/vehiculos/{vehiculo_id}', json={
            'estado': 'en_ruta'
        })
        
        assert response.status_code == 200
        
        # Verificar cambio
        get_response = client.get(f'/api/vehiculos/{vehiculo_id}')
        assert get_response.get_json()['estado'] == 'en_ruta'
    
    def test_asignar_conductor_a_vehiculo(self, client, usuario_cliente):
        """Test: Asignar conductor a vehículo"""
        # Crear vehículo
        create_response = client.post('/api/vehiculos', json={
            'placa': 'CON001',
            'modelo': 'Con Conductor',
            'capacidad_kg': 3000.00,
            'estado': 'disponible'
        })
        vehiculo_id = create_response.get_json()['id']
        
        # Asignar conductor
        response = client.put(f'/api/vehiculos/{vehiculo_id}', json={
            'conductor_id': usuario_cliente.id
        })
        
        assert response.status_code == 200
    
    def test_eliminar_vehiculo(self, client):
        """Test: Eliminar vehículo"""
        # Crear vehículo
        create_response = client.post('/api/vehiculos', json={
            'placa': 'DEL001',
            'modelo': 'Para Eliminar',
            'capacidad_kg': 2500.00,
            'estado': 'mantenimiento'
        })
        vehiculo_id = create_response.get_json()['id']
        
        # Eliminar
        response = client.delete(f'/api/vehiculos/{vehiculo_id}')
        
        assert response.status_code == 200
        
        # Verificar eliminación
        get_response = client.get(f'/api/vehiculos/{vehiculo_id}')
        assert get_response.status_code == 404
