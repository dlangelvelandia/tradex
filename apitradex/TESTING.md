# 🧪 Guía de Testing - TRADEX Backend

## Instalación de dependencias de testing

```powershell
cd c:\taller\tradex\apitradex
python -m pip install -r requirements.txt
python -m pip install -r requirements-dev.txt
```

## Ejecutar todos los tests

```powershell
# Ejecutar tests con cobertura
pytest

# Ver reporte de cobertura en terminal
pytest --cov=app --cov-report=term-missing

# Generar reporte HTML de cobertura
pytest --cov=app --cov-report=html
# Abrir: htmlcov/index.html
```

## Ejecutar tests específicos

```powershell
# Solo tests de usuarios
pytest tests/test_usuarios.py

# Solo tests de vehículos
pytest tests/test_vehiculos.py

# Solo tests de autenticación
pytest tests/test_auth.py

# Un test específico
pytest tests/test_usuarios.py::TestUsuariosAPI::test_crear_usuario_exitoso
```

## Ejecutar con diferentes niveles de verbosidad

```powershell
# Modo silencioso (solo resumen)
pytest -q

# Modo verbose (detalles)
pytest -v

# Modo extra verbose (mucho detalle)
pytest -vv

# Mostrar print() en tests
pytest -s
```

## Ver solo tests que fallan

```powershell
pytest --tb=short  # Traceback corto
pytest --tb=line   # Una línea por fallo
pytest -x          # Detener en primer fallo
```

## Estructura de tests actual

```
tests/
├── __init__.py              # Package marker
├── conftest.py              # Fixtures compartidas
├── test_usuarios.py         # 10 tests de API usuarios
├── test_vehiculos.py        # 6 tests de API vehículos
└── test_auth.py             # 6 tests de autenticación

Total: 22 tests unitarios
```

## Cobertura esperada

| Módulo | Cobertura Target | Estado |
|--------|------------------|--------|
| `app/routes.py` | >80% | ⏳ Pendiente |
| `app/models.py` | >90% | ⏳ Pendiente |
| `app/extensions.py` | 100% | ⏳ Pendiente |

## Agregar nuevos tests

### Template para test de endpoint:

```python
def test_nuevo_endpoint(self, client):
    """Test: Descripción de qué valida"""
    response = client.post('/api/endpoint', json={
        'campo': 'valor'
    })
    
    assert response.status_code == 200
    data = response.get_json()
    assert 'campo_esperado' in data
```

### Template para test con fixture:

```python
def test_con_datos(self, client, usuario_admin):
    """Test: Usa datos de fixture"""
    response = client.get(f'/api/usuarios/{usuario_admin.id}')
    
    assert response.status_code == 200
    assert response.get_json()['email'] == 'admin@tradex.com'
```

## Buenas prácticas

1. **Nombres descriptivos**: `test_crear_usuario_email_duplicado` mejor que `test_2`
2. **Un assert por concepto**: No mezclar validaciones no relacionadas
3. **Arrange-Act-Assert**: Preparar → Ejecutar → Verificar
4. **Tests independientes**: Cada test debe poder correr solo
5. **Limpiar estado**: Usar fixtures que resetean BD en memoria

## CI/CD (Futuro)

```yaml
# .github/workflows/test.yml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install dependencies
        run: pip install -r requirements-dev.txt
      - name: Run tests
        run: pytest --cov=app --cov-fail-under=70
```

## Troubleshooting

### Error: "No module named pytest"
```powershell
python -m pip install pytest pytest-cov
```

### Error: "No such table"
- Los tests usan SQLite en memoria, se crea automáticamente
- Revisar `conftest.py` → fixture `app`

### Tests pasan local pero fallan en otro PC
- Verificar versiones de Python (3.11+)
- Verificar dependencias: `pip list`

## Métricas actuales

```bash
# Ejecutar para ver estado actual
pytest --cov=app --cov-report=term-missing

# Output esperado:
# ===== 22 passed in 2.5s =====
# Coverage: ~65-75%
```

## Próximos pasos

- [ ] Agregar tests para rutas (CRUD completo)
- [ ] Tests de integración E2E
- [ ] Tests de performance (pytest-benchmark)
- [ ] Tests de seguridad (SQL injection, XSS)
