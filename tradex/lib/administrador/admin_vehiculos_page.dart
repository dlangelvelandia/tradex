import 'package:flutter/material.dart';
import 'sidebar_admin.dart';
import 'package:tradex_web/services/api.dart';

class AdminVehiculosPage extends StatefulWidget {
  const AdminVehiculosPage({super.key});

  @override
  State<AdminVehiculosPage> createState() => _AdminVehiculosPageState();
}

class _AdminVehiculosPageState extends State<AdminVehiculosPage> {
  bool _cargando = false;
  List<Map<String, dynamic>> _vehiculos = [];

  @override
  void initState() {
    super.initState();
    _cargarVehiculos();
  }

  Future<void> _cargarVehiculos() async {
    setState(() => _cargando = true);
    try {
      final resp = await Api.listarVehiculos(perPage: 200);
      _vehiculos = ((resp['data'] ?? []) as List)
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

  Future<void> _eliminarVehiculo(int id, String placa) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Eliminar vehículo $placa?'),
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
      await Api.eliminarVehiculo(id);
      _cargarVehiculos();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehículo eliminado')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _mostrarFormulario({Map<String, dynamic>? vehiculo}) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (_) => _FormularioVehiculo(vehiculo: vehiculo),
    );
    if (resultado == true) {
      _cargarVehiculos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Row(
        children: [
          const SidebarAdmin(selected: '/admin/vehiculos'),
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
                            Text('Gestión de vehículos',
                                style:
                                    Theme.of(context).textTheme.headlineMedium),
                            const SizedBox(height: 4),
                            const Text('Administrar flota de vehículos',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _mostrarFormulario(),
                        icon: const Icon(Icons.add),
                        label: const Text('Nuevo Vehículo'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _cargarVehiculos,
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
                          : _vehiculos.isEmpty
                              ? const Center(child: Text('Sin vehículos'))
                              : ListView.separated(
                                  itemCount: _vehiculos.length,
                                  separatorBuilder: (_, __) => const Divider(
                                      height: 1, color: kBordeSuave),
                                  itemBuilder: (context, index) {
                                    final v = _vehiculos[index];
                                    return ListTile(
                                      title: Text(
                                          '${v['placa']} • ${v['marca']} ${v['modelo']}'),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Año: ${v['anio'] ?? 'N/A'} • Capacidad: ${v['capacidad_kg'] ?? 0} kg'),
                                          if (v['conductor_nombre'] != null)
                                            Text(
                                              'Conductor: ${v['conductor_nombre']}',
                                              style: const TextStyle(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: v['estado'] == 'disponible'
                                                  ? kVerde.withOpacity(0.1)
                                                  : Colors.orange
                                                      .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              v['estado'] ?? '',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: v['estado'] ==
                                                        'disponible'
                                                    ? kVerde
                                                    : Colors.orange,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                size: 20),
                                            onPressed: () =>
                                                _mostrarFormulario(vehiculo: v),
                                            tooltip: 'Editar',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                size: 20, color: Colors.red),
                                            onPressed: () => _eliminarVehiculo(
                                                v['id'], v['placa']),
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
}

class _FormularioVehiculo extends StatefulWidget {
  final Map<String, dynamic>? vehiculo;
  const _FormularioVehiculo({this.vehiculo});

  @override
  State<_FormularioVehiculo> createState() => _FormularioVehiculoState();
}

class _FormularioVehiculoState extends State<_FormularioVehiculo> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _placaCtrl;
  late TextEditingController _marcaCtrl;
  late TextEditingController _modeloCtrl;
  late TextEditingController _anioCtrl;
  late TextEditingController _capacidadCtrl;
  late TextEditingController _volumenCtrl;
  String _estado = 'disponible';
  bool _guardando = false;
  
  // Campo para conductor
  int? _conductorId;
  List<Map<String, dynamic>> _conductores = [];
  bool _cargandoConductores = true;

  @override
  void initState() {
    super.initState();
    final v = widget.vehiculo;
    _placaCtrl = TextEditingController(text: v?['placa']?.toString() ?? '');
    _marcaCtrl = TextEditingController(text: v?['marca']?.toString() ?? '');
    _modeloCtrl = TextEditingController(text: v?['modelo']?.toString() ?? '');
    _anioCtrl = TextEditingController(text: v?['anio']?.toString() ?? '');
    _capacidadCtrl =
        TextEditingController(text: v?['capacidad_kg']?.toString() ?? '');
    _volumenCtrl =
        TextEditingController(text: v?['volumen_m3']?.toString() ?? '');
    _estado = v?['estado']?.toString() ?? 'disponible';
    _conductorId = v?['conductor_id'];
    _cargarConductores();
  }

  Future<void> _cargarConductores() async {
    try {
      final conductores = await Api.listarUsuariosPorRol('Conductor', perPage: 500);
      _conductores = conductores.cast<Map>().map((e) => e.cast<String, dynamic>()).toList();
      if (mounted) {
        setState(() => _cargandoConductores = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _cargandoConductores = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando conductores: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _placaCtrl.dispose();
    _marcaCtrl.dispose();
    _modeloCtrl.dispose();
    _anioCtrl.dispose();
    _capacidadCtrl.dispose();
    _volumenCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);
    try {
      if (widget.vehiculo == null) {
        await Api.crearVehiculo(
          placa: _placaCtrl.text.trim().toUpperCase(),
          marca: _marcaCtrl.text.trim(),
          modelo: _modeloCtrl.text.trim(),
          anio: int.tryParse(_anioCtrl.text),
          capacidadKg: double.tryParse(_capacidadCtrl.text),
          volumenM3: double.tryParse(_volumenCtrl.text),
          estado: _estado,
          conductorId: _conductorId,
        );
      } else {
        final data = <String, dynamic>{
          'placa': _placaCtrl.text.trim().toUpperCase(),
          'marca': _marcaCtrl.text.trim(),
          'modelo': _modeloCtrl.text.trim(),
          if (_anioCtrl.text.isNotEmpty) 'anio': int.parse(_anioCtrl.text),
          if (_capacidadCtrl.text.isNotEmpty)
            'capacidad_kg': double.parse(_capacidadCtrl.text),
          if (_volumenCtrl.text.isNotEmpty)
            'volumen_m3': double.parse(_volumenCtrl.text),
          'estado': _estado,
          'conductor_id': _conductorId,
        };
        await Api.actualizarVehiculo(widget.vehiculo!['id'], data);
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(widget.vehiculo == null
                ? 'Vehículo creado'
                : 'Vehículo actualizado')),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.vehiculo == null
                      ? 'Nuevo Vehículo'
                      : 'Editar Vehículo',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _placaCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Placa *',
                          border: OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.characters,
                        validator: (v) =>
                            v?.trim().isEmpty == true ? 'Requerido' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _marcaCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Marca',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _modeloCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Modelo',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _anioCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Año',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _capacidadCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Capacidad (kg)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _volumenCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Volumen (m³)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _estado,
                  decoration: const InputDecoration(
                    labelText: 'Estado',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'disponible', child: Text('Disponible')),
                    DropdownMenuItem(
                        value: 'en_ruta', child: Text('En ruta')),
                    DropdownMenuItem(
                        value: 'mantenimiento', child: Text('Mantenimiento')),
                  ],
                  onChanged: (v) => setState(() => _estado = v!),
                ),
                const SizedBox(height: 16),
                if (_cargandoConductores)
                  const Center(child: CircularProgressIndicator())
                else
                  DropdownButtonFormField<int>(
                    value: _conductorId,
                    decoration: const InputDecoration(
                      labelText: 'Conductor Asignado',
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
                              child: CircularProgressIndicator(strokeWidth: 2),
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
    );
  }
}
