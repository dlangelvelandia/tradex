# DOCUMENTACIÓN TÉCNICA - SISTEMA TRADEX
## Sistema de Gestión Logística con CRUD Completo

---

## 1. INTRODUCCIÓN

### 1.1 Descripción del Proyecto
TRADEX es un sistema web de gestión logística que permite administrar usuarios, vehículos y rutas de transporte. El sistema implementa operaciones CRUD (Create, Read, Update, Delete) completas para las tres entidades principales.

### 1.2 Tecnologías Utilizadas

**Backend:**
- Python 3.x
- Flask 3.1.2 (Framework web)
- SQLAlchemy 2.0.44 (ORM)
- PyMySQL 1.1.2 (Conector MySQL)
- Flask-CORS (Cross-Origin Resource Sharing)

**Frontend:**
- Flutter/Dart SDK 3.9.2
- HTTP Package 1.5.0
- Flutter Web

**Base de Datos:**
- MySQL 8.x
- XAMPP (Servidor local)

---

## 2. ARQUITECTURA DEL SISTEMA

### 2.1 Patrón Arquitectónico
El sistema implementa una arquitectura de **tres capas**:

```
┌─────────────────────────────────────────────────────────┐
│                   CAPA DE PRESENTACIÓN                   │
│              (Flutter Web - Puerto 8080)                 │
│  - Interfaz de usuario responsiva                        │
│  - Validaciones del lado del cliente                     │
│  - Gestión de estado local                               │
└─────────────────┬───────────────────────────────────────┘
                  │ HTTP/JSON
                  │ (API REST)
┌─────────────────▼───────────────────────────────────────┐
│                    CAPA DE NEGOCIO                       │
│                (Flask API - Puerto 5000)                 │
│  - Endpoints REST                                        │
│  - Validaciones de negocio                               │
│  - Conversión de datos                                   │
│  - Autenticación JWT                                     │
└─────────────────┬───────────────────────────────────────┘
                  │ SQLAlchemy ORM
                  │
┌─────────────────▼───────────────────────────────────────┐
│                  CAPA DE PERSISTENCIA                    │
│                 (MySQL - Puerto 3306)                    │
│  - Almacenamiento de datos                               │
│  - Integridad referencial                                │
│  - Relaciones entre entidades                            │
└─────────────────────────────────────────────────────────┘
```

---

## 3. MODELO DE DATOS

### 3.1 Diagrama Entidad-Relación

```
┌──────────────────┐           ┌──────────────────┐
│      ROLES       │           │    USUARIOS      │
├──────────────────┤           ├──────────────────┤
│ PK id            │◄──────────│ PK id            │
│    nombre        │     1:N   │ FK rol_id        │
│    descripcion   │           │    email         │
└──────────────────┘           │    password      │
                               │    nombre_comp   │
                               │    telefono      │
                               │    direccion     │
                               └────────┬─────────┘
                                        │
                         ┌──────────────┼──────────────┐
                         │              │              │
                         │ Conductor    │ Cliente      │
                         │              │              │
                    ┌────▼────┐    ┌───▼────┐    ┌────▼────┐
                    │VEHICULOS│    │ RUTAS  │    │ RUTAS   │
                    ├─────────┤    ├────────┤    ├─────────┤
                    │PK id    │    │PK id   │    │FK cliente│
                    │  placa  │    │  codigo│    │         │
┌────────┐          │  marca  │    │  nombre│    └─────────┘
│VEHICULO│◄─────────┤  modelo │◄───┤FK veh  │
│        │   1:N    │  anio   │1:N │FK cond │
└────────┘          │  cap_kg │    │  estado│
                    │  vol_m3 │    │  prior │
                    │  estado │    │  fecha │
                    │FK cond  │    └────┬───┘
                    └─────────┘         │
                                        │ 1:N
                                   ┌────▼────────┐
                                   │RUTAS_PARADAS│
                                   ├─────────────┤
                                   │PK id        │
                                   │FK ruta_id   │
                                   │  orden      │
                                   │  direccion  │
                                   │  latitud    │
                                   │  longitud   │
                                   └─────────────┘
```

### 3.2 Descripción de Tablas

#### Tabla: roles
```sql
CREATE TABLE roles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    descripcion TEXT
);
```

**Registros por defecto:**
- Administrador
- Cliente
- Conductor

#### Tabla: usuarios
```sql
CREATE TABLE usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    rol_id INT NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    nombre_completo VARCHAR(150),
    telefono VARCHAR(20),
    direccion TEXT,
    FOREIGN KEY (rol_id) REFERENCES roles(id)
);
```

#### Tabla: vehiculos
```sql
CREATE TABLE vehiculos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    placa VARCHAR(20) UNIQUE NOT NULL,
    marca VARCHAR(50),
    modelo VARCHAR(50),
    anio INT,
    capacidad_kg DECIMAL(10,2),
    volumen_m3 DECIMAL(10,2),
    estado VARCHAR(20) DEFAULT 'disponible',
    conductor_id INT,
    FOREIGN KEY (conductor_id) REFERENCES usuarios(id)
);
```

**Estados válidos:** disponible, en_ruta, mantenimiento

#### Tabla: rutas
```sql
CREATE TABLE rutas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    codigo VARCHAR(50) UNIQUE NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT,
    estado VARCHAR(20) DEFAULT 'pendiente',
    prioridad INT DEFAULT 1,
    fecha_programada DATE,
    hora_inicio TIME,
    hora_fin TIME,
    cliente_id INT,
    conductor_id INT,
    vehiculo_id INT,
    meta JSON,
    FOREIGN KEY (cliente_id) REFERENCES usuarios(id),
    FOREIGN KEY (conductor_id) REFERENCES usuarios(id),
    FOREIGN KEY (vehiculo_id) REFERENCES vehiculos(id)
);
```

**Estados válidos:** pendiente, en_curso, completada, cancelada
**Prioridad:** 1=Baja, 2=Media, 3=Alta

