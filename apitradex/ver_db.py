"""Script para visualizar el contenido de la base de datos"""
from app import create_app, db
from app.models import Rol, Usuario, Vehiculo, Ruta, RutaParada, RutaAsignacion

app = create_app()

with app.app_context():
    print("=" * 60)
    print("CONTENIDO DE LA BASE DE DATOS TRADEX")
    print("=" * 60)
    
    # ROLES
    print("\n📋 ROLES:")
    print("-" * 60)
    roles = Rol.query.all()
    if roles:
        for r in roles:
            print(f"  ID: {r.id} | Nombre: {r.nombre}")
    else:
        print("  (vacío)")
    
    # USUARIOS
    print("\n👤 USUARIOS:")
    print("-" * 60)
    usuarios = Usuario.query.all()
    if usuarios:
        for u in usuarios:
            print(f"  ID: {u.id} | {u.nombre_completo}")
            print(f"      Email: {u.email}")
            print(f"      Rol: {u.rol.nombre if u.rol else 'N/A'}")
            print(f"      Activo: {'Sí' if u.activo else 'No'}")
            print()
    else:
        print("  (vacío)")
    
    # VEHÍCULOS
    print("\n🚛 VEHÍCULOS:")
    print("-" * 60)
    vehiculos = Vehiculo.query.all()
    if vehiculos:
        for v in vehiculos:
            print(f"  ID: {v.id} | Placa: {v.placa}")
            print(f"      Marca/Modelo: {v.marca} {v.modelo} ({v.anio})")
            print(f"      Estado: {v.estado}")
            if v.conductor:
                print(f"      Conductor: {v.conductor.nombre_completo}")
            print()
    else:
        print("  (vacío)")
    
    # RUTAS
    print("\n🗺️  RUTAS:")
    print("-" * 60)
    rutas = Ruta.query.all()
    if rutas:
        for r in rutas:
            print(f"  ID: {r.id} | Código: {r.codigo}")
            print(f"      Nombre: {r.nombre}")
            print(f"      Estado: {r.estado}")
            print(f"      Fecha: {r.fecha_programada}")
            if r.conductor_id:
                conductor = Usuario.query.get(r.conductor_id)
                print(f"      Conductor: {conductor.nombre_completo if conductor else 'N/A'}")
            
            # Paradas
            paradas = RutaParada.query.filter_by(ruta_id=r.id).order_by(RutaParada.orden).all()
            if paradas:
                print(f"      Paradas ({len(paradas)}):")
                for p in paradas:
                    print(f"        {p.orden}. {p.titulo} - {p.direccion}")
            print()
    else:
        print("  (vacío)")
    
    # RESUMEN
    print("\n" + "=" * 60)
    print("RESUMEN:")
    print(f"  Roles: {Rol.query.count()}")
    print(f"  Usuarios: {Usuario.query.count()}")
    print(f"  Vehículos: {Vehiculo.query.count()}")
    print(f"  Rutas: {Ruta.query.count()}")
    print(f"  Paradas: {RutaParada.query.count()}")
    print(f"  Asignaciones: {RutaAsignacion.query.count()}")
    print("=" * 60)
