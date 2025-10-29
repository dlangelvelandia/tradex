from .extensions import db

# ===== Roles =====
class Rol(db.Model):
    __tablename__ = "roles"
    id = db.Column(db.Integer, primary_key=True)
    nombre = db.Column(db.String(30), unique=True, nullable=False)  # Admin, Cliente, Conductor

# ===== Usuarios =====
class Usuario(db.Model):
    __tablename__ = "usuarios"
    id = db.Column(db.Integer, primary_key=True)
    nombre_completo = db.Column(db.String(120), nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    telefono = db.Column(db.String(20))
    password_hash = db.Column(db.Text, nullable=False)  # ¡no guardes texto plano!
    role_id = db.Column(db.Integer, db.ForeignKey("roles.id", onupdate="CASCADE", ondelete="RESTRICT"), nullable=False)
    activo = db.Column(db.Boolean, default=True, nullable=False)

    rol = db.relationship("Rol")

# ===== Vehículos =====
class Vehiculo(db.Model):
    __tablename__ = "vehiculos"
    id = db.Column(db.Integer, primary_key=True)
    placa = db.Column(db.String(15), unique=True, nullable=False)
    marca = db.Column(db.String(50))
    modelo = db.Column(db.String(50))
    anio = db.Column(db.Integer)
    capacidad_kg = db.Column(db.Numeric(10,2))
    volumen_m3 = db.Column(db.Numeric(10,3))
    estado = db.Column(db.String(20), default="disponible", nullable=False)

    # Regla simple: 1 conductor ↔ 1 vehículo (si quieres varios, elimina unique=True)
    conductor_id = db.Column(
        db.Integer,
        db.ForeignKey("usuarios.id", onupdate="CASCADE", ondelete="SET NULL"),
        unique=True
    )
    conductor = db.relationship("Usuario")

# ===== Rutas =====
class Ruta(db.Model):
    __tablename__ = "rutas"
    id = db.Column(db.Integer, primary_key=True)
    codigo = db.Column(db.String(50), unique=True, nullable=False)
    nombre = db.Column(db.String(120), nullable=False)
    descripcion = db.Column(db.Text)
    estado = db.Column(db.String(20), default="planificada", nullable=False)  # planificada/asignada/en_curso/completada/cancelada
    prioridad = db.Column(db.SmallInteger, default=3, nullable=False)
    fecha_programada = db.Column(db.Date)
    hora_inicio = db.Column(db.Time)
    hora_fin = db.Column(db.Time)

    cliente_id = db.Column(db.Integer, db.ForeignKey("usuarios.id", onupdate="CASCADE", ondelete="SET NULL"))
    creado_por = db.Column(db.Integer, db.ForeignKey("usuarios.id", onupdate="CASCADE", ondelete="SET NULL"))

    # asignación "actual"
    conductor_id = db.Column(db.Integer, db.ForeignKey("usuarios.id", onupdate="CASCADE", ondelete="SET NULL"))
    vehiculo_id = db.Column(db.Integer, db.ForeignKey("vehiculos.id", onupdate="CASCADE", ondelete="SET NULL"))

    distancia_km = db.Column(db.Numeric(10,3))
    duracion_estimada_min = db.Column(db.Integer)
    meta = db.Column(db.JSON)  # datos libres (tipo de carga, etc.)

# ===== Paradas =====
class RutaParada(db.Model):
    __tablename__ = "rutas_paradas"
    id = db.Column(db.Integer, primary_key=True)
    ruta_id = db.Column(db.Integer, db.ForeignKey("rutas.id", ondelete="CASCADE"), nullable=False)
    orden = db.Column(db.Integer, nullable=False)  # 1..n
    titulo = db.Column(db.String(120))
    direccion = db.Column(db.Text)
    ventana_inicio = db.Column(db.String(30))  # ISO simplificado
    ventana_fin = db.Column(db.String(30))
    notas = db.Column(db.Text)

    # Geometría simple para Leaflet
    lat = db.Column(db.Numeric(10, 6), nullable=False)
    lng = db.Column(db.Numeric(10, 6), nullable=False)

    __table_args__ = (db.UniqueConstraint('ruta_id', 'orden', name='uq_ruta_orden'),)

# ===== Historial de asignaciones =====
class RutaAsignacion(db.Model):
    __tablename__ = "rutas_asignaciones"
    id = db.Column(db.Integer, primary_key=True)
    ruta_id = db.Column(db.Integer, db.ForeignKey("rutas.id", ondelete="CASCADE"), nullable=False)
    conductor_id = db.Column(db.Integer, db.ForeignKey("usuarios.id"), nullable=False)
    vehiculo_id = db.Column(db.Integer, db.ForeignKey("vehiculos.id"))
    asignado_por = db.Column(db.Integer, db.ForeignKey("usuarios.id"))
    comentario = db.Column(db.Text)
    asignado_en_iso = db.Column(db.String(30))  # fecha/hora ISO
