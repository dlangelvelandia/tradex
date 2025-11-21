// Archivo: lib/administrador/admin_rutas_page.dart

import 'package:flutter/material.dart';
import 'sidebar_admin.dart';

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

  @override
  void initState() {
    super.initState();
    _cargarRutas();
  }

  Future<void> _cargarRutas() async {
    setState(() => _cargando = true);
    try {
      // SOLO FRONTEND: datos de ejemplo
      await Future.delayed(const Duration(milliseconds: 400));

      _rutas = [
        _RutaAdmin(
          id: 1,
          codigo: 'TRX-1001',
          nombre: 'Ruta Bogotá - Medellín',
          cliente: 'Cliente Demo 1',
          estado: 'planificada',
          conductor: null,
          vehiculo: null,
        ),
        _RutaAdmin(
          id: 2,
          codigo: 'TRX-1002',
          nombre: 'Ruta Cali - Barranquilla',
          cliente: 'Cliente Demo 2',
          estado: 'en_progreso',
          conductor: 'Carlos Gómez',
          vehiculo: 'ABC123',
        ),
      ];
      setState(() {});
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _abrirAsignarConductor(_RutaAdmin ruta) async {
    await showDialog<bool>(
      context: context,
      builder: (_) => _AsignarConductorDialog(ruta: ruta),
    );
    // Cuando tengas backend, aquí puedes recargar:
    // await _cargarRutas();
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
                  const SizedBox(height: 24),
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
                              : ListView.separated(
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

/// Diálogo para asignar conductor y vehículo
/// (solo frontend: usamos una lista fija de conductores)
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

    // SOLO FRONTEND: lista fija de conductores + vehículo
    await Future.delayed(const Duration(milliseconds: 300));

    _conductores = [
      {
        'id': 1,
        'nombre_completo': 'Carlos Gómez',
        'vehiculo': {'placa': 'ABC123', 'modelo': 'Toyota Hilux'},
      },
      {
        'id': 2,
        'nombre_completo': 'Ana Pérez',
        'vehiculo': {'placa': 'XYZ987', 'modelo': 'Chevrolet NKR'},
      },
      {
        'id': 3,
        'nombre_completo': 'Luis Ramírez',
        'vehiculo': {'placa': 'JKL456', 'modelo': 'Ford Ranger'},
      },
    ];

    if (mounted) {
      setState(() => _cargandoConductores = false);
    }
  }

  Future<void> _onSeleccionConductor(int? id) async {
    setState(() {
      _conductorId = id;
      _vehiculo = null;
    });
    if (id == null) return;

    final c = _conductores.firstWhere(
      (e) => (e['id'] as int) == id,
      orElse: () => {},
    );
    if (c.isNotEmpty) {
      setState(() {
        _vehiculo = c['vehiculo'] as Map<String, dynamic>?;
      });
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
    await Future.delayed(const Duration(milliseconds: 300));

    // SOLO FRONTEND: aquí solo cerramos el diálogo; no hay llamada a API
    if (mounted) {
      Navigator.of(context).pop(true);
    }

    if (mounted) setState(() => _guardando = false);
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
                                  value: (c['id'] as int),
                                  child: Text(
                                    c['nombre_completo']?.toString() ??
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
