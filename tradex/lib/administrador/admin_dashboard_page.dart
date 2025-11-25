// Archivo: lib/administrador/admin_dashboard_page.dart

import 'package:flutter/material.dart';
import 'sidebar_admin.dart';
import 'package:tradex_web/services/api.dart';

enum _DashboardDetail {
  none,
  usuarios,
  vehiculos,
  rutas,
}

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  bool _cargandoStats = false;

  int _totalUsuarios = 0;
  int _totalClientes = 0;
  int _totalConductores = 0;
  int _totalVehiculos = 0;
  int _rutasActivas = 0;

  // Detalle seleccionado
  _DashboardDetail _detalle = _DashboardDetail.none;

  // Datos de usuarios para el detalle
  bool _cargandoUsuarios = false;
  List<Map<String, dynamic>> _usuarios = [];

  // Datos de vehículos
  bool _cargandoVehiculos = false;
  List<Map<String, dynamic>> _vehiculos = [];

  // Datos de rutas
  bool _cargandoRutas = false;
  List<Map<String, dynamic>> _rutas = [];

  @override
  void initState() {
    super.initState();
    _cargarStats();
  }

  // ----------------------- STATS -----------------------
  Future<void> _cargarStats() async {
    setState(() => _cargandoStats = true);
    try {
      // Usuarios por rol
      final clientes =
          await Api.listarUsuariosPorRol('Cliente', perPage: 500, page: 1);
      final conductores =
          await Api.listarUsuariosPorRol('Conductor', perPage: 500, page: 1);

      _totalClientes = clientes.length;
      _totalConductores = conductores.length;
      _totalUsuarios = _totalClientes + _totalConductores;

      // Vehículos
      final vehResp = await Api.listarVehiculos(perPage: 1, page: 1);
      final totalVehRaw =
          vehResp['total'] ?? (vehResp['data'] as List?)?.length ?? 0;
      _totalVehiculos = (totalVehRaw as num).toInt();

      // Rutas (cuántas están “activas”)
      final rutasResp = await Api.listarRutasAdmin(perPage: 200, page: 1);
      final data = (rutasResp['data'] ?? []) as List;
      _rutasActivas = data.where((e) {
        final m = (e as Map).cast<String, dynamic>();
        final estado = (m['estado'] ?? '') as String;
        return estado != 'completada' && estado != 'cancelada';
      }).length;
    } catch (_) {
      // Si algo falla, dejamos los contadores como estén
    } finally {
      if (mounted) setState(() => _cargandoStats = false);
    }
  }

  // ------------------- DETALLE: USUARIOS -------------------
  Future<void> _mostrarDetalleUsuarios() async {
    setState(() {
      _detalle = _DashboardDetail.usuarios;
      _cargandoUsuarios = true;
      _usuarios.clear();
    });

    try {
      final clientes =
          await Api.listarUsuariosPorRol('Cliente', perPage: 500, page: 1);
      final conductores =
          await Api.listarUsuariosPorRol('Conductor', perPage: 500, page: 1);

      final lista = <Map<String, dynamic>>[];

      for (final c in clientes) {
        final m = Map<String, dynamic>.from(c);
        m['rol'] = 'Cliente';
        lista.add(m);
      }
      for (final c in conductores) {
        final m = Map<String, dynamic>.from(c);
        m['rol'] = 'Conductor';
        lista.add(m);
      }

      if (mounted) {
        setState(() => _usuarios = lista);
      }
    } on ApiError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar usuarios: ${e.message}')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudieron cargar los usuarios')),
      );
    } finally {
      if (mounted) setState(() => _cargandoUsuarios = false);
    }
  }

  // ------------------- DETALLE: VEHÍCULOS -------------------
  Future<void> _mostrarDetalleVehiculos() async {
    setState(() {
      _detalle = _DashboardDetail.vehiculos;
      _cargandoVehiculos = true;
      _vehiculos.clear();
    });

    try {
      final resp = await Api.listarVehiculos(perPage: 500, page: 1);
      final list = (resp['data'] ?? []) as List;
      final vehs =
          list.cast<Map>().map((e) => e.cast<String, dynamic>()).toList();
      if (mounted) setState(() => _vehiculos = vehs);
    } on ApiError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar vehículos: ${e.message}')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudieron cargar los vehículos')),
      );
    } finally {
      if (mounted) setState(() => _cargandoVehiculos = false);
    }
  }

  // ------------------- DETALLE: RUTAS -------------------
  Future<void> _mostrarDetalleRutas() async {
    setState(() {
      _detalle = _DashboardDetail.rutas;
      _cargandoRutas = true;
      _rutas.clear();
    });

    try {
      final resp = await Api.listarRutasAdmin(perPage: 500, page: 1);
      final list = (resp['data'] ?? []) as List;
      final rutas =
          list.cast<Map>().map((e) => e.cast<String, dynamic>()).toList();
      if (mounted) setState(() => _rutas = rutas);
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
      if (mounted) setState(() => _cargandoRutas = false);
    }
  }

  Future<void> _abrirDialogAsignarRuta({
    required int rutaId,
    required String codigo,
    required String nombre,
    int? conductorActualId,
  }) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (_) => _AsignarConductorDialogAdmin(
            rutaId: rutaId,
            rutaCodigo: codigo,
            rutaNombre: nombre,
            conductorActualId: conductorActualId,
          ),
        ) ??
        false;

    if (ok) {
      // refrescar rutas y stats
      await _mostrarDetalleRutas();
      await _cargarStats();
    }
  }

  // ------------------- UI -------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Row(
        children: [
          const SidebarAdmin(selected: '/admin/dashboard'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header + botón de refrescar
                  Row(
                    children: [
                      Text(
                        'Panel de administración',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: _cargandoStats ? null : _cargarStats,
                        icon: _cargandoStats
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.refresh),
                        tooltip: 'Actualizar métricas',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Resumen general del sistema',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),

                  // Tarjetas de stats
                  Row(
                    children: [
                      _StatCard(
                        title: 'Usuarios',
                        value: _cargandoStats ? '...' : '$_totalUsuarios',
                        subtitle: _cargandoStats
                            ? null
                            : '$_totalClientes clientes • $_totalConductores conductores',
                        icon: Icons.people_alt_outlined,
                        onTap: _mostrarDetalleUsuarios,
                      ),
                      const SizedBox(width: 16),
                      _StatCard(
                        title: 'Vehículos',
                        value: _cargandoStats ? '...' : '$_totalVehiculos',
                        icon: Icons.local_shipping_outlined,
                        onTap: _mostrarDetalleVehiculos,
                      ),
                      const SizedBox(width: 16),
                      _StatCard(
                        title: 'Rutas activas',
                        value: _cargandoStats ? '...' : '$_rutasActivas',
                        icon: Icons.alt_route,
                        onTap: _mostrarDetalleRutas,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Detalle debajo de las tarjetas
                  Expanded(
                    child: _buildDetalle(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetalle() {
    switch (_detalle) {
      case _DashboardDetail.usuarios:
        return _buildDetalleUsuarios();
      case _DashboardDetail.vehiculos:
        return _buildDetalleVehiculos();
      case _DashboardDetail.rutas:
        return _buildDetalleRutas();
      case _DashboardDetail.none:
      default:
        return const Center(
          child: Text(
            'Selecciona una tarjeta para ver más detalle.\n'
            'Por ejemplo, haz clic en "Usuarios", "Vehículos" o "Rutas activas".',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        );
    }
  }

  // -------- UI detalle: Usuarios --------
  Widget _buildDetalleUsuarios() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: kBordeSuave),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título + loader
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: kBordeSuave)),
            ),
            child: Row(
              children: [
                const Text(
                  'Usuarios (clientes y conductores)',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: kTexto,
                  ),
                ),
                const Spacer(),
                if (_cargandoUsuarios)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Actualizar usuarios',
                    onPressed: _mostrarDetalleUsuarios,
                  ),
              ],
            ),
          ),

          if (_usuarios.isEmpty && !_cargandoUsuarios)
            const Expanded(
              child: Center(
                child: Text('No hay usuarios para mostrar'),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: _usuarios.length + 1, // +1 para cabecera
                separatorBuilder: (_, __) => const Divider(color: kBordeSuave),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // Fila de cabecera
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 8),
                      child: Row(
                        children: const [
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Nombre',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Correo',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Teléfono',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Rol',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final u = _usuarios[index - 1];
                  final nombre = (u['nombre_completo'] ?? '').toString();
                  final email = (u['email'] ?? '').toString();
                  final tel = (u['telefono'] ?? '').toString();
                  final rol = (u['rol'] ?? '').toString();

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 6, horizontal: 8),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Text(nombre)),
                        Expanded(flex: 3, child: Text(email)),
                        Expanded(flex: 2, child: Text(tel.isEmpty ? '-' : tel)),
                        Expanded(
                          flex: 2,
                          child: Text(
                            rol,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // -------- UI detalle: Vehículos --------
  Widget _buildDetalleVehiculos() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: kBordeSuave),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título + loader
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: kBordeSuave)),
            ),
            child: Row(
              children: [
                const Text(
                  'Vehículos',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: kTexto,
                  ),
                ),
                const Spacer(),
                if (_cargandoVehiculos)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Actualizar vehículos',
                    onPressed: _mostrarDetalleVehiculos,
                  ),
              ],
            ),
          ),

          if (_vehiculos.isEmpty && !_cargandoVehiculos)
            const Expanded(
              child: Center(
                child: Text('No hay vehículos para mostrar'),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: _vehiculos.length + 1,
                separatorBuilder: (_, __) => const Divider(color: kBordeSuave),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // Cabecera
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 8),
                      child: Row(
                        children: const [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Placa',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Marca / Modelo',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Año',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Estado',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Conductor (id)',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final v = _vehiculos[index - 1];
                  final placa = (v['placa'] ?? '').toString();
                  final marca = (v['marca'] ?? '').toString();
                  final modelo = (v['modelo'] ?? '').toString();
                  final anio = (v['anio'] ?? '').toString();
                  final estado = (v['estado'] ?? '').toString();
                  final conductorId = v['conductor_id'];

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 6, horizontal: 8),
                    child: Row(
                      children: [
                        Expanded(flex: 2, child: Text(placa)),
                        Expanded(
                          flex: 3,
                          child: Text(
                            [marca, modelo].where((e) => e.isNotEmpty).join(' '),
                          ),
                        ),
                        Expanded(flex: 2, child: Text(anio.isEmpty ? '-' : anio)),
                        Expanded(
                          flex: 2,
                          child: Text(
                            estado,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            conductorId == null ? '-' : '#$conductorId',
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // -------- UI detalle: Rutas --------
  Widget _buildDetalleRutas() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: kBordeSuave),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título + loader
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: kBordeSuave)),
            ),
            child: Row(
              children: [
                const Text(
                  'Rutas (todas)',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: kTexto,
                  ),
                ),
                const Spacer(),
                if (_cargandoRutas)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Actualizar rutas',
                    onPressed: _mostrarDetalleRutas,
                  ),
              ],
            ),
          ),

          if (_rutas.isEmpty && !_cargandoRutas)
            const Expanded(
              child: Center(
                child: Text('No hay rutas para mostrar'),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: _rutas.length + 1,
                separatorBuilder: (_, __) => const Divider(color: kBordeSuave),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // Cabecera
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 8),
                      child: Row(
                        children: const [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Código',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Nombre',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Cliente',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Estado',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Conductor',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Vehículo (id)',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          SizedBox(
                            width: 160,
                            child: Text(
                              'Acciones',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final r = _rutas[index - 1];
                  final rutaId = (r['id'] as num).toInt();
                  final codigo = (r['codigo'] ?? '').toString();
                  final nombre = (r['nombre'] ?? '').toString();
                  final clienteNombre = (r['cliente_nombre'] ?? '').toString();
                  final estado = (r['estado'] ?? '').toString();
                  final conductorNombre =
                      (r['conductor_nombre'] ?? '').toString();
                  final vehiculoId = r['vehiculo_id'];
                  final conductorId = r['conductor_id'] as int?;

                  Color colorEstado;
                  switch (estado) {
                    case 'completada':
                      colorEstado = kVerde;
                      break;
                    case 'cancelada':
                      colorEstado = Colors.red;
                      break;
                    case 'en_progreso':
                      colorEstado = Colors.orange;
                      break;
                    default:
                      colorEstado = kTexto;
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 6, horizontal: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            codigo,
                            style:
                                const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        Expanded(flex: 3, child: Text(nombre)),
                        Expanded(
                          flex: 3,
                          child: Text(clienteNombre.isEmpty ? '-' : clienteNombre),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            estado,
                            style: TextStyle(
                              color: colorEstado,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            conductorNombre.isEmpty ? '-' : conductorNombre,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            vehiculoId == null ? '-' : '#$vehiculoId',
                          ),
                        ),
                        SizedBox(
                          width: 160,
                          child: OutlinedButton(
                            onPressed: () => _abrirDialogAsignarRuta(
                              rutaId: rutaId,
                              codigo: codigo,
                              nombre: nombre,
                              conductorActualId: conductorId,
                            ),
                            child: Text(
                              conductorNombre.isEmpty
                                  ? 'Asignar'
                                  : 'Reasignar',
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: kBordeSuave),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 28, color: kNavy),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: kTexto,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: kTexto,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ]
              ],
            ),
          ],
        ),
      ),
    );

    return Expanded(
      child: onTap == null
          ? card
          : InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap,
              child: card,
            ),
    );
  }
}