---

## 4. API REST - ENDPOINTS

### 4.1 Autenticación

#### POST /auth/login
**Descripción:** Iniciar sesión y obtener token JWT

**Request:**
```json
{
    "email": "admin@tradex.com",
    "password": "123456"
}
```

**Response (200):**
```json
{
    "access_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
    "user": {
        "id": 1,
        "email": "admin@tradex.com",
        "rol": "Administrador",
        "nombre_completo": "Administrador Sistema"
    }
}
```

---

### 4.2 CRUD de Usuarios

#### Archivo: `apitradex/app/routes.py` (Líneas 135-260)

#### 1. CREATE - POST /usuarios
**Descripción:** Crear un nuevo usuario

**Request:**
```json
{
    "email": "cliente1@example.com",
    "password": "pass123",
    "rol_id": 2,
    "nombre_completo": "Juan Pérez",
    "telefono": "3001234567",
    "direccion": "Calle 123 #45-67"
}
```

**Response (201):**
```json
{
    "id": 4
}
```

**Validaciones:**
- Email único y obligatorio
- Password obligatorio
- rol_id debe existir en tabla roles

---

#### 2. READ - GET /usuarios
**Descripción:** Listar todos los usuarios con paginación

**Query Parameters:**
- `page`: Número de página (default: 1)
- `per_page`: Registros por página (default: 50)
- `rol_id`: Filtrar por ID de rol

**Request:**
```
GET /usuarios?page=1&per_page=10&rol_id=2
```

**Response (200):**
```json
{
    "data": [
        {
            "id": 2,
            "email": "cliente1@example.com",
            "rol_id": 2,
            "rol_nombre": "Cliente",
            "nombre_completo": "Juan Pérez",
            "telefono": "3001234567",
            "direccion": "Calle 123 #45-67"
        }
    ],
    "page": 1,
    "per_page": 10,
    "total": 1,
    "pages": 1
}
```

---

#### 3. READ ONE - GET /usuarios/{id}
**Descripción:** Obtener un usuario específico

**Request:**
```
GET /usuarios/2
```

**Response (200):**
```json
{
    "id": 2,
    "email": "cliente1@example.com",
    "rol_id": 2,
    "rol_nombre": "Cliente",
    "nombre_completo": "Juan Pérez",
    "telefono": "3001234567",
    "direccion": "Calle 123 #45-67"
}
```

**Response (404):**
```json
{
    "error": "Usuario no existe"
}
```

---

#### 4. UPDATE - PUT /usuarios/{id}
**Descripción:** Actualizar datos de un usuario

**Request:**
```json
{
    "nombre_completo": "Juan Pérez Actualizado",
    "telefono": "3009876543"
}
```

**Response (200):**
```json
{
    "ok": true
}
```

**Notas:**
- Solo se actualizan los campos enviados
- No se permite actualizar email ni rol_id por seguridad

---

#### 5. DELETE - DELETE /usuarios/{id}
**Descripción:** Eliminar un usuario

**Request:**
```
DELETE /usuarios/4
```

**Response (200):**
```json
{
    "ok": true
}
```

**Response (404):**
```json
{
    "error": "Usuario no existe"
}
```

---

### 4.3 CRUD de Vehículos

#### Archivo: `apitradex/app/routes.py` (Líneas 268-410)

#### 1. CREATE - POST /vehiculos
**Descripción:** Registrar un nuevo vehículo

**Request:**
```json
{
    "placa": "ABC123",
    "marca": "Chevrolet",
    "modelo": "NPRS",
    "anio": 2022,
    "capacidad_kg": 3400,
    "volumen_m3": 15,
    "estado": "disponible",
    "conductor_id": 6
}
```

**Response (201):**
```json
{
    "id": 1
}
```

**Validaciones:**
- Placa única y obligatoria
- Placa se convierte automáticamente a mayúsculas
- conductor_id opcional (puede ser null)

---

#### 2. READ - GET /vehiculos
**Descripción:** Listar vehículos con paginación

**Query Parameters:**
- `page`: Número de página
- `per_page`: Registros por página
- `conductor_id`: Filtrar por conductor
- `estado`: Filtrar por estado

**Request:**
```
GET /vehiculos?estado=disponible&per_page=20
```

**Response (200):**
```json
{
    "data": [
        {
            "id": 1,
            "placa": "ABC123",
            "marca": "Chevrolet",
            "modelo": "NPRS",
            "anio": 2022,
            "capacidad_kg": 3400.0,
            "volumen_m3": 15.0,
            "estado": "disponible",
            "conductor_id": 6,
            "conductor_nombre": "Celico Homez"
        }
    ],
    "page": 1,
    "per_page": 20,
    "total": 1,
    "pages": 1
}
```

**Nota:** El campo `conductor_nombre` se calcula dinámicamente desde la tabla usuarios.

---

#### 3. READ ONE - GET /vehiculos/{id}
**Descripción:** Obtener detalles de un vehículo

**Request:**
```
GET /vehiculos/1
```

**Response (200):**
```json
{
    "id": 1,
    "placa": "ABC123",
    "marca": "Chevrolet",
    "modelo": "NPRS",
    "anio": 2022,
    "capacidad_kg": 3400.0,
    "volumen_m3": 15.0,
    "estado": "disponible",
    "conductor_id": 6,
    "conductor_nombre": "Celico Homez"
}
```

---

#### 4. UPDATE - PUT /vehiculos/{id}
**Descripción:** Actualizar datos de un vehículo

**Request:**
```json
{
    "estado": "en_ruta",
    "conductor_id": 7
}
```

**Response (200):**
```json
{
    "ok": true
}
```

**Campos actualizables:**
- placa, marca, modelo, anio
- capacidad_kg, volumen_m3
- estado, conductor_id

---

#### 5. DELETE - DELETE /vehiculos/{id}
**Descripción:** Eliminar un vehículo

**Request:**
```
DELETE /vehiculos/1
```

