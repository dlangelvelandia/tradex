// Archivo: lib/administrador/admin_rutas_page.dart

import 'package:flutter/material.dart';
import 'sidebar_admin.dart';
import 'package:tradex_web/services/api.dart';
import 'package:tradex_web/session.dart';

/// Modelo simple de ruta para el admin
class _RutaAdmin {
  final int id;
  final String codigo;
  final String nombre;
  final String cliente;
  final String estado;
  final String? conductor;
  final String? vehiculo;

  _RutaAdmin({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.cliente,
    required this.estado,
    this.conductor,
    this.vehiculo,
  });
}

class AdminRutasPage extends StatefulWidget {
  const AdminRutasPage({super.key});

  @override
  State<AdminRutasPage> createState() => _AdminRutasPageState();
}

class _AdminRutasPageState extends State<AdminRutasPage> {
  bool _cargando = false;
  List<_RutaAdmin> _rutas = [];
  String? _filtroEstado; // planificada/en_progreso/completada/cancelada

  @override
  void initState() {
    super.initState();
    _cargarRutas();
  }

  Future<void> _cargarRutas() async {
    setState(() => _cargando = true);
    try {
      final resp = await Api.listarRutasAdmin(
        estado: _filtroEstado,
        perPage: 200,
        page: 1,
      );
      final data = (resp['data'] ?? []) as List;

      _rutas = data.map<_RutaAdmin>((raw) {
        final m = (raw as Map).cast<String, dynamic>();
        return _RutaAdmin(
          id: (m['id'] as num).toInt(),
          codigo: m['codigo']?.toString() ?? '',
          nombre: m['nombre']?.toString() ?? '',
          cliente: m['cliente_nombre']?.toString() ?? '-',
          estado: m['estado']?.toString() ?? '',
          conductor: m['conductor_nombre']?.toString(),
          vehiculo: m['vehiculo_id'] != null
              ? m['vehiculo_id'].toString()
              : null,
        );
      }).toList();

      if (mounted) setState(() {});
    } on ApiError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar rutas: ${e.message}')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudieron cargar las rutas')),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _abrirAsignarConductor(_RutaAdmin ruta) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _AsignarConductorDialog(ruta: ruta),
    );
    if (ok == true) {
      await _cargarRutas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Row(
        children: [
          const SidebarAdmin(selected: '/admin/rutas'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gestión de rutas',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Rutas solicitadas por los clientes',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  // Filtros
                  Row(
                    children: [
                      DropdownButton<String>(
                        value: _filtroEstado,
                        hint: const Text('Filtrar por estado'),
                        items: const [
                          DropdownMenuItem(
                              value: 'planificada',
                              child: Text('Planificada')),
                          DropdownMenuItem(
                              value: 'en_progreso',
                              child: Text('En progreso')),
                          DropdownMenuItem(
                              value: 'completada',
                              child: Text('Completada')),
                          DropdownMenuItem(
                              value: 'cancelada',
                              child: Text('Cancelada')),
                        ],
                        onChanged: (v) {
                          setState(() => _filtroEstado = v);
                          _cargarRutas();
                        },
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: _cargarRutas,
                        icon: _cargando
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.refresh),
                        label: const Text('Actualizar'),
                      ),
                      if (_filtroEstado != null)
                        TextButton(
                          onPressed: () {
                            setState(() => _filtroEstado = null);
                            _cargarRutas();
                          },
                          child: const Text('Quitar filtro'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: kBordeSuave),
                      ),
                      child: _cargando
                          ? const Center(child: CircularProgressIndicator())
                          : _rutas.isEmpty
                              ? const Center(child: Text('Sin rutas'))
                              : Column(
                                  children: [
                                    // Cabecera de “tabla”
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom:
                                              BorderSide(color: kBordeSuave),
                                        ),
                                      ),
                                      child: Row(
                                        children: const [
                                          Expanded(
                                            flex: 2,
                                            child: Text('Código',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w700)),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Text('Nombre',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w700)),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Text('Cliente',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w700)),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text('Estado',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w700)),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Text('Conductor',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w700)),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text('Vehículo',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w700)),
                                          ),
                                          SizedBox(
                                              width: 180, child: SizedBox()),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: ListView.separated(
                                        padding: const EdgeInsets.all(12),
                                        itemCount: _rutas.length,
                                        separatorBuilder: (_, __) =>
                                            const Divider(color: kBordeSuave),
                                        itemBuilder: (context, index) {
                                          final r = _rutas[index];
                                          return _RowRutaAdmin(
                                            ruta: r,
                                            onAsignar: () =>
                                                _abrirAsignarConductor(r),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RowRutaAdmin extends StatelessWidget {
  final _RutaAdmin ruta;
  final VoidCallback onAsignar;

  const _RowRutaAdmin({
    required this.ruta,
    required this.onAsignar,
  });

  @override
  Widget build(BuildContext context) {
    final colorEstado = (ruta.estado == 'completada')
        ? kVerde
        : (ruta.estado == 'cancelada')
            ? Colors.red
            : kTexto;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              ruta.codigo,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(flex: 3, child: Text(ruta.nombre)),
          Expanded(flex: 3, child: Text(ruta.cliente)),
          Expanded(
            flex: 2,
            child: Text(
              ruta.estado,
              style: TextStyle(
                color: colorEstado,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(ruta.conductor ?? '-'),
          ),
          Expanded(
            flex: 2,
            child: Text(ruta.vehiculo ?? '-'),
          ),
          SizedBox(
            width: 180,
            child: ElevatedButton(
              onPressed: onAsignar,
              child: const Text('Asignar conductor'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Diálogo para asignar conductor y vehículo (conectado a la API)
class _AsignarConductorDialog extends StatefulWidget {
  final _RutaAdmin ruta;

  const _AsignarConductorDialog({required this.ruta});

  @override
  State<_AsignarConductorDialog> createState() =>
      _AsignarConductorDialogState();
}

class _AsignarConductorDialogState extends State<_AsignarConductorDialog> {
  bool _cargandoConductores = false;
  bool _guardando = false;

  List<Map<String, dynamic>> _conductores = [];
  int? _conductorId;
  Map<String, dynamic>? _vehiculo;

  @override
  void initState() {
    super.initState();
    _cargarConductores();
  }

  Future<void> _cargarConductores() async {
    setState(() => _cargandoConductores = true);
    try {
      _conductores = await Api.listarUsuariosPorRol('Conductor');
    } on ApiError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar conductores: ${e.message}')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudieron cargar los conductores')),
      );
    } finally {
      if (mounted) setState(() => _cargandoConductores = false);
    }
  }

  Future<void> _onSeleccionConductor(int? id) async {
    setState(() {
      _conductorId = id;
      _vehiculo = null;
    });
    if (id == null) return;

    try {
      final v = await Api.obtenerVehiculoDeConductor(id);
      if (mounted) {
        setState(() {
          _vehiculo = v;
        });
      }
    } on ApiError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener vehículo: ${e.message}')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo obtener el vehículo')),
      );
    }
  }

  Future<void> _guardar() async {
    if (_conductorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un conductor')),
      );
      return;
    }

    setState(() => _guardando = true);
    try {
      final vehiculoId = (_vehiculo?['id'] as num?)?.toInt();

      await Api.asignarRuta(
        rutaId: widget.ruta.id,
        conductorId: _conductorId,
        vehiculoId: vehiculoId,
        asignadoPor: Session.userId,
        comentario: 'Asignación desde panel administrador',
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on ApiError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al asignar ruta: ${e.message}')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo asignar la ruta')),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Asignar conductor',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.ruta.codigo} • ${widget.ruta.nombre}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              if (_cargandoConductores) const LinearProgressIndicator(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _conductorId,
                      isDense: true,
                      decoration: const InputDecoration(
                        labelText: 'Conductor',
                        border: OutlineInputBorder(),
                      ),
                      items: _cargandoConductores
                          ? const []
                          : _conductores
                              .map(
                                (c) => DropdownMenuItem<int>(
                                  value: (c['id'] as num).toInt(),
                                  child: Text(
                                    c['nombre_completo']?.toString() ??
                                        c['email']?.toString() ??
                                        '#${c['id']}',
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: _onSeleccionConductor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Vehículo (asignado automáticamente)',
                        border: const OutlineInputBorder(),
                        hintText: _vehiculo == null
                            ? 'Sin vehículo'
                            : '${_vehiculo!['placa'] ?? 'placa'} • ${_vehiculo!['modelo'] ?? 'modelo'}',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _guardando ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _guardando ? null : _guardar,
                    child: _guardando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Guardar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
