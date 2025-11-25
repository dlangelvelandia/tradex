// Archivo: lib/clientes/clientes_pages.dart
// Creación de rutas (cliente SOLO crea) y Rutas pendientes.

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'clientes_rutas.dart';
import 'package:tradex_web/services/api.dart';
import 'package:tradex_web/session.dart';

// ----------- Paleta local mínima -----------
const kNavy = Color(0xFF0D2234);
const kBg = Color(0xFFF5F6FB);
const kTexto = Color(0xFF0F172A);
const kBordeSuave = Color(0xFFE5E7EB);
const kVerde = Color(0xFF21BF73);

// ----------- Puntos predeterminados (Bogotá) -----------
class _PuntoPredefinido {
  final String id;
  final String label;
  final String direccion;
  final double lat;
  final double lng;

  const _PuntoPredefinido({
    required this.id,
    required this.label,
    required this.direccion,
    required this.lat,
    required this.lng,
  });
}

const List<_PuntoPredefinido> kPuntosPredefinidos = [
  _PuntoPredefinido(
    id: 'plaza_bolivar',
    label: 'Plaza de Bolívar',
    direccion: 'Plaza de Bolívar, Bogotá',
    lat: 4.598120,
    lng: -74.076044,
  ),
  _PuntoPredefinido(
    id: 'terminal_salitre',
    label: 'Terminal de Transportes Salitre',
    direccion: 'Terminal de Transportes Salitre, Bogotá',
    lat: 4.651890,
    lng: -74.104050,
  ),
  _PuntoPredefinido(
    id: 'zona_industrial',
    label: 'Zona Industrial (Calle 13 con 50)',
    direccion: 'Calle 13 #50, Zona Industrial, Bogotá',
    lat: 4.629800,
    lng: -74.111600,
  ),
  _PuntoPredefinido(
    id: 'bodega_fontibon',
    label: 'Bodega Fontibón',
    direccion: 'Fontibón, Bogotá',
    lat: 4.672500,
    lng: -74.146000,
  ),
];

// ================== Sidebar ==================
class SidebarCliente extends StatelessWidget {
  final String selected; // ruta actual
  const SidebarCliente({super.key, required this.selected});

  @override
  Widget build(BuildContext context) {
    Widget item({
      required IconData icon,
      required String label,
      required String route,
    }) {
      final sel = (selected == route);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: InkWell(
          onTap: () {
            if (!sel) Navigator.pushReplacementNamed(context, route);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: sel ? Colors.white.withOpacity(0.06) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(label,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      width: 260,
      color: kNavy,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: const [
            Icon(Icons.local_shipping, color: Colors.white),
            SizedBox(width: 10),
            Text('TRADEX LOGISTIC',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 24),
          item(
              icon: Icons.alt_route,
              label: 'Creación de rutas',
              route: ClientesRoutes.creacion),
          item(
              icon: Icons.hourglass_bottom,
              label: 'Rutas pendientes',
              route: ClientesRoutes.pendientes),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24)),
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (r) => false),
              child: const Text('Salir'),
            ),
          ),
        ],
      ),
    );
  }
}

// ================== Página: Creación de rutas ==================
class CreacionRutaPage extends StatefulWidget {
  const CreacionRutaPage({super.key});

  @override
  State<CreacionRutaPage> createState() => _CreacionRutaPageState();
}

class _CreacionRutaPageState extends State<CreacionRutaPage> {
  final _formKey = GlobalKey<FormState>();

  // Header
  final _nombreCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _fechaCtrl = TextEditingController(); // YYYY-MM-DD
  final _horaIniCtrl = TextEditingController(); // HH:mm

  // Carga (meta)
  final _pesoCtrl = TextEditingController();
  final _volumenCtrl = TextEditingController();
  final _tipoCargaCtrl = TextEditingController();

  bool _guardando = false;