**Response (200):**
```json
{
    "ok": true
}
```

**Restricción:** No se puede eliminar si está asignado a rutas activas.

---

### 4.4 CRUD de Rutas

#### Archivo: `apitradex/app/routes.py` (Líneas 412-660)

#### 1. CREATE - POST /rutas
**Descripción:** Crear una nueva ruta de transporte

**Request:**
```json
{
    "codigo": "R-001",
    "nombre": "Ruta Norte",
    "descripcion": "Entrega zona norte de la ciudad",
    "estado": "pendiente",
    "prioridad": "alta",
    "fecha_programada": "2025-11-27",
    "hora_inicio": "08:00",
    "hora_fin": "17:00",
    "cliente_id": 2,
    "conductor_id": 6,
    "vehiculo_id": 1
}
```

**Response (201):**
```json
{
    "id": 1
}
```

**Validaciones:**
- Código único y obligatorio
- Nombre obligatorio
- Prioridad: "baja", "media", "alta" (se convierte a 1, 2, 3 en BD)

**Conversión de Prioridad:**
```python
PRIORIDAD_STR_TO_INT = {'baja': 1, 'media': 2, 'alta': 3}
PRIORIDAD_INT_TO_STR = {1: 'baja', 2: 'media', 3: 'alta'}
```

---

#### 2. READ - GET /rutas
**Descripción:** Listar rutas con filtros

**Query Parameters:**
- `cliente_id`: Filtrar por cliente
- `conductor_id`: Filtrar por conductor
- `estado`: Filtrar por estado

**Request:**
```
GET /rutas?estado=en_curso&per_page=50
```

**Response (200):**
```json
{
    "data": [
        {
            "id": 1,
            "codigo": "R-001",
            "nombre": "Ruta Norte",
            "descripcion": "Entrega zona norte",
            "estado": "en_curso",
            "prioridad": "alta",
            "fecha_programada": "2025-11-27",
            "hora_inicio": "08:00",
            "hora_fin": "17:00",
            "cliente_id": 2,
            "cliente_nombre": "María García",
            "conductor_id": 6,
            "conductor_nombre": "Celico Homez",
            "vehiculo_id": 1,
            "vehiculo_info": "ABC123 - Chevrolet NPRS",
            "meta": {}
        }
    ],
    "page": 1,
    "per_page": 50,
    "total": 1,
    "pages": 1
}
```

**Campos calculados:**
- `cliente_nombre`: Nombre del usuario cliente
- `conductor_nombre`: Nombre del usuario conductor
- `vehiculo_info`: Formato "PLACA - MARCA MODELO"

---

#### 3. READ ONE - GET /rutas/{id}
**Descripción:** Obtener detalles completos de una ruta

**Request:**
```
GET /rutas/1
```

**Response (200):**
```json
{
    "id": 1,
    "codigo": "R-001",
    "nombre": "Ruta Norte",
    "descripcion": "Entrega zona norte",
    "estado": "en_curso",
    "prioridad": "alta",
    "fecha_programada": "2025-11-27",
    "hora_inicio": "08:00",
    "hora_fin": "17:00",
    "cliente_id": 2,
    "cliente_nombre": "María García",
    "conductor_id": 6,
    "conductor_nombre": "Celico Homez",
    "vehiculo_id": 1,
    "vehiculo_info": "ABC123 - Chevrolet NPRS",
    "meta": {}
}
```

---

#### 4. UPDATE - PUT /rutas/{id}
**Descripción:** Actualizar información de una ruta

**Request:**
```json
{
    "estado": "completada",
    "prioridad": "media"
}
```

**Response (200):**
```json
{
    "ok": true
}
```

**Campos actualizables:**
- codigo, nombre, descripcion
- estado, prioridad
- fecha_programada, hora_inicio, hora_fin
- cliente_id, conductor_id, vehiculo_id

**Nota:** La prioridad en texto se convierte automáticamente a número.

---

#### 5. DELETE - DELETE /rutas/{id}
**Descripción:** Eliminar una ruta

**Request:**
```
DELETE /rutas/1
```

**Response (200):**
```json
{
    "ok": true
}
```

**Cascada:** Elimina automáticamente las paradas asociadas (rutas_paradas).

---

## 5. FRONTEND - ESTRUCTURA

### 5.1 Organización de Archivos

```
tradex/lib/
├── main.dart                    # Punto de entrada
├── login_page.dart              # Pantalla de login
├── session.dart                 # Gestión de sesión
├── auth_forms.dart              # Formularios de autenticación
│
├── services/
│   └── api.dart                 # Cliente HTTP para API
│
└── administrador/
    ├── admin_dashboard_page.dart    # Dashboard principal
    ├── admin_usuarios_page.dart     # CRUD Usuarios
    ├── admin_vehiculos_page.dart    # CRUD Vehículos
    ├── admin_rutas_page.dart        # CRUD Rutas
    └── sidebar_admin.dart           # Menú lateral
```

---

### 5.2 Servicio API (api.dart)

#### Clase: Api
**Ubicación:** `tradex/lib/services/api.dart`

**Métodos principales:**

```dart
// Autenticación
static Future<Map<String, dynamic>> login(String email, String password)

// USUARIOS
static Future<List<dynamic>> listarUsuariosPorRol(String rol, {int page, int perPage})
static Future<void> crearUsuario({
  required String email,
  required String password,
  required int rolId,
  String? nombreCompleto,
  String? telefono,
  String? direccion
})
static Future<void> actualizarUsuario(int id, Map<String, dynamic> data)
static Future<void> eliminarUsuario(int id)

// VEHÍCULOS
static Future<Map<String, dynamic>> listarVehiculos({int page, int perPage})
static Future<void> crearVehiculo({
  required String placa,
  String? marca,
  String? modelo,
  int? anio,
  double? capacidadKg,
  double? volumenM3,
  String? estado,
  int? conductorId
})
static Future<void> actualizarVehiculo(int id, Map<String, dynamic> data)
static Future<void> eliminarVehiculo(int id)

// RUTAS
static Future<Map<String, dynamic>> listarRutasAdmin({int page, int perPage})
static Future<void> crearRuta({
  required String codigo,
  required String nombre,
  String? descripcion,
  String? estado,
  String? prioridad,
  String? fechaProgramada,
  String? horaInicio,
  String? horaFin,
  int? clienteId,
  int? conductorId,
  int? vehiculoId
})
static Future<void> actualizarRuta(int id, Map<String, dynamic> data)
static Future<void> eliminarRuta(int id)
```

