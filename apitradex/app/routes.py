from flask import Blueprint, request, jsonify, current_app
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime
import traceback

from .extensions import db
from .models import Rol, Usuario, Vehiculo, Ruta, RutaParada, RutaAsignacion

bp = Blueprint("api", __name__, url_prefix="/api")


# ---------- Helpers ----------
def get_json():
    # Más tolerante frente a requests sin header o vacíos
    try:
        if request.is_json:
            data = request.get_json(silent=True)
            return data if isinstance(data, dict) else (data or {})
        # intenta como JSON aunque falte header
        data = request.get_json(force=True, silent=True)
        return data if isinstance(data, dict) else (data or {})
    except Exception:
        return {}


def int_qs(name, default=None):
    try:
        return int(request.args.get(name)) if request.args.get(name) else default
    except (TypeError, ValueError):
        return default


def str_qs(name, default=None):
    v = request.args.get(name)
    return v if v is not None else default


def paginate(q, page, per_page):
    """Devuelve dict con items y meta de paginación."""
    if page is None:
        page = 1
    if per_page is None:
        per_page = 50
    p = q.paginate(page=page, per_page=per_page, error_out=False)
    return {
        "data": [i for i in p.items],
        "page": p.page,
        "per_page": p.per_page,
        "total": p.total,
        "pages": p.pages,
    }


def _nom_usuario(uid):
    if not uid:
        return None
    u = Usuario.query.get(uid)
    return u.nombre_completo if u else None


# ---------- Error handler global (mejor traza en consola) ----------
@bp.app_errorhandler(Exception)
def handle_any_error(e):
    current_app.logger.error("ERROR 500\n" + traceback.format_exc())
    return jsonify(error="internal_error", detail=str(e)), 500


# ---------- Seed básico ----------
@bp.route("/seed-roles", methods=["POST"])
def seed_roles():
    existentes = {r.nombre for r in Rol.query.all()}
    for nombre in ["Admin", "Cliente", "Conductor"]:
        if nombre not in existentes:
            db.session.add(Rol(nombre=nombre))
    db.session.commit()
    return jsonify(ok=True)


# ---------- Login seguro ----------
@bp.route("/login", methods=["POST"])
def login():
    d = get_json()
    email = (d.get("email") or "").strip().lower()
    password = d.get("password")
    if not email or not password:
        return jsonify(error="email y password son obligatorios"), 400

    u = Usuario.query.filter_by(email=email).first()
    if not u or not check_password_hash(u.password_hash, password):
        return jsonify(error="Credenciales inválidas"), 401

    rol_nombre = u.rol.nombre if getattr(u, "rol", None) else None
    return jsonify({"id": u.id, "nombre": u.nombre_completo, "rol": rol_nombre})


# ---------- Usuarios ----------
@bp.route("/usuarios", methods=["POST"])
def crear_usuario():
    data = get_json()

    rol_nombre = data.get("rol")
    rol = Rol.query.filter_by(nombre=rol_nombre).first()
    if not rol:
        return jsonify(error="Rol inválido"), 400

    raw_password = data.get("password") or data.get("password_hash")
    if not raw_password:
        return jsonify(error="Falta 'password'"), 400

    email = (data.get("email") or "").strip().lower()
    if not email:
        return jsonify(error="Falta 'email'"), 400

    # correo único
    if Usuario.query.filter_by(email=email).first():
        return jsonify(error="Email ya registrado"), 409

    u = Usuario(
        nombre_completo=data["nombre_completo"],
        email=email,
        telefono=data.get("telefono"),
        password_hash=generate_password_hash(raw_password),
        role_id=rol.id,
    )
    db.session.add(u)
    db.session.commit()
    return jsonify(id=u.id), 201