  // Paradas
  final List<_ParadaModel> _paradas = [_ParadaModel()];

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    _fechaCtrl.dispose();
    _horaIniCtrl.dispose();
    _pesoCtrl.dispose();
    _volumenCtrl.dispose();
    _tipoCargaCtrl.dispose();
    for (final p in _paradas) {
      p.dispose();
    }
    super.dispose();
  }

  void _agregarParada() => setState(() => _paradas.add(_ParadaModel()));
  void _eliminarParada(int i) =>
      setState(() => _paradas.removeAt(i).dispose());

  String _genCodigo() => 'TRX-${DateTime.now().millisecondsSinceEpoch}';

  Future<void> _pickFecha() async {
    final hoy = DateTime.now();
    final sel = await showDatePicker(
      context: context,
      firstDate: hoy.subtract(const Duration(days: 1)),
      lastDate: hoy.add(const Duration(days: 365)),
      initialDate: hoy,
    );
    if (sel != null) {
      _fechaCtrl.text =
          '${sel.year.toString().padLeft(4, '0')}-${sel.month.toString().padLeft(2, '0')}-${sel.day.toString().padLeft(2, '0')}';
      setState(() {});
    }
  }

  Future<void> _pickHora() async {
    final now = TimeOfDay.now();
    final sel = await showTimePicker(context: context, initialTime: now);
    if (sel != null) {
      _horaIniCtrl.text =
          '${sel.hour.toString().padLeft(2, '0')}:${sel.minute.toString().padLeft(2, '0')}';
      setState(() {});
    }
  }

  Future<void> _guardar() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    if (_paradas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Agrega al menos una parada')));
      return;
    }

    // Validar lat/lng de cada parada
    for (int i = 0; i < _paradas.length; i++) {
      final p = _paradas[i];
      final lat = double.tryParse(p.latCtrl.text);
      final lng = double.tryParse(p.lngCtrl.text);
      if (lat == null || lng == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Parada #${i + 1}: latitud/longitud inválidas')));
        return;
      }
    }

    setState(() => _guardando = true);
    try {
      final meta = <String, dynamic>{
        if (_pesoCtrl.text.trim().isNotEmpty)
          'peso_kg': double.tryParse(_pesoCtrl.text.trim()),
        if (_volumenCtrl.text.trim().isNotEmpty)
          'volumen_m3': double.tryParse(_volumenCtrl.text.trim()),
        if (_tipoCargaCtrl.text.trim().isNotEmpty)
          'tipo_carga': _tipoCargaCtrl.text.trim(),
      }..removeWhere((_, v) => v == null);

      final clienteId = Session.userId!;
      final creadoPor = Session.userId!;

      // Cliente SOLO crea la ruta -> estado planificada, sin conductor ni vehículo
      final r = await Api.crearRuta(
        codigo: _genCodigo(),
        nombre: _nombreCtrl.text.trim(),
        descripcion: _descripcionCtrl.text.trim().isEmpty
            ? null
            : _descripcionCtrl.text.trim(),
        estado: 'planificada',
        fechaProgramada:
            _fechaCtrl.text.trim().isEmpty ? null : _fechaCtrl.text.trim(),
        horaInicio:
            _horaIniCtrl.text.trim().isEmpty ? null : _horaIniCtrl.text.trim(),
        clienteId: clienteId,
        creadoPor: creadoPor,
        meta: meta.isEmpty ? null : meta,
      );
      final rutaId = (r['id'] as num).toInt();

      // Paradas
      for (int i = 0; i < _paradas.length; i++) {
        final p = _paradas[i];
        await Api.agregarParada(
          rutaId: rutaId,
          orden: i + 1,
          lat: double.parse(p.latCtrl.text),
          lng: double.parse(p.lngCtrl.text),
          titulo: p.tituloCtrl.text.trim().isEmpty
              ? null
              : p.tituloCtrl.text.trim(),
          direccion: p.dirCtrl.text.trim().isNotEmpty
              ? p.dirCtrl.text.trim()
              : null,
          notas:
              p.notasCtrl.text.trim().isEmpty ? null : p.notasCtrl.text.trim(),
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ruta #$rutaId creada correctamente')));
      _resetForm();
    } on ApiError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear ruta: ${e.message}')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo crear la ruta')));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nombreCtrl.clear();
    _descripcionCtrl.clear();
    _fechaCtrl.clear();
    _horaIniCtrl.clear();
    _pesoCtrl.clear();
    _volumenCtrl.clear();
    _tipoCargaCtrl.clear();
    for (final p in _paradas) {
      p.dispose();
    }
    _paradas
      ..clear()
      ..add(_ParadaModel());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Row(
        children: [
          const SidebarCliente(selected: ClientesRoutes.creacion),
          Expanded(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hola, ${Session.name ?? "Cliente"}',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: kTexto)),
                  const SizedBox(height: 8),
                  const Text('Creación de rutas',
                      style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: kTexto)),
                  const SizedBox(height: 14),

                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: kBordeSuave),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Datos de la ruta',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 12),

                            // Nombre + Fecha + Hora (con pickers)
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    controller: _nombreCtrl,
                                    decoration: const InputDecoration(
                                      labelText: 'Nombre de la ruta',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                            ? 'Ingresa el nombre'
                                            : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _fechaCtrl,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: 'Fecha (YYYY-MM-DD)',
                                      border: const OutlineInputBorder(),
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.calendar_month),
                                        onPressed: _pickFecha,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _horaIniCtrl,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: 'Hora inicio (HH:mm)',
                                      border: const OutlineInputBorder(),
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.schedule),
                                        onPressed: _pickHora,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Descripción
                            TextFormField(
                              controller: _descripcionCtrl,
                              minLines: 2,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                labelText: 'Descripción (opcional)',
                                border: OutlineInputBorder(),
                              ),
                            ),

                            const SizedBox(height: 18),
                            const Divider(),
                            const SizedBox(height: 6),

                            // Carga
                            const Text('Datos de la carga (opcional)',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _pesoCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Peso (kg)',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _volumenCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Volumen (m³)',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _tipoCargaCtrl,
                                    decoration: const InputDecoration(
                                      labelText: 'Tipo de carga',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),
                            const Divider(),
                            const SizedBox(height: 6),

                            // Paradas (solo direcciones predefinidas)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Paradas',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700)),
                                OutlinedButton.icon(
                                  onPressed: _agregarParada,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Agregar parada'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            for (int i = 0; i < _paradas.length; i++)
                              _ParadaCard(
                                index: i,
                                model: _paradas[i],
                              ),

                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _guardando ? null : _guardar,
                                child: _guardando
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : const Text('Crear ruta'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParadaModel {
  final tituloCtrl = TextEditingController();
  final dirCtrl = TextEditingController();
  final latCtrl = TextEditingController();
  final lngCtrl = TextEditingController();
  final notasCtrl = TextEditingController();

  String? puntoSeleccionadoId;

  void aplicarPunto(_PuntoPredefinido p) {
    tituloCtrl.text = p.label;
    dirCtrl.text = p.direccion;
    latCtrl.text = p.lat.toStringAsFixed(6);
    lngCtrl.text = p.lng.toStringAsFixed(6);
  }

  void dispose() {
    tituloCtrl.dispose();
    dirCtrl.dispose();
    latCtrl.dispose();
    lngCtrl.dispose();
    notasCtrl.dispose();
  }
}

class _ParadaCard extends StatefulWidget {
  final int index;
  final _ParadaModel model;

  const _ParadaCard({required this.index, required this.model});

  @override
  State<_ParadaCard> createState() => _ParadaCardState();
}

class _ParadaCardState extends State<_ParadaCard> {
  @override
  Widget build(BuildContext context) {
    final m = widget.model;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: kBordeSuave),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Text('Parada #${widget.index + 1}',
                    style:
                        const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 8),

            // Selector de punto predefinido
            DropdownButtonFormField<String>(
              value: m.puntoSeleccionadoId,
              decoration: const InputDecoration(
                labelText: 'Punto predefinido',
                border: OutlineInputBorder(),
              ),
              items: kPuntosPredefinidos
                  .map(
                    (p) => DropdownMenuItem(
                      value: p.id,
                      child: Text(p.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  m.puntoSeleccionadoId = value;
                  final punto = kPuntosPredefinidos
                      .firstWhere((p) => p.id == value);
                  m.aplicarPunto(punto);
                });
              },
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: m.tituloCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Título (opcional)',
                        border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: m.dirCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Dirección (opcional)',
                        border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: m.latCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Latitud',
                        border: OutlineInputBorder()),
                    validator: (v) =>
                        (v == null || double.tryParse(v) == null)
                            ? 'Lat inválida'
                            : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: m.lngCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Longitud',
                        border: OutlineInputBorder()),
                    validator: (v) =>
                        (v == null || double.tryParse(v) == null)
                            ? 'Lng inválida'
                            : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: m.notasCtrl,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                  border: OutlineInputBorder()),
            ),
          ],
        ),
      ),
    );
  }
}