---

### 5.3 CRUD Usuarios (admin_usuarios_page.dart)

#### Componentes principales:

**1. AdminUsuariosPage (StatefulWidget)**
- Lista de usuarios
- Filtro por rol (Cliente/Conductor)
- Botón "Nuevo Usuario"
- Acciones: Editar, Eliminar

**2. _FormularioUsuario (Dialog)**
- Campos: email, password, rol, nombre, teléfono, dirección
- Validaciones de formulario
- Manejo de errores

**Flujo de creación:**
```
Usuario hace clic en "Nuevo Usuario"
        ↓
Se abre diálogo _FormularioUsuario
        ↓
Usuario llena formulario
        ↓
Se valida el formulario
        ↓
Se llama Api.crearUsuario()
        ↓
Backend crea registro en BD
        ↓
Se cierra diálogo
        ↓
Se recarga lista de usuarios
        ↓
Se muestra mensaje de éxito
```

**Código clave:**
```dart
Future<void> _guardar() async {
  if (!_formKey.currentState!.validate()) return;
  
  setState(() => _guardando = true);
  try {
    await Api.crearUsuario(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      rolId: _rolId!,
      nombreCompleto: _nombreCtrl.text.trim(),
      telefono: _telefonoCtrl.text.trim(),
      direccion: _direccionCtrl.text.trim(),
    );
    
    Navigator.of(context).pop(true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Usuario creado'))
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e'))
    );
  } finally {
    setState(() => _guardando = false);
  }
}
```

---

### 5.4 CRUD Vehículos (admin_vehiculos_page.dart)

#### Características especiales:

**1. Asignación de Conductor**
- Dropdown con lista de conductores
- Opción "Sin asignar"
- Carga dinámica de conductores desde API

**2. Visualización en Lista**
- Muestra conductor asignado en azul
- Badge de estado (disponible/en_ruta/mantenimiento)

**Código de Dropdown:**
```dart
DropdownButtonFormField<int>(
  value: _conductorId,
  decoration: InputDecoration(
    labelText: 'Conductor Asignado',
    border: OutlineInputBorder(),
  ),
  items: [
    DropdownMenuItem(value: null, child: Text('Sin asignar')),
    ..._conductores.map((c) => DropdownMenuItem(
      value: c['id'],
      child: Text(c['nombre_completo'] ?? 'Sin nombre'),
    )),
  ],
  onChanged: (v) => setState(() => _conductorId = v),
)
```

**Estados del vehículo:**
- **disponible** (verde): Listo para asignar
- **en_ruta** (naranja): En operación
- **mantenimiento** (rojo): Fuera de servicio

---

### 5.5 CRUD Rutas (admin_rutas_page.dart)

#### Características avanzadas:

**1. Triple Asignación**
- Cliente (dropdown)
- Conductor (dropdown)
- Vehículo (dropdown)

**2. Gestión de Prioridad**
- Dropdown con valores: Baja, Media, Alta
- Conversión automática a número en backend

**3. Campos de Fecha/Hora**
- Fecha programada (Date picker)
- Hora inicio y fin (Time pickers)

**Inicialización de datos:**
```dart
Future<void> _cargarDatosIniciales() async {
  setState(() => _cargandoDatos = true);
  try {
    // Cargar clientes
    final clientes = await Api.listarUsuariosPorRol('Cliente', perPage: 500);
    _clientes = clientes.cast<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList();
    
    // Cargar conductores
    final conductores = await Api.listarUsuariosPorRol('Conductor', perPage: 500);
    _conductores = conductores.cast<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList();
    
    // Cargar vehículos
    final vehResp = await Api.listarVehiculos(perPage: 500);
    final vehList = (vehResp['data'] ?? []) as List;
    _vehiculos = vehList.cast<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList();
    
    if (mounted) {
      setState(() => _cargandoDatos = false);
    }
  } catch (e) {
    // Manejar error
  }
}
```

**Visualización de información:**
```dart
ListTile(
  title: Text('${r['codigo']} • ${r['nombre']}'),
  subtitle: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Fecha: ${r['fecha_programada']} • Prioridad: ${r['prioridad']}'),
      if (r['cliente_nombre'] != null)
        Text('Cliente: ${r['cliente_nombre']}', 
            style: TextStyle(color: Colors.grey)),
      if (r['conductor_nombre'] != null)
        Text('Conductor: ${r['conductor_nombre']}', 
            style: TextStyle(color: Colors.blue)),
      if (r['vehiculo_info'] != null)
        Text('Vehículo: ${r['vehiculo_info']}', 
            style: TextStyle(color: Colors.green)),
    ],
  ),
)
```

---

## 6. FLUJOS DE DATOS

### 6.1 Diagrama de Secuencia - Crear Usuario

