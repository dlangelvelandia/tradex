// Archivo: lib/clientes/clientes_pages.dart
// Pantallas de "Creación de rutas" y "Rutas pendientes" + SidebarCliente.

import 'package:flutter/material.dart';
import 'clientes_rutas.dart';

// ----------- Paleta local mínima -----------
const kNavy  = Color(0xFF0D2234);
const kBg    = Color(0xFFF5F6FB);
const kTexto = Color(0xFF0F172A);
const kMuted = Color(0xFF6B7280);
const kBordeSuave = Color(0xFFE5E7EB);

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
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
              Icon(Icons.local_shipping, color: Colors.white),
              SizedBox(width: 10),
              Text('TRADEX LOGISTIC',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 24),
          item(icon: Icons.alt_route, label: 'Creación de rutas', route: ClientesRoutes.creacion),
          item(icon: Icons.hourglass_bottom, label: 'Rutas pendientes', route: ClientesRoutes.pendientes),
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
                Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
              },
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
  final _direccionCtrl = TextEditingController();
  final _instruccionesCtrl = TextEditingController();
  bool _guardando = false;

  @override
  void dispose() {
    _direccionCtrl.dispose();
    _instruccionesCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;
    setState(() => _guardando = true);
    await Future.delayed(const Duration(milliseconds: 700)); // simulación
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ruta guardada (simulado)')),
    );
    setState(() => _guardando = false);
    _direccionCtrl.clear();
    _instruccionesCtrl.clear();
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Hola, Cliente',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: kTexto)),
                  const SizedBox(height: 8),
                  const Text('Creación de rutas',
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: kTexto)),
                  const SizedBox(height: 14),
                  Card(
                    color: Colors.white,
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
                            const Text('Destinatario',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _direccionCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Dirección',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Ingrese la dirección'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _instruccionesCtrl,
                              minLines: 3,
                              maxLines: 6,
                              decoration: const InputDecoration(
                                labelText: 'Instrucciones',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _guardando ? null : _guardar,
                                child: _guardando
                                    ? const SizedBox(
                                        width: 18, height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Text('Guardar ruta'),
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

// ================== Página: Rutas pendientes ==================
class RutasPendientesPage extends StatelessWidget {
  const RutasPendientesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const [
      ['Juan Pérez', 'Calle 123\nMedellín', 'Dejar en portería'],
      ['Rosa López', 'Carrera 45,\nEnvigado', 'Llamar al llegar'],
    ];

    TableRow _header() => const TableRow(
      decoration: BoxDecoration(color: Colors.white),
      children: [
        _Cell(text: 'Destinatario', isHeader: true),
        _Cell(text: 'Dirección', isHeader: true),
        _Cell(text: 'Instrucciones', isHeader: true),
      ],
    );

    TableRow _row(List<String> r) => TableRow(
      decoration: const BoxDecoration(color: Colors.white),
      children: [
        _Cell(text: r[0]),
        _Cell(text: r[1]),
        _Cell(text: r[2]),
      ],
    );

    return Scaffold(
      backgroundColor: kBg,
      body: Row(
        children: [
          const SidebarCliente(selected: ClientesRoutes.pendientes),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Hola, Cliente',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: kTexto)),
                  const SizedBox(height: 8),
                  const Text('Rutas pendientes',
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: kTexto)),
                  const SizedBox(height: 14),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: kBordeSuave),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(2.2),
                        1: FlexColumnWidth(2.6),
                        2: FlexColumnWidth(2.6),
                      },
                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                      border: TableBorder.symmetric(
                        inside: BorderSide(color: kBordeSuave.withOpacity(.7)),
                      ),
                      children: [
                        _header(),
                        for (final r in items) _row(r),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: 300,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Actualizar lista'),
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

class _Cell extends StatelessWidget {
  final String text;
  final bool isHeader;
  const _Cell({required this.text, this.isHeader = false});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: isHeader ? FontWeight.w700 : FontWeight.w500,
      fontSize: isHeader ? 16 : 14,
      color: kTexto,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Text(text, style: style),
    );
  }
}
