// Archivo: lib/conductores/conductores_pages.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'conductores_rutas.dart';
import 'package:tradex_web/services/api.dart';
import 'package:tradex_web/session.dart';

// --------- Paleta local mínima ---------
const kNavy = Color(0xFF0D2234);
const kNavy2 = Color(0xFF12314A);
const kVerde = Color(0xFF21BF73);
const kBg = Color(0xFFF3F5F9);
const kTexto = Color(0xFF111827);
const kBordeSuave = Color(0xFFE5E7EB);

class SidebarConductor extends StatelessWidget {
  final String selected; // ruta actual
  const SidebarConductor({super.key, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: kNavy,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.local_shipping, color: Colors.white),
              SizedBox(width: 10),
              Text('TRADEX LOGISTIC',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 24),
          _item(context,
              icon: Icons.turn_slight_right_rounded,
              label: 'Rutas asignadas',
              route: ConductoresRoutes.rutas,
              selected: selected),
          const SizedBox(height: 8),
          _item(context,
              icon: Icons.directions_car_filled_rounded,
              label: 'Vehículos vinculados',
              route: ConductoresRoutes.vehiculos,
              selected: selected),
          const Spacer(),
          const Divider(color: Colors.white24, height: 24),
          const SizedBox(height: 8),
          _logout(context),
        ],
      ),
    );
  }

  Widget _item(BuildContext context,
      {required IconData icon,
      required String label,
      required String route,
      required String selected}) {
    final isSelected = selected == route;
    return Material(
      color: isSelected ? kNavy2 : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (!isSelected) Navigator.pushReplacementNamed(context, route);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _logout(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.logout, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text('Salir', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =================== Rutas Asignadas ===================
class RutasAsignadasPage extends StatefulWidget {
  const RutasAsignadasPage({super.key});

  @override
  State<RutasAsignadasPage> createState() => _RutasAsignadasPageState();
}

class _RutasAsignadasPageState extends State<RutasAsignadasPage> {
  List<Map<String, dynamic>> _rutas = [];
  final Map<int, Map<String, dynamic>> _geoPorRuta = {}; // rutaId -> geojson
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    try {
      final resp = await Api.listarRutasConductor(Session.userId!);
      final list = (resp['data'] ?? []) as List;
      final rutas = list.cast<Map>().map((e) => e.cast<String, dynamic>()).toList();
      setState(() => _rutas = rutas);

      // Cargar geojson para cada ruta (en paralelo)
      for (final r in rutas) {
        final id = (r['id'] as num).toInt();
        Api.geojsonRuta(id).then((g) {
          if (!mounted) return;
          setState(() => _geoPorRuta[id] = g);
        });
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _cambiarEstado(int rutaId, String nuevo) async {
    await Api.actualizarEstadoRuta(rutaId: rutaId, estado: nuevo);
    // Refrescar list
    await _cargar();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Estado actualizado')));
  }

  @override
  Widget build(BuildContext context) {
    // Center del mapa: si hay alguna parada, usamos la primera; de lo contrario, Bogotá
    LatLng center = const LatLng(4.7110, -74.0721);
    for (final geo in _geoPorRuta.values) {
      final paradas = (geo['paradas']?['features'] as List?) ?? [];
      if (paradas.isNotEmpty) {
        final first = (paradas.first as Map)['geometry']['coordinates'] as List;
        center = LatLng((first[1] as num).toDouble(), (first[0] as num).toDouble());
        break;
      }
    }

    return Scaffold(
      backgroundColor: kBg,
      body: Row(
        children: [
          const SidebarConductor(selected: ConductoresRoutes.rutas),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hola, ${Session.name ?? "Conductor"}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: kTexto)),
                  const SizedBox(height: 6),
                  const Text('Rutas asignadas',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: kTexto)),
                  const SizedBox(height: 16),

                  // ---------- Mapa con TODAS las rutas (polylines + marcadores) ----------
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: kBordeSuave),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: SizedBox(
                      height: 420,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: center,
                          initialZoom: 12.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.tradex_web',
                          ),
                          // Polylines por ruta
                          PolylineLayer(
                            polylines: [
                              for (final entry in _geoPorRuta.entries)
                                () {
                                  final geo = entry.value;
                                  final line = geo['linea'] as Map<String, dynamic>?;
                                  final coords = (line?['geometry']?['coordinates'] as List?) ?? [];
                                  final pts = coords.map((c) {
                                    final l = c as List;
                                    return LatLng((l[1] as num).toDouble(), (l[0] as num).toDouble());
                                  }).toList();
                                  if (pts.isEmpty) return Polyline(points: const []);
                                  return Polyline(points: pts, strokeWidth: 4.0);
                                }(),
                            ],
                          ),
                          // Marcadores por ruta
                          MarkerLayer(
                            markers: [
                              for (final entry in _geoPorRuta.entries)
                                ...(() {
                                  final geo = entry.value;
                                  final feats = (geo['paradas']?['features'] as List?) ?? [];
                                  return feats.map((f) {
                                    final g = (f as Map)['geometry'];
                                    final props = f['properties'] as Map;
                                    final coords = g['coordinates'] as List;
                                    final p = LatLng((coords[1] as num).toDouble(), (coords[0] as num).toDouble());
                                    final etiqueta = '${props['orden']}. ${props['titulo'] ?? 'Parada'}';
                                    return Marker(
                                      point: p,
                                      width: 150,
                                      height: 80,
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(color: kVerde, borderRadius: BorderRadius.circular(8)),
                                            child: Text(
                                              etiqueta,
                                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const Icon(Icons.location_on, color: kVerde, size: 36),
                                        ],
                                      ),
                                    );
                                  }).toList();
                                })(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ---------- Tabla de rutas con cambio de estado ----------
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: kBordeSuave),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                            child: Row(
                              children: const [
                                _Cell('Ruta', flex: 2, isHeader: true),
                                _Cell('Nombre', flex: 3, isHeader: true),
                                _Cell('Estado', flex: 2, isHeader: true),
                                _Cell('Cliente', flex: 3, isHeader: true),
                                _Cell('Acciones', flex: 3, isHeader: true),
                              ],
                            ),
                          ),
                          const Divider(height: 24, color: kBordeSuave),
                          if (_cargando)
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            )
                          else if (_rutas.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('No tienes rutas asignadas'),
                            )
                          else
                            for (final r in _rutas) _rowRuta(r),
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

  Widget _rowRuta(Map<String, dynamic> r) {
    final id = (r['id'] as num).toInt();
    final estado = (r['estado'] ?? 'planificada') as String;
    final TextEditingController _dummy = TextEditingController(); // placeholder
    String _nuevoEstado = estado;

    return StatefulBuilder(
      builder: (context, setSt) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: Row(
                children: [
                  _Cell('${r['codigo']}', flex: 2),
                  _Cell('${r['nombre']}', flex: 3),
                  _Cell(estado, flex: 2, emphasize: true, color: estado == 'completada' ? kVerde : kTexto),
                  _Cell(r['cliente_nombre'] ?? '-', flex: 3),
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 180,
                          child: DropdownButtonFormField<String>(
                            value: _nuevoEstado,
                            items: const [
                              DropdownMenuItem(value: 'planificada', child: Text('Planificada')),
                              DropdownMenuItem(value: 'en_progreso', child: Text('En progreso')),
                              DropdownMenuItem(value: 'completada', child: Text('Completada')),
                              DropdownMenuItem(value: 'cancelada', child: Text('Cancelada')),
                            ],
                            onChanged: (v) => setSt(() => _nuevoEstado = v ?? estado),
                            decoration: const InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(),
                              labelText: 'Nuevo estado',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () => _cambiarEstado(id, _nuevoEstado),
                          icon: const Icon(Icons.save_outlined),
                          label: const Text('Guardar'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 0, color: kBordeSuave),
          ],
        );
      },
    );
  }
}

// ========== Vehículos vinculados (sin cambios funcionales) ==========
// ========== Pantalla: Vehículos vinculados (nueva) ==========
class VehiculosVinculadosPage extends StatefulWidget {
  const VehiculosVinculadosPage({super.key});

  @override
  State<VehiculosVinculadosPage> createState() => _VehiculosVinculadosPageState();
}

class _VehiculosVinculadosPageState extends State<VehiculosVinculadosPage> {
  List<Map<String, dynamic>> _vehiculos = [];
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    try {
      final r = await Api.listarVehiculos(conductorId: Session.userId);
      final data = (r['data'] ?? []) as List;
      setState(() {
        _vehiculos = data.cast<Map>().map((e) => e.cast<String, dynamic>()).toList();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error cargando vehículos: $e')));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _abrirFormularioNuevo() async {
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => const _DialogCrearVehiculo(),
    );
    if (res == true) {
      _cargar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirFormularioNuevo,
        icon: const Icon(Icons.add),
        label: const Text('Registrar vehículo'),
      ),
      body: Row(
        children: [
          const SidebarConductor(selected: ConductoresRoutes.vehiculos),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hola, ${Session.name ?? "Conductor"}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: kTexto)),
                  const SizedBox(height: 6),
                  const Text('Vehículos vinculados',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: kTexto)),
                  const SizedBox(height: 16),

                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: kBordeSuave),
                    ),
                    child: Column(
                      children: [
                        // Header de tabla
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: kBordeSuave)),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: const [
                              _Cell('Placa', flex: 2, isHeader: true),
                              _Cell('Marca / Modelo', flex: 3, isHeader: true),
                              _Cell('Año', flex: 1, isHeader: true),
                              _Cell('Cap. (kg)', flex: 2, isHeader: true),
                              _Cell('Vol. (m³)', flex: 2, isHeader: true),
                              _Cell('Estado', flex: 2, isHeader: true),
                            ],
                          ),
                        ),

                        if (_cargando)
                          const Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          )
                        else if (_vehiculos.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text('No tienes vehículos asignados.'),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(12),
                            itemBuilder: (_, i) {
                              final v = _vehiculos[i];
                              final activo = (v['estado'] ?? '').toString().toLowerCase() == 'activo';
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                                child: Row(
                                  children: [
                                    _Cell(v['placa'] ?? '-', flex: 2, emphasize: true),
                                    _Cell(
                                      '${v['marca'] ?? '-'} ${v['modelo'] ?? ''}'.trim(),
                                      flex: 3,
                                    ),
                                    _Cell(v['anio']?.toString() ?? '-', flex: 1),
                                    _Cell(v['capacidad_kg']?.toString() ?? '-', flex: 2),
                                    _Cell(v['volumen_m3']?.toString() ?? '-', flex: 2),
                                    _Cell(
                                      v['estado'] ?? '-',
                                      flex: 2,
                                      emphasize: true,
                                      color: activo ? kVerde : kTexto,
                                    ),
                                  ],
                                ),
                              );
                            },
                            separatorBuilder: (_, __) => const Divider(color: kBordeSuave),
                            itemCount: _vehiculos.length,
                          ),

                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: OutlinedButton.icon(
                              onPressed: _cargar,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Actualizar lista'),
                            ),
                          ),
                        )
                      ],
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