```
Usuario      Frontend          API Flask        Base de Datos
  |              |                 |                  |
  |-- Clic "Nuevo Usuario" ------->|                  |
  |              |                 |                  |
  |<-- Muestra Formulario ---------|                  |
  |              |                 |                  |
  |-- Llena datos y "Guardar" ---->|                  |
  |              |                 |                  |
  |              |-- Valida datos ---|                |
  |              |                 |                  |
  |              |-- POST /usuarios -->               |
  |              |                 |                  |
  |              |                 |-- Valida email único -->
  |              |                 |                  |
  |              |                 |<- Email válido --|
  |              |                 |                  |
  |              |                 |-- Hash password --|
  |              |                 |                  |
  |              |                 |-- INSERT INTO usuarios -->
  |              |                 |                  |
  |              |                 |<- ID generado ---|
  |              |                 |                  |
  |              |<- 201 Created --|                  |
  |              |  { "id": 4 }    |                  |
  |              |                 |                  |
  |<-- Mensaje "Usuario creado" ---|                  |
  |              |                 |                  |
  |              |-- GET /usuarios -->                |
  |              |                 |                  |
  |              |                 |-- SELECT * FROM usuarios -->
  |              |                 |                  |
  |              |                 |<- Lista usuarios |
  |              |                 |                  |
  |              |<- 200 OK -------|                  |
  |              |  { data: [...] }|                  |
  |              |                 |                  |
  |<-- Actualiza lista ------------|                  |
  |              |                 |                  |
```

---

### 6.2 Diagrama de Secuencia - Asignar Conductor a Vehículo

```
Admin       Frontend        API Flask      BD MySQL
  |             |               |              |
  |-- Edita vehículo -------->  |              |
  |             |               |              |
  |             |-- GET /usuarios/rol/Conductor -->
  |             |               |              |
  |             |               |-- SELECT * FROM usuarios
  |             |               |   WHERE rol='Conductor' -->
  |             |               |              |
  |             |               |<- Lista conductores --
  |             |               |              |
  |             |<- 200 OK -----|              |
  |             |  [conductores]|              |
  |             |               |              |
  |<-- Muestra dropdown con conductores ----  |
  |             |               |              |
  |-- Selecciona conductor -----> _conductorId = 6
  |             |               |              |
  |-- Clic "Guardar" --------->|              |
  |             |               |              |
  |             |-- PUT /vehiculos/1 -->       |
  |             |  { conductor_id: 6 }         |
  |             |               |              |
  |             |               |-- UPDATE vehiculos
  |             |               |   SET conductor_id=6
  |             |               |   WHERE id=1 -->
  |             |               |              |
  |             |               |<- Affected: 1
  |             |               |              |
  |             |<- 200 OK -----|              |
  |             |  { ok: true } |              |
  |             |               |              |
  |<-- Mensaje "Actualizado" --|              |
  |             |               |              |
```

---

## 7. VALIDACIONES

### 7.1 Validaciones Backend

#### Usuarios
```python
# Email único
if Usuario.query.filter_by(email=email).first():
    return jsonify(error="Ya existe un usuario con ese email"), 409

# Email válido (formato)
if not re.match(r'^[\w\.-]+@[\w\.-]+\.\w+$', email):
    return jsonify(error="Email inválido"), 400

# Password mínimo 6 caracteres
if len(password) < 6:
    return jsonify(error="Password debe tener al menos 6 caracteres"), 400
```

#### Vehículos
```python
# Placa única
if Vehiculo.query.filter_by(placa=placa).first():
    return jsonify(error="Ya existe un vehículo con esa placa"), 409

# Estado válido
estados_validos = ['disponible', 'en_ruta', 'mantenimiento']
if estado not in estados_validos:
    return jsonify(error="Estado inválido"), 400
```

#### Rutas
```python
# Código único
if Ruta.query.filter_by(codigo=codigo).first():
    return jsonify(error="Ya existe una ruta con ese código"), 409

# Prioridad válida
if prioridad not in ['baja', 'media', 'alta']:
    return jsonify(error="Prioridad inválida"), 400

# Conversión de prioridad
def prioridad_to_int(p_str):
    return {'baja': 1, 'media': 2, 'alta': 3}.get(p_str, 1)
```

---

### 7.2 Validaciones Frontend

#### Formulario de Usuario (Flutter)
```dart
TextFormField(
  controller: _emailCtrl,
  decoration: InputDecoration(labelText: 'Email *'),
  validator: (v) {
    if (v?.trim().isEmpty == true) return 'Email requerido';
    if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(v!)) {
      return 'Email inválido';
    }
    return null;
  },
)

TextFormField(
  controller: _passwordCtrl,
  obscureText: true,
  decoration: InputDecoration(labelText: 'Password *'),
  validator: (v) {
    if (v?.isEmpty == true) return 'Password requerido';
    if (v!.length < 6) return 'Mínimo 6 caracteres';
    return null;
  },
)
```

#### Dropdown con validación
```dart
DropdownButtonFormField<int>(
  value: _rolId,
  decoration: InputDecoration(labelText: 'Rol *'),
  items: [
    DropdownMenuItem(value: 2, child: Text('Cliente')),
    DropdownMenuItem(value: 3, child: Text('Conductor')),
  ],
  validator: (v) => v == null ? 'Selecciona un rol' : null,
  onChanged: (v) => setState(() => _rolId = v),
)
```

---

## 8. MANEJO DE ERRORES

### 8.1 Códigos HTTP Utilizados

| Código | Significado | Uso |
|--------|-------------|-----|
| 200 | OK | Operación exitosa (GET, PUT, DELETE) |
| 201 | Created | Recurso creado exitosamente (POST) |
| 400 | Bad Request | Datos inválidos o faltantes |
| 401 | Unauthorized | Token JWT inválido o expirado |
| 404 | Not Found | Recurso no existe |
| 409 | Conflict | Duplicado (email, placa, código) |
| 500 | Internal Server Error | Error del servidor |

---

### 8.2 Manejo de Errores en Flutter

```dart
try {
  await Api.crearVehiculo(
    placa: _placaCtrl.text.trim(),
    // ... otros campos
  );
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Vehículo creado exitosamente'),
      backgroundColor: Colors.green,
    ),
  );
  
} on ApiError catch (e) {
  // Error de la API con mensaje específico
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Error: ${e.message}'),
      backgroundColor: Colors.red,
    ),
  );
  
} catch (e) {
  // Error genérico
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Error inesperado: $e'),
      backgroundColor: Colors.red,
    ),
  );
}
```

