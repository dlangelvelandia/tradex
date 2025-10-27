import 'package:flutter/material.dart';
import 'conductores_rutas.dart';

// --------- Paleta local mínima ---------
const kNavy = Color(0xFF0D2234);
const kNavy2 = Color(0xFF12314A);
const kVerde = Color(0xFF21BF73);
const kBg = Color(0xFFF3F5F9);
const kTexto = Color(0xFF111827);
const kBordeSuave = Color(0xFFE5E7EB);

// ================== Sidebar ==================
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

          // navegación
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

          // --- NUEVO: separador y botón de salida ---
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

  // --- NUEVO: botón de Salir ---
  Widget _logout(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // vuelve al Login y limpia el stack
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        },
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.logout, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text('Salir',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ============ Pantalla: Rutas asignadas ============
class RutasAsignadasPage extends StatelessWidget {
  const RutasAsignadasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final filas = [
      _RutaData(id: '2680', FechaEnvio: '06/02/2025 · 1:36 pm', FechaEntrega: '', contacto: '69032909', estado: 'En tránsito'),
      _RutaData(id: '2165', FechaEnvio: '08/02/2025 · 11:50 pm', FechaEntrega: '', contacto: '610123456', estado: 'En espera'),
      _RutaData(id: '2212', FechaEnvio: '26/10/2025 · 10:00 am', FechaEntrega: '30/10/2025 · 11:00 am', contacto: '601890123', estado: 'Entregado'),
    ];

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
                  const Text('Hola, Conductor',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: kTexto)),
                  const SizedBox(height: 6),
                  const Text('Rutas asignadas',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: kTexto)),
                  const SizedBox(height: 16),

                  // Placeholder de mapa
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: kBordeSuave),
                    ),
                    child: SizedBox(
                      height: 220,
                      child: Center(
                        child: Text('Mapa de ruta (placeholder)',
                            style: Theme.of(context).textTheme.bodySmall),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: kBordeSuave),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Column(
                        children: [
                          _headerRutas(),
                          const Divider(height: 24, color: kBordeSuave),
                          for (final r in filas) _rowRuta(r),
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

  Widget _headerRutas() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          children: const [
            _Cell('Ruta', flex: 2, isHeader: true),
            _Cell('Fecha de despacho', flex: 3, isHeader: true),
            _Cell('Fecha de Entrega', flex: 3, isHeader: true),
            _Cell('Contacto', flex: 2, isHeader: true),
            _Cell('Estado', flex: 2, isHeader: true),
          ],
        ),
      );

  Widget _rowRuta(_RutaData d) {
    final estadoColor = (d.estado.toLowerCase().contains('tránsito') ||
            d.estado.toLowerCase().contains('entregado'))
        ? kVerde
        : kTexto;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Row(
            children: [
              _Cell(d.id, flex: 2),
              _Cell(d.FechaEnvio, flex: 3),
              _Cell(d.FechaEntrega, flex: 3),
              _Cell(d.contacto, flex: 2, emphasize: true, underline: true),
              _Cell(d.estado, flex: 2, emphasize: true, color: estadoColor),
            ],
          ),
        ),
        const Divider(height: 0, color: kBordeSuave),
      ],
    );
  }
}

// ========== Pantalla: Vehículos vinculados ==========
class VehiculosVinculadosPage extends StatelessWidget {
  const VehiculosVinculadosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _Vehiculo(no: '3312', estado: 'Activo',   modelo: 'Chevrolet N300'),
      _Vehiculo(no: '5677', estado: 'Inactivo', modelo: 'Mercedes-Benz Atego'),
      _Vehiculo(no: '3641', estado: 'Activo',  modelo: 'Volkswagen Delivery'),
    ];

    return Scaffold(
      backgroundColor: kBg,
      body: Row(
        children: [
          const SidebarConductor(selected: ConductoresRoutes.vehiculos),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Hola, Conductor',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: kTexto)),
                  const SizedBox(height: 6),
                  const Text('Vehículos vinculados',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: kTexto)),
                  const SizedBox(height: 16),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: kBordeSuave),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Column(
                        children: [
                          _headerVehiculos(),
                          const Divider(height: 24, color: kBordeSuave),
                          for (final v in items) _rowVehiculo(v),
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

  Widget _headerVehiculos() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          children: const [
            _Cell('No.', flex: 1, isHeader: true),
            _Cell('Estado', flex: 2, isHeader: true),
            _Cell('Modelo', flex: 4, isHeader: true),
          ],
        ),
      );

  Widget _rowVehiculo(_Vehiculo v) {
    final activo = v.estado.toLowerCase() == 'activo';
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Row(
            children: [
              _Cell(v.no, flex: 1),
              _Cell(v.estado, flex: 2, emphasize: true, color: activo ? kVerde : kTexto),
              _Cell(v.modelo, flex: 4),
            ],
          ),
        ),
        const Divider(height: 0, color: kBordeSuave),
      ],
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

class _RutaData {
  final String id, FechaEnvio, FechaEntrega, contacto, estado;
  _RutaData({required this.id, required this.FechaEnvio, required this.FechaEntrega, required this.contacto, required this.estado});
}

class _Vehiculo {
  final String no, estado, modelo;
  _Vehiculo({required this.no, required this.estado, required this.modelo});
}