// ================== Página: Rutas pendientes ==================
class RutasPendientesPage extends StatefulWidget {
  const RutasPendientesPage({super.key});
  @override
  State<RutasPendientesPage> createState() => _RutasPendientesPageState();
}

class _RutasPendientesPageState extends State<RutasPendientesPage> {
  List<Map<String, dynamic>> _rutas = [];
  bool _cargando = false;
  String? _filtroEstado;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    try {
      final resp = await Api.listarRutasCliente(Session.userId!,
          estado: _filtroEstado);
      final data = (resp['data'] ?? []) as List;
      setState(() => _rutas =
          data.cast<Map>().map((e) => e.cast<String, dynamic>()).toList());
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _abrirMapa(int rutaId, String titulo) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: SizedBox(
          width: 900,
          height: 560,
          child: _MapaRutaDialog(rutaId: rutaId, titulo: titulo),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Row(
        children: [
          const SidebarCliente(selected: ClientesRoutes.pendientes),
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hola, ${Session.name ?? "Cliente"}',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: kTexto)),
                  const SizedBox(height: 8),
                  const Text('Rutas pendientes',
                      style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: kTexto)),
                  const SizedBox(height: 14),

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
                              value: 'cancelada', child: Text('Cancelada')),
                        ],
                        onChanged: (v) {
                          setState(() => _filtroEstado = v);
                          _cargar();
                        },
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: _cargar,
                        icon: _cargando
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.refresh),
                        label: const Text('Actualizar'),
                      ),
                      if (_filtroEstado != null)
                        TextButton(
                          onPressed: () {
                            setState(() => _filtroEstado = null);
                            _cargar();
                          },
                          child: const Text('Quitar filtro'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: kBordeSuave),
                      ),
                      child: _rutas.isEmpty
                          ? const Center(child: Text('Sin rutas'))
                          : Column(
                              children: [
                                // Cabecera de la tabla
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
                                                      FontWeight.w700))),
                                      Expanded(
                                          flex: 3,
                                          child: Text('Nombre',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.w700))),
                                      Expanded(
                                          flex: 2,
                                          child: Text('Estado',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.w700))),
                                      Expanded(
                                          flex: 3,
                                          child: Text('Conductor',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.w700))),
                                      Expanded(
                                          flex: 2,
                                          child: Text('Vehículo',
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.w700))),
                                      SizedBox(width: 160, child: Text('')),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: ListView.separated(
                                    padding: const EdgeInsets.all(12),
                                    itemBuilder: (_, i) {
                                      final r = _rutas[i];
                                      return _RowRuta(
                                        codigo: '${r['codigo']}',
                                        nombre: '${r['nombre']}',
                                        estado: '${r['estado']}',
                                        conductor:
                                            r['conductor_nombre'] ?? '-',
                                        vehiculo:
                                            r['vehiculo_id']?.toString() ??
                                                '-',
                                        onMapa: () => _abrirMapa(
                                          (r['id'] as num).toInt(),
                                          r['nombre'] ??
                                              r['codigo'] ??
                                              'Ruta',
                                        ),
                                      );
                                    },
                                    separatorBuilder: (_, __) =>
                                        const Divider(color: kBordeSuave),
                                    itemCount: _rutas.length,
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

class _RowRuta extends StatelessWidget {
  final String codigo;
  final String nombre;
  final String estado;
  final String conductor;
  final String vehiculo;
  final VoidCallback onMapa;

  const _RowRuta({
    required this.codigo,
    required this.nombre,
    required this.estado,
    required this.conductor,
    required this.vehiculo,
    required this.onMapa,
  });

  @override
  Widget build(BuildContext context) {
    final color = (estado == 'completada') ? kVerde : kTexto;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: Text(codigo,
                  style: const TextStyle(fontWeight: FontWeight.w700))),
          Expanded(flex: 3, child: Text(nombre)),
          Expanded(
              flex: 2,
              child: Text(estado,
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.w700))),
          Expanded(flex: 3, child: Text(conductor)),
          Expanded(flex: 2, child: Text(vehiculo)),
          SizedBox(
            width: 160,
            child: OutlinedButton.icon(
              onPressed: onMapa,
              icon: const Icon(Icons.map_outlined),
              label: const Text('Ver mapa'),
            ),
          )
        ],
      ),
    );
  }
}

