from .extensions import db
from sqlalchemy.dialects.mysql import DECIMAL


# ============================================================
#  ROLES
# ============================================================
class Rol(db.Model):
    __tablename__ = "roles"

    id = db.Column(db.Integer, primary_key=True)
    nombre = db.Column(db.String(30), unique=True, nullable=False)


# ============================================================
#  USUARIOS
# ============================================================
class Usuario(db.Model):
    __tablename__ = "usuarios"

    id = db.Column(db.Integer, primary_key=True)
    nombre_completo = db.Column(db.String(120), nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    telefono = db.Column(db.String(20))
    password_hash = db.Column(db.Text, nullable=False)
    role_id = db.Column(
        db.Integer,
        db.ForeignKey("roles.id", onupdate="CASCADE", ondelete="RESTRICT"),
        nullable=False
    )
    activo = db.Column(db.Boolean, default=True, nullable=False)

    rol = db.relationship("Rol")


# ============================================================
#  VEHICULOS
# ============================================================
class Vehiculo(db.Model):
    __tablename__ = "vehiculos"

    id = db.Column(db.Integer, primary_key=True)
    placa = db.Column(db.String(15), unique=True, nullable=False)
    marca = db.Column(db.String(50))
    modelo = db.Column(db.String(50))
    anio = db.Column(db.Integer)
    capacidad_kg = db.Column(DECIMAL(10, 2))
    volumen_m3 = db.Column(DECIMAL(10, 3))
    estado = db.Column(db.String(20), default="disponible", nullable=False)

    # Relación 1:1 conductor → vehículo
    conductor_id = db.Column(
        db.Integer,
        db.ForeignKey("usuarios.id", onupdate="CASCADE", ondelete="SET NULL"),
        unique=True
    )
    conductor = db.relationship("Usuario", foreign_keys=[conductor_id])


# ============================================================
#  RUTAS
# ============================================================
class Ruta(db.Model):
    __tablename__ = "rutas"

    id = db.Column(db.Integer, primary_key=True)
    codigo = db.Column(db.String(50), unique=True, nullable=False)
    nombre = db.Column(db.String(120), nullable=False)
    descripcion = db.Column(db.Text)
    estado = db.Column(db.String(20), default="planificada", nullable=False)  
    prioridad = db.Column(db.SmallInteger, default=3, nullable=False)
    fecha_programada = db.Column(db.Date)
    hora_inicio = db.Column(db.Time)
    hora_fin = db.Column(db.Time)

    cliente_id = db.Column(
        db.Integer,
        db.ForeignKey("usuarios.id", onupdate="CASCADE", ondelete="SET NULL")
    )
    creado_por = db.Column(
        db.Integer,
        db.ForeignKey("usuarios.id", onupdate="CASCADE", ondelete="SET NULL")
    )

    # Asignación actual
    conductor_id = db.Column(
        db.Integer,
        db.ForeignKey("usuarios.id", onupdate="CASCADE", ondelete="SET NULL")
    )
    vehiculo_id = db.Column(
        db.Integer,
        db.ForeignKey("vehiculos.id", onupdate="CASCADE", ondelete="SET NULL")
    )

    distancia_km = db.Column(DECIMAL(10, 3))
    duracion_estimada_min = db.Column(db.Integer)
    meta = db.Column(db.JSON)  # requiere MySQL 5.7+


# ============================================================
#  PARADAS DE RUTA
# ============================================================
class RutaParada(db.Model):
    __tablename__ = "rutas_paradas"

    id = db.Column(db.Integer, primary_key=True)
    ruta_id = db.Column(
        db.Integer,
        db.ForeignKey("rutas.id", ondelete="CASCADE"),
        nullable=False
    )
    orden = db.Column(db.Integer, nullable=False)
    titulo = db.Column(db.String(120))
    direccion = db.Column(db.Text)
    ventana_inicio = db.Column(db.String(30))
    ventana_fin = db.Column(db.String(30))
    notas = db.Column(db.Text)

    lat = db.Column(DECIMAL(10, 6), nullable=False)
    lng = db.Column(DECIMAL(10, 6), nullable=False)

    __table_args__ = (
        db.UniqueConstraint('ruta_id', 'orden', name='uq_ruta_orden'),
    )


# ============================================================
#  HISTORIAL DE ASIGNACIONES
# ============================================================
class RutaAsignacion(db.Model):
    __tablename__ = "rutas_asignaciones"

    id = db.Column(db.Integer, primary_key=True)
    ruta_id = db.Column(
        db.Integer,
        db.ForeignKey("rutas.id", ondelete="CASCADE"),
        nullable=False
    )
    conductor_id = db.Column(
        db.Integer,
        db.ForeignKey("usuarios.id"),
        nullable=False
    )
    vehiculo_id = db.Column(
        db.Integer,
        db.ForeignKey("vehiculos.id")
    )
    asignado_por = db.Column(
        db.Integer,
        db.ForeignKey("usuarios.id")
    )
    comentario = db.Column(db.Text)
    asignado_en_iso = db.Column(db.String(30))
