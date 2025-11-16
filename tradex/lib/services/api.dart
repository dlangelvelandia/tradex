import 'dart:convert';
import 'package:http/http.dart' as http;
import '../env.dart';

class ApiError implements Exception {
  final String message;
  final int? statusCode;
  ApiError(this.message, {this.statusCode});
  @override
  String toString() => 'ApiError(${statusCode ?? '-'}) $message';
}

class Api {
  // --- Helpers --------------------------------------------------------------
  static Map<String, dynamic> _normalizeToMap(String body) {
    if (body.isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    return <String, dynamic>{'data': decoded};
  }

  static Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, String>? params,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$kApiBase$path').replace(queryParameters: params);
    final res = await http.get(uri, headers: {
      'Accept': 'application/json',
      ...?headers,
    });
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return _normalizeToMap(res.body);
    }
    throw ApiError('GET $path -> ${res.statusCode}: ${res.body}',
        statusCode: res.statusCode);
  }

  static Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$kApiBase$path');
    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        ...?headers,
      },
      body: jsonEncode(body),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return _normalizeToMap(res.body);
    }
    throw ApiError('POST $path -> ${res.statusCode}: ${res.body}',
        statusCode: res.statusCode);
  }

  // --- AUTH -----------------------------------------------------------
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final resp = await _post('/login', {'email': email, 'password': password});
    return resp;
  }

  // --- USUARIOS -------------------------------------------------------
  static Future<Map<String, dynamic>> crearUsuario({
    required String nombre,
    required String email,
    String? telefono,
    required String password,
    required String rol,
  }) {
    return _post('/usuarios', {
      'nombre_completo': nombre,
      'email': email,
      'telefono': telefono,
      'password': password,
      'rol': rol,
    });
  }

  static Future<List<Map<String, dynamic>>> listarUsuariosPorRol(String rol,
      {int perPage = 50, int page = 1}) async {
    final resp = await _get('/usuarios', params: {
      'rol': rol,
      'per_page': '$perPage',
      'page': '$page',
    });
    final list = (resp['data'] ?? []) as List;
    return list.cast<Map>().map((e) => e.cast<String, dynamic>()).toList();
  }

  // --- VEHÍCULOS ------------------------------------------------------
  static Future<Map<String, dynamic>> listarVehiculos({
    int? conductorId,
    String? estado,
    int perPage = 50,
    int page = 1,
  }) {
    return _get('/vehiculos', params: {
      if (conductorId != null) 'conductor_id': '$conductorId',
      if (estado != null) 'estado': estado,
      'per_page': '$perPage',
      'page': '$page',
    });
  }

  static Future<Map<String, dynamic>> crearVehiculo({
    required String placa,
    String? marca,
    String? modelo,
    int? anio,
    double? capacidadKg,
    double? volumenM3,
    String estado = 'disponible', // o 'activo' según tu preferencia
    int? conductorId,            // asignación directa al conductor
  }) {
    return _post('/vehiculos', {
      'placa': placa,
      if (marca != null && marca.trim().isNotEmpty) 'marca': marca.trim(),
      if (modelo != null && modelo.trim().isNotEmpty) 'modelo': modelo.trim(),
      if (anio != null) 'anio': anio,
      if (capacidadKg != null) 'capacidad_kg': capacidadKg,
      if (volumenM3 != null) 'volumen_m3': volumenM3,
      'estado': estado,
      if (conductorId != null) 'conductor_id': conductorId,
    });
  }

  /// Helper: trae el primer vehículo asignado a un conductor (o null si no hay).
  static Future<Map<String, dynamic>?> obtenerVehiculoDeConductor(int conductorId) async {
    final r = await listarVehiculos(conductorId: conductorId, perPage: 1, page: 1);
    final list = (r['data'] as List?) ?? const [];
    if (list.isEmpty) return null;
    return (list.first as Map).cast<String, dynamic>();
  }

  // --- RUTAS ----------------------------------------------------------
  static Future<Map<String, dynamic>> crearRuta({
    required String codigo,
    required String nombre,
    int? clienteId,
    int? creadoPor,
    String? descripcion,
    String estado = 'planificada',
    String? fechaProgramada, // 'YYYY-MM-DD'
    String? horaInicio,      // 'HH:mm'
    int? conductorId,
    int? vehiculoId,
    Map<String, dynamic>? meta, // carga: peso/volumen/tipo
  }) {
    return _post('/rutas', {
      'codigo': codigo,
      'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
      'estado': estado,
      if (fechaProgramada != null) 'fecha_programada': fechaProgramada,
      if (horaInicio != null) 'hora_inicio': horaInicio,
      if (clienteId != null) 'cliente_id': clienteId,
      if (creadoPor != null) 'creado_por': creadoPor,
      if (conductorId != null) 'conductor_id': conductorId,
      if (vehiculoId != null) 'vehiculo_id': vehiculoId,
      if (meta != null) 'meta': meta,
    });
  }

  static Future<Map<String, dynamic>> agregarParada({
    required int rutaId,
    required int orden,
    required double lat,
    required double lng,
    String? titulo,
    String? direccion,
    String? notas,
  }) {
    return _post('/rutas/$rutaId/paradas', {
      'orden': orden,
      'lat': lat,
      'lng': lng,
      if (titulo != null) 'titulo': titulo,
      if (direccion != null) 'direccion': direccion,
      if (notas != null) 'notas': notas,
    });
  }

  static Future<Map<String, dynamic>> asignarRuta({
    required int rutaId,
    int? conductorId,
    int? vehiculoId,
    int? asignadoPor,
    String? comentario,
  }) {
    return _post('/rutas/$rutaId/asignar', {
      if (conductorId != null) 'conductor_id': conductorId,
      if (vehiculoId != null) 'vehiculo_id': vehiculoId,
      if (asignadoPor != null) 'asignado_por': asignadoPor,
      if (comentario != null) 'comentario': comentario,
    });
  }

  static Future<Map<String, dynamic>> listarRutasCliente(
    int clienteId, {
    int perPage = 50,
    int page = 1,
    String? estado,
  }) {
    return _get('/rutas', params: {
      'cliente_id': '$clienteId',
      if (estado != null) 'estado': estado,
      'per_page': '$perPage',
      'page': '$page',
    });
  }

  static Future<Map<String, dynamic>> listarRutasConductor(
    int conductorId, {
    int perPage = 50,
    int page = 1,
    String? estado,
  }) {
    return _get('/rutas', params: {
      'conductor_id': '$conductorId',
      if (estado != null) 'estado': estado,
      'per_page': '$perPage',
      'page': '$page',
    });
  }

  static Future<Map<String, dynamic>> geojsonRuta(int rutaId) {
    return _get('/rutas/$rutaId/geojson');
  }

  // --- PASSWORD -------------------------------------------------------
  static Future<Map<String, dynamic>> forgotPassword(String email) {
    return _post('/forgot-password', {'email': email});
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) {
    return _post('/reset-password', {'token': token, 'password': newPassword});
  }


  // --- RUTAS: actualizar estado --------------------------------------
  static Future<Map<String, dynamic>> actualizarEstadoRuta({
    required int rutaId,
    required String estado, // 'planificada' | 'en_progreso' | 'completada' | 'cancelada'
  }) {
    return _post('/rutas/$rutaId/estado', {'estado': estado});
  }
}