---

## 9. SEGURIDAD

### 9.1 Autenticación JWT

**Generación del token (Backend):**
```python
from flask_jwt_extended import create_access_token

@bp.route('/auth/login', methods=['POST'])
def login():
    data = request.json
    email = data.get('email')
    password = data.get('password')
    
    usuario = Usuario.query.filter_by(email=email).first()
    
    if not usuario or not check_password_hash(usuario.password, password):
        return jsonify(error="Credenciales inválidas"), 401
    
    token = create_access_token(identity=usuario.id)
    
    return jsonify({
        'access_token': token,
        'user': {
            'id': usuario.id,
            'email': usuario.email,
            'rol': usuario.rol.nombre
        }
    })
```

**Uso del token (Frontend):**
```dart
class Api {
  static String? _token;
  
  static Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['access_token'];
    }
  }
  
  static Map<String, String> _headers() {
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }
}
```

---

### 9.2 Hashing de Passwords

```python
from werkzeug.security import generate_password_hash, check_password_hash

# Al crear usuario
hashed = generate_password_hash(password, method='pbkdf2:sha256')
usuario = Usuario(email=email, password=hashed)

# Al validar login
if check_password_hash(usuario.password, password_ingresado):
    # Password correcto
```

---

### 9.3 CORS (Cross-Origin Resource Sharing)

```python
from flask_cors import CORS

app = Flask(__name__)
CORS(app, resources={
    r"/*": {
        "origins": ["http://localhost:8080"],
        "methods": ["GET", "POST", "PUT", "DELETE"],
        "allow_headers": ["Content-Type", "Authorization"]
    }
})
```

---

## 10. PRUEBAS Y CASOS DE USO

### 10.1 Caso de Uso: Gestión de Usuarios

**Actor:** Administrador

**Precondiciones:**
- Administrador autenticado
- Navegador en página de Usuarios

**Flujo Principal:**
1. Admin hace clic en "Nuevo Usuario"
2. Sistema muestra formulario
3. Admin ingresa:
   - Email: cliente2@example.com
   - Password: pass123
   - Rol: Cliente
   - Nombre: Pedro López
   - Teléfono: 3001234567
4. Admin hace clic en "Guardar"
5. Sistema valida datos
6. Sistema crea usuario en BD
7. Sistema muestra mensaje "Usuario creado"
8. Sistema actualiza lista de usuarios

**Flujos Alternativos:**
- **3a.** Email ya existe
  - Sistema muestra error "Ya existe un usuario con ese email"
  - Retorna al paso 3

- **5a.** Email inválido
  - Sistema muestra error "Email inválido"
  - Retorna al paso 3

---

### 10.2 Caso de Uso: Asignación de Vehículo a Ruta

**Actor:** Administrador

**Precondiciones:**
- Existen vehículos disponibles
- Existen conductores registrados
- Existe al menos un cliente

**Flujo Principal:**
1. Admin navega a "Rutas"
2. Admin hace clic en "Nueva Ruta"
3. Sistema carga datos:
   - Lista de clientes
   - Lista de conductores
   - Lista de vehículos
4. Admin ingresa:
   - Código: R-003
   - Nombre: Ruta Centro
   - Cliente: María García
   - Conductor: Celico Homez
   - Vehículo: ABC123 - Chevrolet NPRS
   - Prioridad: Alta
   - Fecha: 2025-11-28
5. Admin hace clic en "Guardar"
6. Sistema crea ruta con asignaciones
7. Sistema actualiza estado del vehículo a "en_ruta"
8. Sistema muestra mensaje "Ruta creada"

**Postcondiciones:**
- Ruta creada en BD
- Vehículo marcado como "en_ruta"
- Conductor asignado a ruta

---

## 11. DIAGRAMAS UML

### 11.1 Diagrama de Clases (Backend)

```
┌─────────────────────────────────────────────────────┐
│                      Usuario                         │
├─────────────────────────────────────────────────────┤
│ - id: int                                           │
│ - rol_id: int                                       │
│ - email: string                                     │
│ - password: string (hashed)                         │
│ - nombre_completo: string                           │
│ - telefono: string                                  │
│ - direccion: string                                 │
├─────────────────────────────────────────────────────┤
│ + __init__(email, password, rol_id)                │
│ + to_dict(): dict                                   │
│ + check_password(password): bool                    │
└──────────────┬──────────────────────────────────────┘
               │
               │ 1:N
               │
┌──────────────▼──────────────────────────────────────┐
│                    Vehiculo                          │
├─────────────────────────────────────────────────────┤
│ - id: int                                           │
│ - placa: string (UNIQUE)                            │
│ - marca: string                                     │
│ - modelo: string                                    │
│ - anio: int                                         │
│ - capacidad_kg: decimal                             │
│ - volumen_m3: decimal                               │
│ - estado: string                                    │
│ - conductor_id: int (FK → Usuario)                  │
├─────────────────────────────────────────────────────┤
│ + __init__(placa)                                   │
│ + asignar_conductor(conductor_id)                   │
│ + cambiar_estado(nuevo_estado)                      │
│ + to_dict(): dict                                   │
└─────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────┐
│                      Ruta                            │
├─────────────────────────────────────────────────────┤
│ - id: int                                           │
│ - codigo: string (UNIQUE)                           │
│ - nombre: string                                    │
│ - descripcion: string                               │
│ - estado: string                                    │
│ - prioridad: int (1=baja, 2=media, 3=alta)         │
│ - fecha_programada: date                            │
│ - hora_inicio: time                                 │
│ - hora_fin: time                                    │
│ - cliente_id: int (FK → Usuario)                    │
│ - conductor_id: int (FK → Usuario)                  │
│ - vehiculo_id: int (FK → Vehiculo)                  │
│ - meta: JSON                                        │
├─────────────────────────────────────────────────────┤
│ + __init__(codigo, nombre)                          │
│ + asignar_recursos(cliente, conductor, vehiculo)   │
│ + cambiar_estado(nuevo_estado)                      │
│ + to_dict(): dict                                   │
└─────────────────────────────────────────────────────┘
```

