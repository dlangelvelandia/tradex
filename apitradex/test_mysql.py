"""Script para probar la conexión a MySQL"""
import pymysql

try:
    # Intentar conectar sin especificar base de datos
    conn = pymysql.connect(
        host='localhost',
        user='root',
        password='',
        port=3306
    )
    print("✅ Conexión a MySQL exitosa!")
    
    cursor = conn.cursor()
    cursor.execute("SHOW DATABASES")
    databases = cursor.fetchall()
    
    print("\n📁 Bases de datos disponibles:")
    for db in databases:
        print(f"  - {db[0]}")
    
    # Verificar si existe tradex2
    cursor.execute("SHOW DATABASES LIKE 'tradex2'")
    exists = cursor.fetchone()
    
    if exists:
        print("\n✅ La base de datos 'tradex2' existe!")
        
        # Conectar a tradex2 y ver tablas
        conn.select_db('tradex2')
        cursor.execute("SHOW TABLES")
        tables = cursor.fetchall()
        
        if tables:
            print("\n📋 Tablas en 'tradex2':")
            for table in tables:
                print(f"  - {table[0]}")
        else:
            print("\n⚠️  La base de datos 'tradex2' está vacía (sin tablas)")
    else:
        print("\n❌ La base de datos 'tradex2' NO existe")
        print("\n💡 Para crearla, ejecuta en MySQL:")
        print("   CREATE DATABASE tradex2 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;")
    
    conn.close()
    
except pymysql.err.OperationalError as e:
    if e.args[0] == 1045:
        print("❌ Error de autenticación")
        print("El usuario 'root' requiere contraseña.")
        print("\n💡 Opciones:")
        print("1. Configura MySQL sin contraseña para root")
        print("2. O actualiza la configuración con tu contraseña")
    else:
        print(f"❌ Error de conexión: {e}")
except Exception as e:
    print(f"❌ Error: {e}")