@bp.route("/usuarios", methods=["GET"])
def listar_usuarios():
    q = Usuario.query
    qtext = str_qs("q")
    rol_nombre = str_qs("rol")
    if qtext:
        like = f"%{qtext}%"
        q = q.filter(
            (Usuario.email.ilike(like)) | (Usuario.nombre_completo.ilike(like))
        )
    if rol_nombre:
        q = q.join(Rol, Usuario.role_id == Rol.id).filter(Rol.nombre == rol_nombre)

    page = int_qs("page", 1)
    per_page = int_qs("per_page", 50)
    p = q.paginate(page=page, per_page=per_page, error_out=False)

    data = []
    for u in p.items:
        rol = Rol.query.get(u.role_id)
        data.append(
            {
                "id": u.id,
                "nombre_completo": u.nombre_completo,
                "email": u.email,
                "telefono": u.telefono,
                "rol_id": u.role_id,
                "rol_nombre": rol.nombre if rol else None,
                # ojo: nunca devuelvas password_hash en un GET público
            }
        )
    return jsonify(
        {
            "data": data,
            "page": p.page,
            "per_page": p.per_page,
            "total": p.total,
            "pages": p.pages,
        }
    )


@bp.route("/usuarios/<int:usuario_id>", methods=["GET"])
def obtener_usuario(usuario_id):
    u = Usuario.query.get(usuario_id)
    if not u:
        return jsonify(error="Usuario no existe"), 404
    rol = Rol.query.get(u.role_id)
    return jsonify(
        {
            "id": u.id,
            "nombre_completo": u.nombre_completo,
            "email": u.email,
            "telefono": u.telefono,
            "rol_id": u.role_id,
            "rol_nombre": rol.nombre if rol else None,
        }
    )


# ---------- Vehículos ----------
@bp.route("/vehiculos", methods=["POST"])
def crear_vehiculo():
    d = get_json()
    placa = (d.get("placa") or "").strip().upper()
    if not placa:
        return jsonify(error="Falta 'placa'"), 400

    if Vehiculo.query.filter_by(placa=placa).first():
        return jsonify(error="Ya existe un vehículo con esa placa"), 409

    v = Vehiculo(
        placa=placa,
        marca=d.get("marca"),
        modelo=d.get("modelo"),
        anio=d.get("anio"),
        capacidad_kg=d.get("capacidad_kg"),
        volumen_m3=d.get("volumen_m3"),
        estado=d.get("estado", "disponible"),
        conductor_id=d.get("conductor_id"),
    )
    db.session.add(v)
    db.session.commit()
    return jsonify(id=v.id), 201


@bp.route("/vehiculos", methods=["GET"])
def listar_vehiculos():
    q = Vehiculo.query
    conductor_id = int_qs("conductor_id")
    estado = str_qs("estado")
    if conductor_id is not None:
        q = q.filter_by(conductor_id=conductor_id)
    if estado:
        q = q.filter_by(estado=estado)

    page = int_qs("page", 1)
    per_page = int_qs("per_page", 50)
    p = q.paginate(page=page, per_page=per_page, error_out=False)
    data = []
    for v in p.items:
        data.append(
            {
                "id": v.id,
                "placa": v.placa,
                "marca": v.marca,
                "modelo": v.modelo,
                "anio": v.anio,
                # DECIMAL -> float para que JSON no explote en MySQL
                "capacidad_kg": float(v.capacidad_kg)
                if v.capacidad_kg is not None
                else None,
                "volumen_m3": float(v.volumen_m3)
                if v.volumen_m3 is not None
                else None,
                "estado": v.estado,
                "conductor_id": v.conductor_id,
            }
        )
    return jsonify(
        {
            "data": data,
            "page": p.page,
            "per_page": p.per_page,
            "total": p.total,
            "pages": p.pages,
        }
    )