// ========= DIÁLOGO: Asignar conductor/vehículo =========

class _AsignarConductorDialogAdmin extends StatefulWidget {
  final int rutaId;
  final String rutaCodigo;
  final String rutaNombre;
  final int? conductorActualId;

  const _AsignarConductorDialogAdmin({
    required this.rutaId,
    required this.rutaCodigo,
    required this.rutaNombre,
    this.conductorActualId,
  });

  @override
  State<_AsignarConductorDialogAdmin> createState() =>
      _AsignarConductorDialogAdminState();
}

class _AsignarConductorDialogAdminState
    extends State<_AsignarConductorDialogAdmin> {
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
      final lista =
          await Api.listarUsuariosPorRol('Conductor', perPage: 500, page: 1);
      if (!mounted) return;

      setState(() {
        _conductores = lista;
        _conductorId = widget.conductorActualId;
      });

      // si ya había conductor, cargar su vehículo
      if (_conductorId != null) {
        final v = await Api.obtenerVehiculoDeConductor(_conductorId!);
        if (mounted) setState(() => _vehiculo = v);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudieron cargar conductores')),
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
      if (mounted) setState(() => _vehiculo = v);
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
      await Api.asignarRuta(
        rutaId: widget.rutaId,
        conductorId: _conductorId!,
        vehiculoId: (_vehiculo?['id'] as num?)?.toInt(),
        // asignadoPor: podrías pasar el id del admin si lo manejas en Session
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al asignar: ${e.message}')),
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
                '${widget.rutaCodigo} • ${widget.rutaNombre}',
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
                                    (c['nombre_completo'] ??
                                            c['email'] ??
                                            '#${c['id']}')
                                        .toString(),
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