---

### 11.2 Diagrama de Componentes

```
┌───────────────────────────────────────────────────────────────┐
│                     SISTEMA TRADEX                             │
│                                                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │          COMPONENTE FRONTEND (Flutter)              │    │
│  │                                                     │    │
│  │  ┌──────────────┐  ┌──────────────┐               │    │
│  │  │  UI Layer    │  │  Service     │               │    │
│  │  │              │  │  Layer       │               │    │
│  │  │ - Login      │  │              │               │    │
│  │  │ - Dashboard  │  │ - Api.dart   │               │    │
│  │  │ - Usuarios   │◄─┤              │               │    │
│  │  │ - Vehículos  │  │ - Session    │               │    │
│  │  │ - Rutas      │  │              │               │    │
│  │  └──────────────┘  └──────┬───────┘               │    │
│  │                            │                       │    │
│  └────────────────────────────┼───────────────────────┘    │
│                               │                            │
│                               │ HTTP/JSON                  │
│                               │ (REST API)                 │
│  ┌────────────────────────────▼───────────────────────┐    │
│  │        COMPONENTE BACKEND (Flask)                  │    │
│  │                                                     │    │
│  │  ┌──────────────┐  ┌──────────────┐               │    │
│  │  │ Controllers  │  │   Models     │               │    │
│  │  │              │  │              │               │    │
│  │  │ - routes.py  │◄─┤ - Usuario    │               │    │
│  │  │              │  │ - Vehiculo   │               │    │
│  │  │ - auth       │  │ - Ruta       │               │    │
│  │  └──────┬───────┘  └──────┬───────┘               │    │
│  │         │                 │                        │    │
│  │         │  ┌──────────────▼───────┐               │    │
│  │         │  │   Extensions         │               │    │
│  │         └─►│                      │               │    │
│  │            │ - db (SQLAlchemy)    │               │    │
│  │            │ - jwt_manager        │               │    │
│  │            │ - cors               │               │    │
│  │            └──────────┬───────────┘               │    │
│  └───────────────────────┼───────────────────────────┘    │
│                          │                                │
│                          │ SQL                            │
│  ┌───────────────────────▼───────────────────────────┐    │
│  │      COMPONENTE BASE DE DATOS (MySQL)             │    │
│  │                                                     │    │
│  │  ┌──────────┐  ┌───────────┐  ┌──────────┐       │    │
│  │  │  roles   │  │ usuarios  │  │vehiculos │       │    │
│  │  └────┬─────┘  └─────┬─────┘  └────┬─────┘       │    │
│  │       │              │              │             │    │
│  │       └──────────────┴──────────────┴─────┐       │    │
│  │                                            │       │    │
│  │                      ┌─────────────────────▼─┐     │    │
│  │                      │       rutas          │     │    │
│  │                      └──────────────────────┘     │    │
│  └─────────────────────────────────────────────────┘    │
└───────────────────────────────────────────────────────────┘
```

---

### 11.3 Diagrama de Despliegue

```
┌──────────────────────────────────────────────────────┐
│              MÁQUINA CLIENTE                          │
│                                                       │
│  ┌────────────────────────────────────────────┐     │
│  │         Navegador Web (Chrome)             │     │
│  │                                            │     │
│  │  ┌──────────────────────────────────┐     │     │
│  │  │   Aplicación Flutter Web         │     │     │
│  │  │   (Puerto 8080)                  │     │     │
│  │  │                                  │     │     │
│  │  │  - HTML/CSS/JavaScript           │     │     │
│  │  │  - WebAssembly (Dart)            │     │     │
│  │  └──────────────────────────────────┘     │     │
│  └────────────────────────────────────────────┘     │
└────────────┬─────────────────────────────────────────┘
             │
             │ HTTP Request/Response
             │ (JSON)
             │
┌────────────▼─────────────────────────────────────────┐
│            SERVIDOR DE APLICACIÓN                     │
│            (localhost / 127.0.0.1)                    │
│                                                       │
│  ┌────────────────────────────────────────────┐     │
│  │        Flask Application Server            │     │
│  │        (Puerto 5000)                       │     │
│  │                                            │     │
│  │  - API REST                                │     │
│  │  - Autenticación JWT                       │     │
│  │  - Lógica de negocio                       │     │
│  │  - Validaciones                            │     │
│  └────────────┬───────────────────────────────┘     │
│               │                                      │
│               │ SQLAlchemy ORM                       │
│               │ (pymysql driver)                     │
│  ┌────────────▼───────────────────────────────┐     │
│  │        MySQL Server (XAMPP)                │     │
│  │        (Puerto 3306)                       │     │
│  │                                            │     │
│  │  Database: tradex2                         │     │
│  │  - roles                                   │     │
│  │  - usuarios                                │     │
│  │  - vehiculos                               │     │
│  │  - rutas                                   │     │
│  │  - rutas_paradas                           │     │
│  │  - rutas_asignaciones                      │     │
│  └────────────────────────────────────────────┘     │
└──────────────────────────────────────────────────────┘
```

---

## 12. GUÍA DE INSTALACIÓN Y EJECUCIÓN

### 12.1 Requisitos Previos

**Software necesario:**
- Python 3.8 o superior
- Flutter SDK 3.9.2
- MySQL 8.x (XAMPP recomendado)
- Git (opcional)

---

### 12.2 Configuración del Backend

**Paso 1:** Instalar dependencias
```bash
cd c:\taller\tradex\apitradex
python -m pip install -r requirements.txt
```

**Paso 2:** Configurar base de datos
```bash
# Iniciar MySQL en XAMPP
# Usuario: root
# Password: 041124
# Base de datos: tradex2

python setup_db.py
```

**Paso 3:** Ejecutar servidor
```bash
python run.py
```