# ---------- Rutas ----------
@bp.route("/rutas", methods=["POST"])
def crear_ruta():
    d = get_json()

    # Requeridos mínimos
    if not d.get("codigo") or not d.get("nombre"):
        return jsonify(error="Faltan campos requeridos: codigo y nombre"), 400

    # Validar código único (por el UNIQUE de la BD)
    if Ruta.query.filter_by(codigo=d["codigo"]).first():
        return jsonify(error="Ya existe una ruta con ese código"), 409

    # Parseo de fecha/hora (MySQL/SQLite exigen objetos date/time)
    fecha_programada_val = None
    if d.get("fecha_programada"):
        try:
            fecha_programada_val = datetime.strptime(
                d["fecha_programada"], "%Y-%m-%d"
            ).date()
        except ValueError:
            return (
                jsonify(error="fecha_programada debe tener formato YYYY-MM-DD"),
                400,
            )

    hora_inicio_val = None
    if d.get("hora_inicio"):
        try:
            hora_inicio_val = datetime.strptime(d["hora_inicio"], "%H:%M").time()
        except ValueError:
            return jsonify(error="hora_inicio debe tener formato HH:mm"), 400

    hora_fin_val = None
    if d.get("hora_fin"):
        try:
            hora_fin_val = datetime.strptime(d["hora_fin"], "%H:%M").time()
        except ValueError:
            return jsonify(error="hora_fin debe tener formato HH:mm"), 400

    r = Ruta(
        codigo=d["codigo"],
        nombre=d["nombre"],
        descripcion=d.get("descripcion"),
        # Puedes mandar 'solicitada' desde el front si es un cliente
        estado=d.get("estado", "planificada"),
        prioridad=d.get("prioridad", 3),
        fecha_programada=fecha_programada_val,  # date
        hora_inicio=hora_inicio_val,  # time
        hora_fin=hora_fin_val,  # time
        cliente_id=d.get("cliente_id"),
        creado_por=d.get("creado_por"),
        conductor_id=d.get("conductor_id"),
        vehiculo_id=d.get("vehiculo_id"),
        distancia_km=d.get("distancia_km"),
        duracion_estimada_min=d.get("duracion_estimada_min"),
        meta=d.get("meta"),
    )
    db.session.add(r)
    db.session.commit()
    return jsonify(id=r.id), 201


@bp.route("/rutas", methods=["GET"])
def listar_rutas():
    q = Ruta.query
    cliente_id = int_qs("cliente_id")
    conductor_id = int_qs("conductor_id")
    estado = str_qs("estado")
    if cliente_id is not None:
        q = q.filter_by(cliente_id=cliente_id)
    if conductor_id is not None:
        q = q.filter_by(conductor_id=conductor_id)
    if estado:
        q = q.filter_by(estado=estado)

    page = int_qs("page", 1)
    per_page = int_qs("per_page", 50)
    p = q.paginate(page=page, per_page=per_page, error_out=False)

    data = []
    for r in p.items:
        data.append(
            {
                "id": r.id,
                "codigo": r.codigo,
                "nombre": r.nombre,
                "descripcion": r.descripcion,
                "estado": r.estado,
                "prioridad": r.prioridad,
                "fecha_programada": r.fecha_programada.isoformat()
                if r.fecha_programada
                else None,
                "hora_inicio": r.hora_inicio.strftime("%H:%M")
                if r.hora_inicio
                else None,
                "hora_fin": r.hora_fin.strftime("%H:%M") if r.hora_fin else None,
                "cliente_id": r.cliente_id,
                "cliente_nombre": _nom_usuario(r.cliente_id),
                "conductor_id": r.conductor_id,
                "conductor_nombre": _nom_usuario(r.conductor_id),
                "vehiculo_id": r.vehiculo_id,
                "meta": r.meta,
            }
        )
    return jsonify(
        {
            "data": data,
            "page": p.page,
            "per_page": p.per_page,
            "total": p.total,
            "pages": p.pages,
        }
    )


@bp.route("/rutas/<int:ruta_id>/paradas", methods=["POST"])
def agregar_parada(ruta_id):
    if not Ruta.query.get(ruta_id):
        return jsonify(error="Ruta no existe"), 404
    d = get_json()
    # lat/lng obligatorios
    if d.get("lat") is None or d.get("lng") is None:
        return jsonify(error="Faltan coordenadas: lat y lng"), 400

    p = RutaParada(
        ruta_id=ruta_id,
        orden=d.get("orden", 1),
        titulo=d.get("titulo"),
        direccion=d.get("direccion"),
        ventana_inicio=d.get("ventana_inicio"),
        ventana_fin=d.get("ventana_fin"),
        notas=d.get("notas"),
        lat=d["lat"],
        lng=d["lng"],
    )
    db.session.add(p)
    db.session.commit()
    return jsonify(id=p.id), 201