class _MapaRutaDialog extends StatefulWidget {
  final int rutaId;
  final String titulo;
  const _MapaRutaDialog(
      {super.key, required this.rutaId, required this.titulo});
  @override
  State<_MapaRutaDialog> createState() => _MapaRutaDialogState();
}

class _MapaRutaDialogState extends State<_MapaRutaDialog> {
  Map<String, dynamic>? _geo;
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    try {
      final resp = await Api.geojsonRuta(widget.rutaId);
      setState(() => _geo = resp);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final paradas = (_geo?['paradas']?['features'] as List?) ?? [];
    final linea = _geo?['linea'] as Map<String, dynamic>?;

    LatLng center = const LatLng(4.7110, -74.0721); // Bogotá fallback
    if (paradas.isNotEmpty) {
      final first = (paradas.first as Map)['geometry']['coordinates'] as List;
      center = LatLng(
        (first[1] as num).toDouble(),
        (first[0] as num).toDouble(),
      );
    }

    final poly =
        (linea?['geometry']?['coordinates'] as List?)?.map((c) {
      final l = c as List;
      return LatLng(
        (l[1] as num).toDouble(),
        (l[0] as num).toDouble(),
      );
    }).toList();

    return Column(
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: kBordeSuave)),
          ),
          child: Row(
            children: [
              Text(widget.titulo,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
        Expanded(
          child: _cargando
              ? const Center(child: CircularProgressIndicator())
              : FlutterMap(
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: 12.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.tradex_web',
                    ),
                    if (poly != null && poly.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(points: poly, strokeWidth: 4.0),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        for (final f in paradas)
                          () {
                            final g = (f as Map)['geometry'];
                            final props = f['properties'] as Map;
                            final coords = g['coordinates'] as List;
                            final p = LatLng(
                              (coords[1] as num).toDouble(),
                              (coords[0] as num).toDouble(),
                            );
                            return Marker(
                              point: p,
                              width: 150,
                              height: 80,
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: kVerde,
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${props['orden']}. ${props['titulo'] ?? 'Parada'}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(Icons.location_on,
                                      color: kVerde, size: 36),
                                ],
                              ),
                            );
                          }(),
                      ],
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
