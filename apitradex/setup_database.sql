-- ============================================================
-- SCRIPT DE CREACIÓN DE BASE DE DATOS TRADEX2
-- ============================================================

-- Crear base de datos
CREATE DATABASE IF NOT EXISTS tradex2 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE tradex2;

-- ============================================================
-- TABLA: ROLES
-- ============================================================
CREATE TABLE IF NOT EXISTS roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(30) UNIQUE NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLA: USUARIOS
-- ============================================================
CREATE TABLE IF NOT EXISTS usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre_completo VARCHAR(120) NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    telefono VARCHAR(20),
    password_hash TEXT NOT NULL,
    role_id INT NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    FOREIGN KEY (role_id) REFERENCES roles(id) 
        ON UPDATE CASCADE 
        ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLA: VEHICULOS
-- ============================================================
CREATE TABLE IF NOT EXISTS vehiculos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    placa VARCHAR(15) UNIQUE NOT NULL,
    marca VARCHAR(50),
    modelo VARCHAR(50),
    anio INT,
    capacidad_kg DECIMAL(10,2),
    volumen_m3 DECIMAL(10,3),
    estado VARCHAR(20) NOT NULL DEFAULT 'disponible',
    conductor_id INT UNIQUE,
    FOREIGN KEY (conductor_id) REFERENCES usuarios(id) 
        ON UPDATE CASCADE 
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLA: RUTAS
-- ============================================================
CREATE TABLE IF NOT EXISTS rutas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(50) UNIQUE NOT NULL,
    nombre VARCHAR(120) NOT NULL,
    descripcion TEXT,
    estado VARCHAR(20) NOT NULL DEFAULT 'planificada',
    prioridad SMALLINT NOT NULL DEFAULT 3,
    fecha_programada DATE,
    hora_inicio TIME,
    hora_fin TIME,
    cliente_id INT,
    creado_por INT,
    conductor_id INT,
    vehiculo_id INT,
    distancia_km DECIMAL(10,3),
    duracion_estimada_min INT,
    meta JSON,
    FOREIGN KEY (cliente_id) REFERENCES usuarios(id) 
        ON UPDATE CASCADE 
        ON DELETE SET NULL,
    FOREIGN KEY (creado_por) REFERENCES usuarios(id) 
        ON UPDATE CASCADE 
        ON DELETE SET NULL,
    FOREIGN KEY (conductor_id) REFERENCES usuarios(id) 
        ON UPDATE CASCADE 
        ON DELETE SET NULL,
    FOREIGN KEY (vehiculo_id) REFERENCES vehiculos(id) 
        ON UPDATE CASCADE 
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLA: PARADAS DE RUTA
-- ============================================================
CREATE TABLE IF NOT EXISTS rutas_paradas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ruta_id INT NOT NULL,
    orden INT NOT NULL,
    titulo VARCHAR(120),
    direccion TEXT,
    ventana_inicio VARCHAR(30),
    ventana_fin VARCHAR(30),
    notas TEXT,
    lat DECIMAL(10,6) NOT NULL,
    lng DECIMAL(10,6) NOT NULL,
    FOREIGN KEY (ruta_id) REFERENCES rutas(id) 
        ON DELETE CASCADE,
    CONSTRAINT uq_ruta_orden UNIQUE (ruta_id, orden)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TABLA: HISTORIAL DE ASIGNACIONES
-- ============================================================
CREATE TABLE IF NOT EXISTS rutas_asignaciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ruta_id INT NOT NULL,
    conductor_id INT NOT NULL,
    vehiculo_id INT,
    asignado_por INT,
    comentario TEXT,
    asignado_en_iso VARCHAR(30),
    FOREIGN KEY (ruta_id) REFERENCES rutas(id) 
        ON DELETE CASCADE,
    FOREIGN KEY (conductor_id) REFERENCES usuarios(id),
    FOREIGN KEY (vehiculo_id) REFERENCES vehiculos(id),
    FOREIGN KEY (asignado_por) REFERENCES usuarios(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- DATOS INICIALES: ROLES
-- ============================================================
INSERT INTO roles (nombre) VALUES 
    ('Admin'),
    ('Cliente'),
    ('Conductor')
ON DUPLICATE KEY UPDATE nombre=nombre;

-- ============================================================
-- DATOS DE PRUEBA: USUARIOS
-- ============================================================
-- Password para todos: "123456" (hasheado con werkzeug)
INSERT INTO usuarios (nombre_completo, email, telefono, password_hash, role_id, activo) VALUES
    ('Administrador Principal', 'admin@tradex.com', '3001234567', 'pbkdf2:sha256:600000$salt123$hash123', 1, TRUE),
    ('Juan Pérez', 'conductor1@tradex.com', '3007654321', 'pbkdf2:sha256:600000$salt123$hash123', 3, TRUE),
    ('María García', 'conductor2@tradex.com', '3009876543', 'pbkdf2:sha256:600000$salt123$hash123', 3, TRUE),
    ('Cliente Demo', 'cliente@empresa.com', '3001112222', 'pbkdf2:sha256:600000$salt123$hash123', 2, TRUE)
ON DUPLICATE KEY UPDATE nombre_completo=nombre_completo;

-- ============================================================
-- DATOS DE PRUEBA: VEHÍCULOS
-- ============================================================
INSERT INTO vehiculos (placa, marca, modelo, anio, capacidad_kg, volumen_m3, estado, conductor_id) VALUES
    ('ABC123', 'Chevrolet', 'NPR', 2022, 3500.00, 15.000, 'disponible', NULL),
    ('XYZ789', 'Ford', 'Cargo', 2021, 2500.00, 12.000, 'disponible', NULL),
    ('DEF456', 'Hino', '300', 2023, 4000.00, 18.000, 'disponible', NULL)
ON DUPLICATE KEY UPDATE placa=placa;

-- ============================================================
-- DATOS DE PRUEBA: RUTAS
-- ============================================================
INSERT INTO rutas (codigo, nombre, descripcion, estado, prioridad, fecha_programada, hora_inicio, hora_fin) VALUES
    ('R-001', 'Ruta Norte', 'Distribución zona norte de la ciudad', 'planificada', 1, '2025-11-26', '08:00:00', '14:00:00'),
    ('R-002', 'Ruta Sur', 'Entregas zona sur', 'en_progreso', 2, '2025-11-25', '09:00:00', '16:00:00')
ON DUPLICATE KEY UPDATE codigo=codigo;

SELECT 'Base de datos creada exitosamente' AS resultado;
