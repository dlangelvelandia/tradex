import 'package:flutter/material.dart';
import 'sidebar_admin.dart';
import 'package:tradex_web/services/api.dart';

class AdminRutasPage extends StatefulWidget {
  const AdminRutasPage({super.key});

  @override
  State<AdminRutasPage> createState() => _AdminRutasPageState();
}

class _AdminRutasPageState extends State<AdminRutasPage> {
  bool _cargando = false;
  List<Map<String, dynamic>> _rutas = [];

  @override
  void initState() {
    super.initState();
    _cargarRutas();
  }

  Future<void> _cargarRutas() async {
    setState(() => _cargando = true);
    try {
      final resp = await Api.listarRutasAdmin(perPage: 200);
      _rutas = ((resp['data'] ?? []) as List)
          .cast<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList();
      if (mounted) setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _eliminarRuta(int id, String codigo) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Eliminar ruta $codigo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    try {
      await Api.eliminarRuta(id);
      _cargarRutas();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ruta eliminada')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _mostrarFormulario({Map<String, dynamic>? ruta}) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (_) => _FormularioRuta(ruta: ruta),
    );
    if (resultado == true) {
      _cargarRutas();
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
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Gestión de rutas',
                                style:
                                    Theme.of(context).textTheme.headlineMedium),
                            const SizedBox(height: 4),
                            const Text('Administrar rutas y asignaciones',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _mostrarFormulario(),
                        icon: const Icon(Icons.add),
                        label: const Text('Nueva Ruta'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _cargarRutas,
                        tooltip: 'Actualizar',
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
                              : ListView.separated(
                                  itemCount: _rutas.length,
                                  separatorBuilder: (_, __) => const Divider(
                                      height: 1, color: kBordeSuave),
                                  itemBuilder: (context, index) {
                                    final r = _rutas[index];
                                    return ListTile(
                                      title: Text(
                                          '${r['codigo']} • ${r['nombre']}'),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Fecha: ${r['fecha_programada'] ?? 'N/A'} • Prioridad: ${r['prioridad'] ?? 'N/A'}'),
                                          if (r['cliente_nombre'] != null)
                                            Text('Cliente: ${r['cliente_nombre']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                          if (r['conductor_nombre'] != null)
                                            Text('Conductor: ${r['conductor_nombre']}', style: const TextStyle(fontSize: 12, color: Colors.blue)),
                                          if (r['vehiculo_info'] != null)
                                            Text('Vehículo: ${r['vehiculo_info']}', style: const TextStyle(fontSize: 12, color: Colors.green)),
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: _colorEstado(r['estado'])
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              r['estado'] ?? '',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: _colorEstado(r['estado']),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                size: 20),
                                            onPressed: () =>
                                                _mostrarFormulario(ruta: r),
                                            tooltip: 'Editar',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                size: 20, color: Colors.red),
                                            onPressed: () =>
                                                _eliminarRuta(r['id'], r['codigo']),
                                            tooltip: 'Eliminar',
                                          ),
                                        ],
                                      ),
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

  Color _colorEstado(String? estado) {
    switch (estado) {
      case 'pendiente':
        return Colors.orange;
      case 'en_curso':
        return Colors.blue;
      case 'completada':
        return kVerde;
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _FormularioRuta extends StatefulWidget {
  final Map<String, dynamic>? ruta;
  const _FormularioRuta({this.ruta});

  @override
  State<_FormularioRuta> createState() => _FormularioRutaState();
}

class _FormularioRutaState extends State<_FormularioRuta> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codigoCtrl;
  late TextEditingController _nombreCtrl;
  late TextEditingController _descripcionCtrl;
  late TextEditingController _fechaCtrl;
  late TextEditingController _horaInicioCtrl;
  late TextEditingController _horaFinCtrl;
  String _estado = 'pendiente';
  String _prioridad = 'media';
  bool _guardando = false;

  // Nuevos campos para asignaciones
  int? _clienteId;
  int? _conductorId;
  int? _vehiculoId;
  List<Map<String, dynamic>> _clientes = [];
  List<Map<String, dynamic>> _conductores = [];
  List<Map<String, dynamic>> _vehiculos = [];
  bool _cargandoDatos = true;

  @override
  void initState() {
    super.initState();
    final r = widget.ruta;
    _codigoCtrl = TextEditingController(text: r?['codigo']?.toString() ?? '');
    _nombreCtrl = TextEditingController(text: r?['nombre']?.toString() ?? '');
    _descripcionCtrl = TextEditingController(text: r?['descripcion']?.toString() ?? '');
    _fechaCtrl = TextEditingController(text: r?['fecha_programada']?.toString() ?? '');
    _horaInicioCtrl = TextEditingController(text: r?['hora_inicio']?.toString() ?? '');
    _horaFinCtrl = TextEditingController(text: r?['hora_fin']?.toString() ?? '');
    
    // Normalizar estado
    final estadoRaw = r?['estado']?.toString() ?? 'pendiente';
    final estadosValidos = ['pendiente', 'planificada', 'en_curso', 'completada', 'cancelada'];
    _estado = estadosValidos.contains(estadoRaw) ? estadoRaw : 'pendiente';
    
    // Normalizar prioridad
    final prioridadRaw = r?['prioridad']?.toString() ?? 'media';
    final prioridadesValidas = ['baja', 'media', 'alta'];
    _prioridad = prioridadesValidas.contains(prioridadRaw) ? prioridadRaw : 'media';
    
    // Inicializar IDs de asignaciones
    _clienteId = r?['cliente_id'];
    _conductorId = r?['conductor_id'];
    _vehiculoId = r?['vehiculo_id'];
    
    _cargarDatosIniciales();
  }

  Future<void> _cargarDatosIniciales() async {
    try {
      final clientes = await Api.listarUsuariosPorRol('Cliente', perPage: 500);
      final conductores = await Api.listarUsuariosPorRol('Conductor', perPage: 500);
      final vehiculosResp = await Api.listarVehiculos(perPage: 500);
      
      _clientes = clientes.cast<Map>().map((e) => e.cast<String, dynamic>()).toList();
      _conductores = conductores.cast<Map>().map((e) => e.cast<String, dynamic>()).toList();
      _vehiculos = ((vehiculosResp['data'] ?? []) as List)
          .cast<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList();
          
      if (mounted) {
        setState(() => _cargandoDatos = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _cargandoDatos = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando datos: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _codigoCtrl.dispose();
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    _fechaCtrl.dispose();
    _horaInicioCtrl.dispose();
    _horaFinCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);
    try {
      final data = <String, dynamic>{
        'codigo': _codigoCtrl.text.trim(),
        'nombre': _nombreCtrl.text.trim(),
        if (_descripcionCtrl.text.isNotEmpty)
          'descripcion': _descripcionCtrl.text.trim(),
        'estado': _estado,
        'prioridad': _prioridad,
        if (_fechaCtrl.text.isNotEmpty)
          'fecha_programada': _fechaCtrl.text.trim(),
        if (_horaInicioCtrl.text.isNotEmpty)
          'hora_inicio': _horaInicioCtrl.text.trim(),
        if (_horaFinCtrl.text.isNotEmpty)
          'hora_fin': _horaFinCtrl.text.trim(),
        if (_clienteId != null) 'cliente_id': _clienteId,
        if (_conductorId != null) 'conductor_id': _conductorId,
        if (_vehiculoId != null) 'vehiculo_id': _vehiculoId,
      };

      if (widget.ruta == null) {
        await Api.crearRutaConDatos(data);
      } else {
        await Api.actualizarRuta(widget.ruta!['id'], data);
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(widget.ruta == null
                ? 'Ruta creada'
                : 'Ruta actualizada')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.ruta == null ? 'Nueva Ruta' : 'Editar Ruta',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _codigoCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Código *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              v?.trim().isEmpty == true ? 'Requerido' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _nombreCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Nombre *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              v?.trim().isEmpty == true ? 'Requerido' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descripcionCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  if (_cargandoDatos)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    DropdownButtonFormField<int>(
                      value: _clienteId,
                      decoration: const InputDecoration(
                        labelText: 'Cliente',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Sin asignar')),
                        ..._clientes.map((c) => DropdownMenuItem(
                              value: c['id'],
                              child: Text(c['nombre_completo'] ?? 'Sin nombre'),
                            )),
                      ],
                      onChanged: (v) => setState(() => _clienteId = v),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _conductorId,
                      decoration: const InputDecoration(
                        labelText: 'Conductor',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Sin asignar')),
                        ..._conductores.map((c) => DropdownMenuItem(
                              value: c['id'],
                              child: Text(c['nombre_completo'] ?? 'Sin nombre'),
                            )),
                      ],
                      onChanged: (v) => setState(() => _conductorId = v),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _vehiculoId,
                      decoration: const InputDecoration(
                        labelText: 'Vehículo',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Sin asignar')),
                        ..._vehiculos.map((v) => DropdownMenuItem(
                              value: v['id'],
                              child: Text('${v['placa']} - ${v['marca']} ${v['modelo']}'),
                            )),
                      ],
                      onChanged: (v) => setState(() => _vehiculoId = v),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _estado,
                          decoration: const InputDecoration(
                            labelText: 'Estado',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                                value: 'pendiente', child: Text('Pendiente')),
                            DropdownMenuItem(
                                value: 'planificada', child: Text('Planificada')),
                            DropdownMenuItem(
                                value: 'en_curso', child: Text('En curso')),
                            DropdownMenuItem(
                                value: 'completada', child: Text('Completada')),
                            DropdownMenuItem(
                                value: 'cancelada', child: Text('Cancelada')),
                          ],
                          onChanged: (v) => setState(() => _estado = v!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _prioridad,
                          decoration: const InputDecoration(
                            labelText: 'Prioridad',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                                value: 'baja', child: Text('Baja')),
                            DropdownMenuItem(
                                value: 'media', child: Text('Media')),
                            DropdownMenuItem(
                                value: 'alta', child: Text('Alta')),
                          ],
                          onChanged: (v) => setState(() => _prioridad = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _fechaCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Fecha programada (YYYY-MM-DD)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _horaInicioCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Hora inicio (HH:MM)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _horaFinCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Hora fin (HH:MM)',
                            border: OutlineInputBorder(),
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
                        onPressed: _guardando
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _guardando ? null : _guardar,
                        child: _guardando
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Guardar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
