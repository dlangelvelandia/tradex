"""Script para ejecutar el SQL en MySQL y crear la base de datos"""
import pymysql

try:
    # Conectar a MySQL
    print("🔌 Conectando a MySQL...")
    conn = pymysql.connect(
        host='localhost',
        user='root',
        password='041124',
        port=3306
    )
    
    cursor = conn.cursor()
    print("✅ Conexión exitosa!")
    
    # Crear la base de datos
    print("\n🗄️  Creando base de datos tradex2...")
    cursor.execute("DROP DATABASE IF EXISTS tradex2")
    cursor.execute("CREATE DATABASE tradex2 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci")
    cursor.execute("USE tradex2")
    print("✅ Base de datos creada!")
    
    # Crear tablas
    print("\n📝 Creando tablas...")
    
    # Tabla roles
    cursor.execute("""
        CREATE TABLE roles (
            id INT AUTO_INCREMENT PRIMARY KEY,
            nombre VARCHAR(30) UNIQUE NOT NULL
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    """)
    
    # Tabla usuarios
    cursor.execute("""
        CREATE TABLE usuarios (
            id INT AUTO_INCREMENT PRIMARY KEY,
            nombre_completo VARCHAR(120) NOT NULL,
            email VARCHAR(120) UNIQUE NOT NULL,
            telefono VARCHAR(20),
            password_hash TEXT NOT NULL,
            role_id INT NOT NULL,
            activo BOOLEAN NOT NULL DEFAULT TRUE,
            FOREIGN KEY (role_id) REFERENCES roles(id) 
                ON UPDATE CASCADE ON DELETE RESTRICT
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    """)
    
    # Tabla vehiculos
    cursor.execute("""
        CREATE TABLE vehiculos (
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
                ON UPDATE CASCADE ON DELETE SET NULL
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    """)
    
    # Tabla rutas
    cursor.execute("""
        CREATE TABLE rutas (
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
            FOREIGN KEY (cliente_id) REFERENCES usuarios(id) ON UPDATE CASCADE ON DELETE SET NULL,
            FOREIGN KEY (creado_por) REFERENCES usuarios(id) ON UPDATE CASCADE ON DELETE SET NULL,
            FOREIGN KEY (conductor_id) REFERENCES usuarios(id) ON UPDATE CASCADE ON DELETE SET NULL,
            FOREIGN KEY (vehiculo_id) REFERENCES vehiculos(id) ON UPDATE CASCADE ON DELETE SET NULL
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    """)
    
    # Tabla rutas_paradas
    cursor.execute("""
        CREATE TABLE rutas_paradas (
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
            FOREIGN KEY (ruta_id) REFERENCES rutas(id) ON DELETE CASCADE,
            CONSTRAINT uq_ruta_orden UNIQUE (ruta_id, orden)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    """)
    
    # Tabla rutas_asignaciones
    cursor.execute("""
        CREATE TABLE rutas_asignaciones (
            id INT AUTO_INCREMENT PRIMARY KEY,
            ruta_id INT NOT NULL,
            conductor_id INT NOT NULL,
            vehiculo_id INT,
            asignado_por INT,
            comentario TEXT,
            asignado_en_iso VARCHAR(30),
            FOREIGN KEY (ruta_id) REFERENCES rutas(id) ON DELETE CASCADE,
            FOREIGN KEY (conductor_id) REFERENCES usuarios(id),
            FOREIGN KEY (vehiculo_id) REFERENCES vehiculos(id),
            FOREIGN KEY (asignado_por) REFERENCES usuarios(id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    """)
    
    print("✅ Tablas creadas!")
    
    # Insertar datos iniciales
    print("\n📥 Insertando datos iniciales...")
    
    # Roles
    cursor.execute("INSERT INTO roles (nombre) VALUES ('Admin'), ('Cliente'), ('Conductor')")
    
    # Usuarios de prueba (password: 123456)
    from werkzeug.security import generate_password_hash
    password = generate_password_hash('123456')
    
    cursor.execute("""
        INSERT INTO usuarios (nombre_completo, email, telefono, password_hash, role_id, activo) VALUES
        ('Administrador Principal', 'admin@tradex.com', '3001234567', %s, 1, TRUE),
        ('Juan Pérez', 'conductor1@tradex.com', '3007654321', %s, 3, TRUE),
        ('María García', 'conductor2@tradex.com', '3009876543', %s, 3, TRUE),
        ('Cliente Demo', 'cliente@empresa.com', '3001112222', %s, 2, TRUE)
    """, (password, password, password, password))
    
    # Vehículos de prueba
    cursor.execute("""
        INSERT INTO vehiculos (placa, marca, modelo, anio, capacidad_kg, volumen_m3, estado) VALUES
        ('ABC123', 'Chevrolet', 'NPR', 2022, 3500.00, 15.000, 'disponible'),
        ('XYZ789', 'Ford', 'Cargo', 2021, 2500.00, 12.000, 'disponible'),
        ('DEF456', 'Hino', '300', 2023, 4000.00, 18.000, 'disponible')
    """)
    
    # Rutas de prueba
    cursor.execute("""
        INSERT INTO rutas (codigo, nombre, descripcion, estado, prioridad, fecha_programada, hora_inicio, hora_fin) VALUES
        ('R-001', 'Ruta Norte', 'Distribución zona norte de la ciudad', 'planificada', 1, '2025-11-26', '08:00:00', '14:00:00'),
        ('R-002', 'Ruta Sur', 'Entregas zona sur', 'en_progreso', 2, '2025-11-25', '09:00:00', '16:00:00')
    """)
    
    conn.commit()
    print("✅ Datos insertados!")
    
    # Verificar
    print("\n📊 Verificando base de datos...")
    cursor.execute("SHOW TABLES")
    tables = cursor.fetchall()
    
    print(f"\n✅ Tablas creadas ({len(tables)}):")
    for table in tables:
        cursor.execute(f"SELECT COUNT(*) FROM {table[0]}")
        count = cursor.fetchone()[0]
        print(f"  ✓ {table[0]:25} → {count} registros")
    
    cursor.close()
    conn.close()
    
    print("\n" + "="*60)
    print("🎉 BASE DE DATOS CONFIGURADA EXITOSAMENTE!")
    print("="*60)
    print("\n📝 Credenciales de prueba:")
    print("   Email: admin@tradex.com")
    print("   Password: 123456")
    print("\n💡 Ahora ejecuta: python run.py")
    
except pymysql.err.OperationalError as e:
    if e.args[0] == 1045:
        print("❌ Error de autenticación")
        print("La contraseña es incorrecta.")
    else:
        print(f"❌ Error de conexión: {e}")
except Exception as e:
    print(f"❌ Error: {e}")
    import traceback
    traceback.print_exc()