Servidor corriendo en: `http://127.0.0.1:5000`

---

### 12.3 Configuración del Frontend

**Paso 1:** Instalar dependencias
```bash
cd c:\taller\tradex\tradex
flutter pub get
```

**Paso 2:** Ejecutar aplicación
```bash
flutter run -d chrome --web-port=8080
```

Aplicación disponible en: `http://localhost:8080`

---

### 12.4 Credenciales de Prueba

**Administrador:**
- Email: admin@tradex.com
- Password: 123456

**Cliente:**
- Email: maria.garcia@example.com
- Password: cliente123

**Conductor:**
- Email: celico.homez@example.com
- Password: conductor123

---

## 13. CONCLUSIONES

### 13.1 Funcionalidades Implementadas

✅ **CRUD Completo de Usuarios**
- Crear, listar, editar y eliminar usuarios
- Asignación de roles (Administrador, Cliente, Conductor)
- Validación de email único
- Hash de passwords

✅ **CRUD Completo de Vehículos**
- Gestión de flota vehicular
- Asignación de conductores
- Control de estados (disponible, en_ruta, mantenimiento)
- Validación de placa única

✅ **CRUD Completo de Rutas**
- Planificación de rutas de transporte
- Asignación múltiple (cliente, conductor, vehículo)
- Gestión de prioridades
- Programación de fechas y horarios

✅ **Características Adicionales**
- Dashboard administrativo
- Autenticación JWT
- Paginación de resultados
- Filtros dinámicos
- Validaciones frontend y backend
- Mensajes de error descriptivos
- Interfaz responsiva

---

### 13.2 Ventajas del Sistema

1. **Arquitectura Escalable:** Separación clara entre frontend y backend
2. **API REST:** Permite integraciones futuras
3. **Seguridad:** JWT, hash de passwords, validaciones
4. **User Experience:** Interfaz intuitiva y responsive
5. **Relaciones de Datos:** Integridad referencial garantizada
6. **Mantenibilidad:** Código organizado y documentado

---

### 13.3 Posibles Mejoras Futuras

- **Reportes:** Generación de PDF con estadísticas
- **Notificaciones:** Alertas en tiempo real
- **Geolocalización:** Seguimiento GPS de vehículos
- **App Móvil:** Aplicación nativa para conductores
- **Roles Avanzados:** Permisos granulares por módulo
- **Auditoría:** Log de todas las operaciones
- **Backup Automático:** Respaldo programado de BD
- **Multi-idioma:** Internacionalización (i18n)

---

## 14. REFERENCIAS

**Documentación Oficial:**
- Flask: https://flask.palletsprojects.com/
- SQLAlchemy: https://docs.sqlalchemy.org/
- Flutter: https://flutter.dev/docs
- MySQL: https://dev.mysql.com/doc/

**Librerías Utilizadas:**
- Flask-CORS: https://flask-cors.readthedocs.io/
- Flask-JWT-Extended: https://flask-jwt-extended.readthedocs.io/
- PyMySQL: https://pymysql.readthedocs.io/

---

## ANEXOS

### A. Estructura de Directorios Completa

```
c:\taller\tradex\
│
├── apitradex/                    # Backend Flask
│   ├── app/
│   │   ├── __init__.py          # Inicialización de Flask
│   │   ├── extensions.py        # SQLAlchemy, JWT, CORS
│   │   ├── models.py            # Modelos de BD
│   │   └── routes.py            # Endpoints API (769 líneas)
│   ├── instance/                # Archivos de instancia
│   ├── requirements.txt         # Dependencias Python
│   ├── run.py                   # Script de ejecución
│   └── setup_db.py              # Script de setup BD
│
└── tradex/                       # Frontend Flutter
    ├── lib/
    │   ├── main.dart
    │   ├── login_page.dart
    │   ├── session.dart
    │   ├── auth_forms.dart
    │   ├── services/
    │   │   └── api.dart         # Cliente HTTP
    │   └── administrador/
    │       ├── admin_dashboard_page.dart
    │       ├── admin_usuarios_page.dart
    │       ├── admin_vehiculos_page.dart
    │       ├── admin_rutas_page.dart
    │       └── sidebar_admin.dart
    ├── web/
    ├── android/
    ├── ios/
    ├── pubspec.yaml             # Dependencias Flutter
    └── README.md
```

---

### B. Variables de Entorno (.env)

```env
# Base de datos
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=041124
DB_NAME=tradex2

# JWT
JWT_SECRET_KEY=tu_clave_secreta_super_segura_aqui

# Flask
FLASK_APP=run.py
FLASK_ENV=development
FLASK_DEBUG=1
```

---

### C. Comandos Útiles

**Backend:**
```bash
# Instalar dependencias
pip install -r requirements.txt

# Crear base de datos
python setup_db.py

# Ejecutar servidor
python run.py

# Ejecutar en producción
gunicorn -w 4 -b 0.0.0.0:5000 run:app
```

**Frontend:**
```bash
# Instalar dependencias
flutter pub get

# Ejecutar en Chrome
flutter run -d chrome --web-port=8080

# Build para producción
flutter build web

# Limpiar cache
flutter clean
```

**Base de Datos:**
```sql
-- Verificar tablas
SHOW TABLES;

-- Ver estructura
DESCRIBE usuarios;

-- Contar registros
SELECT COUNT(*) FROM usuarios;

-- Consultas útiles
SELECT u.*, r.nombre as rol FROM usuarios u
JOIN roles r ON u.rol_id = r.id;

SELECT v.*, u.nombre_completo as conductor FROM vehiculos v
LEFT JOIN usuarios u ON v.conductor_id = u.id;
```

---

**FIN DE LA DOCUMENTACIÓN**

---

**Autor:** Sistema TRADEX
**Versión:** 1.0
**Fecha:** Noviembre 2025
**Institución:** [Nombre de tu institución]
**Curso:** [Nombre del curso]