@bp.route("/rutas/<int:ruta_id>/asignar", methods=["POST"])
def asignar_ruta(ruta_id):
    r = Ruta.query.get(ruta_id)
    if not r:
        return jsonify(error="Ruta no existe"), 404
    d = get_json()
    r.conductor_id = d.get("conductor_id")
    r.vehiculo_id = d.get("vehiculo_id")
    db.session.add(
        RutaAsignacion(
            ruta_id=ruta_id,
            conductor_id=r.conductor_id,
            vehiculo_id=r.vehiculo_id,
            asignado_por=d.get("asignado_por"),
            comentario=d.get("comentario"),
            asignado_en_iso=d.get("asignado_en_iso"),
        )
    )
    db.session.commit()
    return jsonify(ok=True)


# ---------- GeoJSON para Leaflet ----------
@bp.route("/rutas/<int:ruta_id>/geojson", methods=["GET"])
def ruta_geojson(ruta_id):
    r = Ruta.query.get(ruta_id)
    if not r:
        return jsonify(error="Ruta no existe"), 404

    paradas = (
        RutaParada.query.filter_by(ruta_id=ruta_id)
        .order_by(RutaParada.orden.asc())
        .all()
    )

    features = []
    coords_linea = []
    for p in paradas:
        lng = float(p.lng)
        lat = float(p.lat)
        features.append(
            {
                "type": "Feature",
                "geometry": {"type": "Point", "coordinates": [lng, lat]},
                "properties": {
                    "id": p.id,
                    "orden": p.orden,
                    "titulo": p.titulo,
                    "direccion": p.direccion,
                    "ventana_inicio": p.ventana_inicio,
                    "ventana_fin": p.ventana_fin,
                    "notas": p.notas,
                },
            }
        )
        coords_linea.append([lng, lat])

    linea = {
        "type": "Feature",
        "geometry": {"type": "LineString", "coordinates": coords_linea},
        "properties": {"ruta_id": ruta_id, "nombre": r.nombre, "codigo": r.codigo},
    }

    return jsonify(
        {
            "ruta": {
                "id": r.id,
                "codigo": r.codigo,
                "nombre": r.nombre,
                "estado": r.estado,
            },
            "paradas": {"type": "FeatureCollection", "features": features},
            "linea": linea,
        }
    )


# ---------- Listados por rol (compat) ----------
@bp.route("/mis-rutas", methods=["GET"])
def mis_rutas():
    rol = request.args.get("rol")
    usuario_id = request.args.get("usuario_id", type=int)
    if rol == "Cliente":
        q = Ruta.query.filter_by(cliente_id=usuario_id)
    elif rol == "Conductor":
        q = Ruta.query.filter_by(conductor_id=usuario_id)
    else:
        return jsonify(error="rol debe ser Cliente o Conductor"), 400
    data = [
        {
            "id": r.id,
            "codigo": r.codigo,
            "nombre": r.nombre,
            "estado": r.estado,
        }
        for r in q.all()
    ]
    return jsonify(data)


# Cambiar estado de una ruta
@bp.route("/rutas/<int:ruta_id>/estado", methods=["POST"])
def actualizar_estado_ruta(ruta_id):
    r = Ruta.query.get(ruta_id)
    if not r:
        return jsonify(error="Ruta no existe"), 404
    d = get_json()
    nuevo = (d.get("estado") or "").strip()
    if not nuevo:
        return jsonify(error="Falta 'estado'"), 400

    # Ahora incluimos estados extra para tu flujo
    validos = {"planificada", "solicitada", "asignada", "en_progreso", "completada", "cancelada"}
    if nuevo not in validos:
        return (
            jsonify(error=f"Estado inválido. Válidos: {', '.join(sorted(validos))}"),
            400,
        )

    r.estado = nuevo
    db.session.commit()
    return jsonify(ok=True, id=r.id, estado=r.estado)
