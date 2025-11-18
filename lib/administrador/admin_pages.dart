import 'package:flutter/material.dart';

// ----------- Paleta (coincidente con cliente) -----------
const kNavy = Color(0xFF0D2234);
const kBg = Color(0xFFF5F6FB);
const kTexto = Color(0xFF0F172A);
const kMuted = Color(0xFF6B7280);
const kBordeSuave = Color(0xFFE5E7EB);
const kVerde = Color(0xFF21BF73);
const kAzul = Color(0xFF2563EB);
const kNaranja = Color(0xFFF59E0B);

// ================== Sidebar ==================
class SidebarAdmin extends StatelessWidget {
  final String selected; // ruta actual
  const SidebarAdmin({super.key, required this.selected});

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
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
          // Logo
          Row(
            children: const [
              Icon(Icons.admin_panel_settings, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'TRADEX ADMIN',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          item(
            icon: Icons.dashboard,
            label: 'Dashboard',
            route: '/admin/dashboard',
          ),
          item(icon: Icons.people, label: 'Usuarios', route: '/admin/usuarios'),
          item(
            icon: Icons.local_shipping,
            label: 'Vehículos',
            route: '/admin/vehiculos',
          ),
          item(icon: Icons.alt_route, label: 'Rutas', route: '/admin/rutas'),
          const Spacer(),
          // Botón Salir
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white24),
              ),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (r) => false,
                );
              },
              child: const Text('Salir'),
            ),
          ),
        ],
      ),
    );
  }
}

// ================== Página: Dashboard ==================
class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos estáticos por ahora; luego los cargamos desde la API.
    final data = {
      'Usuarios': {'valor': 120, 'color': kAzul, 'icono': Icons.people},
      'Vehículos': {
        'valor': 45,
        'color': kVerde,
        'icono': Icons.directions_car,
      },
      'Rutas Activas': {
        'valor': 12,
        'color': kNaranja,
        'icono': Icons.alt_route,
      },
    };

    return Scaffold(
      backgroundColor: kBg,
      body: Row(
        children: [
          const SidebarAdmin(selected: '/admin/dashboard'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bienvenido, Administrador',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: kTexto,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Panel de control',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: kTexto,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: data.entries.map((e) {
                      final d = e.value;
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: _InfoCard(
                          titulo: e.key,
                          valor: d['valor'] as int,
                          color: d['color'] as Color,
                          icono: d['icono'] as IconData,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kBordeSuave),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: const Text(
                      'Aquí podrás agregar gráficos, filtros y tablas con detalles de las rutas.',
                      style: TextStyle(fontSize: 16, color: kMuted),
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

// ================== Página: Rutas (lista) ==================
class AdminRutasPage extends StatelessWidget {
  const AdminRutasPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos de ejemplo
    final rutas = [
      {
        'id': 'R-001',
        'origen': 'Bogotá',
        'destino': 'Bogotá',
        'vehiculo': 'ABC-123',
        'estado': 'Activa',
      },
      {
        'id': 'R-002',
        'origen': 'Bogotá',
        'destino': 'Bogotá',
        'vehiculo': 'XYZ-789',
        'estado': 'Activa',
      },
      {
        'id': 'R-003',
        'origen': 'Bogotá',
        'destino': 'Bogotá',
        'vehiculo': 'LMN-456',
        'estado': 'En pausa',
      },
    ];

    return Scaffold(
      backgroundColor: kBg,
      body: Row(
        children: [
          SidebarAdmin(selected: '/admin/rutas'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gestión de Rutas',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: kTexto,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Rutas activas',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: kTexto,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Tabla simple
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kBordeSuave),
                    ),
                    child: Table(
                      columnWidths: const {
                        0: FixedColumnWidth(80),
                        1: FlexColumnWidth(2),
                        2: FlexColumnWidth(2),
                        3: FixedColumnWidth(120),
                        4: FixedColumnWidth(120),
                      },
                      border: TableBorder.symmetric(
                        inside: BorderSide(color: kBordeSuave.withOpacity(.7)),
                      ),
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: [
                        // header
                        TableRow(
                          decoration: const BoxDecoration(color: Colors.white),
                          children: const [
                            _Cell(text: 'ID', isHeader: true),
                            _Cell(text: 'Origen', isHeader: true),
                            _Cell(text: 'Destino', isHeader: true),
                            _Cell(text: 'Vehículo', isHeader: true),
                            _Cell(text: 'Estado', isHeader: true),
                          ],
                        ),
                        // filas
                        for (final r in rutas)
                          TableRow(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                            children: [
                              _Cell(text: r['id']!),
                              _Cell(text: r['origen']!),
                              _Cell(text: r['destino']!),
                              _Cell(text: r['vehiculo']!),
                              _Cell(text: r['estado']!),
                            ],
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),
                  SizedBox(
                    width: 220,
                    child: ElevatedButton(
                      onPressed: () {
                        // Aquí más adelante haremos fetch desde el backend
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Actualizar (simulado)'),
                          ),
                        );
                      },
                      child: const Text('Actualizar lista'),
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

// ================== UI helpers ==================
class _InfoCard extends StatelessWidget {
  final String titulo;
  final int valor;
  final Color color;
  final IconData icono;

  const _InfoCard({
    required this.titulo,
    required this.valor,
    required this.color,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: kBordeSuave),
      ),
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icono, size: 46, color: color),
            const SizedBox(height: 12),
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kTexto,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              valor.toString(),
              style: TextStyle(
                fontSize: 34,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String text;
  final bool isHeader;
  const _Cell({required this.text, this.isHeader = false});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: isHeader ? FontWeight.w700 : FontWeight.w500,
      fontSize: isHeader ? 15 : 14,
      color: kTexto,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Text(text, style: style),
    );
  }
}