// ---- Diálogo para crear/registrar vehículo asignado al conductor ----
class _DialogCrearVehiculo extends StatefulWidget {
  const _DialogCrearVehiculo({super.key});

  @override
  State<_DialogCrearVehiculo> createState() => _DialogCrearVehiculoState();
}

class _DialogCrearVehiculoState extends State<_DialogCrearVehiculo> {
  final _formKey = GlobalKey<FormState>();
  final _placaCtrl = TextEditingController();
  final _marcaCtrl = TextEditingController();
  final _modeloCtrl = TextEditingController();
  final _anioCtrl = TextEditingController();
  final _capacidadCtrl = TextEditingController();
  final _volumenCtrl = TextEditingController();

  String _estado = 'activo'; // o 'disponible'
  bool _guardando = false;

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
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    setState(() => _guardando = true);
    try {
      await Api.crearVehiculo(
        placa: _placaCtrl.text.trim(),
        marca: _marcaCtrl.text.trim().isEmpty ? null : _marcaCtrl.text.trim(),
        modelo: _modeloCtrl.text.trim().isEmpty ? null : _modeloCtrl.text.trim(),
        anio: int.tryParse(_anioCtrl.text.trim()),
        capacidadKg: double.tryParse(_capacidadCtrl.text.trim()),
        volumenM3: double.tryParse(_volumenCtrl.text.trim()),
        estado: _estado,
        conductorId: Session.userId, // ← se asigna a este conductor
      );
      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehículo registrado correctamente')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Text('Registrar vehículo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(onPressed: () => Navigator.pop(context, false), icon: const Icon(Icons.close)),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _placaCtrl,
                          decoration: const InputDecoration(labelText: 'Placa *', border: OutlineInputBorder()),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _marcaCtrl,
                          decoration: const InputDecoration(labelText: 'Marca', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _modeloCtrl,
                          decoration: const InputDecoration(labelText: 'Modelo', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _anioCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Año', border: OutlineInputBorder()),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return null;
                            final n = int.tryParse(v);
                            if (n == null || n < 1980 || n > DateTime.now().year + 1) return 'Año inválido';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _capacidadCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Capacidad (kg)', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _volumenCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Volumen (m³)', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _estado,
                    items: const [
                      DropdownMenuItem(value: 'activo', child: Text('Activo')),
                      DropdownMenuItem(value: 'disponible', child: Text('Disponible')),
                      DropdownMenuItem(value: 'inactivo', child: Text('Inactivo')),
                    ],
                    onChanged: (v) => setState(() => _estado = v ?? 'activo'),
                    decoration: const InputDecoration(labelText: 'Estado', border: OutlineInputBorder()),
                  ),

                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _guardando ? null : _guardar,
                      icon: _guardando
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.save),
                      label: const Text('Guardar'),
                    ),
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

// ----------------- Helpers compartidos -----------------
class _Cell extends StatelessWidget {
  final String text;
  final int flex;
  final bool isHeader;
  final bool emphasize;
  final bool underline;
  final Color? color;

  const _Cell(
    this.text, {
    this.flex = 1,
    this.isHeader = false,
    this.emphasize = false,
    this.underline = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle style = isHeader
        ? Theme.of(context).textTheme.titleMedium!
        : Theme.of(context).textTheme.bodyMedium!;
    if (emphasize) style = style.copyWith(fontWeight: FontWeight.w700);
    if (underline) style = style.copyWith(decoration: TextDecoration.underline);
    if (color != null) style = style.copyWith(color: color);
    return Expanded(flex: flex, child: Text(text, style: style));
  }
}

class _Vehiculo {
  final String no, estado, modelo;
  _Vehiculo({required this.no, required this.estado, required this.modelo});
}
