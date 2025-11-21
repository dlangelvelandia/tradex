import 'package:flutter/material.dart';
import 'clientes_rutas.dart';

// --------- Colores ---------
const kNavy = Color(0xFF0D2234);
const kNavy2 = Color(0xFF12314A);
const kBg = Color(0xFFF3F5F9);
const kTexto = Color(0xFF111827);
const kBordeSuave = Color(0xFFE5E7EB);

// ================== Sidebar Cliente ==================
class SidebarCliente extends StatelessWidget {
  final String selected;
  const SidebarCliente({super.key, required this.selected});

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
              Text(
                'TRADEX LOGISTIC',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _item(
            context,
            icon: Icons.add_road_rounded,
            label: 'Creación de rutas',
            route: ClientesRoutes.creacion,
            selected: selected,
          ),
          const SizedBox(height: 8),
          _item(
            context,
            icon: Icons.pending_actions_rounded,
            label: 'Rutas pendientes',
            route: ClientesRoutes.pendientes,
            selected: selected,
          ),

          const Spacer(),
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 1,
            color: Colors.white.withOpacity(0.12),
          ),
          _logout(context),
        ],
      ),
    );
  }

  Widget _item(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
    required String selected,
  }) {
    final isSelected = selected == route;
    return Material(
      color: isSelected ? kNavy2 : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (!isSelected) {
            Navigator.of(context).pushReplacementNamed(route);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
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
        onTap: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.logout, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Salir',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============== Página: Creación de rutas ==================
class CreacionRutaPage extends StatefulWidget {
  const CreacionRutaPage({super.key});

  @override
  State<CreacionRutaPage> createState() => _CreacionRutaPageState();
}

class _CreacionRutaPageState extends State<CreacionRutaPage> {
  final _formKey = GlobalKey<FormState>();

  // RUTA
  final TextEditingController _nombreRutaCtrl = TextEditingController();
  final TextEditingController _fechaCtrl = TextEditingController();
  final TextEditingController _horaInicioCtrl = TextEditingController();
  final TextEditingController _descripcionCtrl = TextEditingController();

  // CARGA
  final TextEditingController _pesoCtrl = TextEditingController();
  final TextEditingController _volumenCtrl = TextEditingController();
  final TextEditingController _tipoCargaCtrl = TextEditingController();


  // CIUDAD ORIGEN / DESTINO PRINCIPAL
  String? _ciudadOrigen;
  String? _ciudadDestino;

  // PARADAS DINÁMICAS
  final List<_ParadaData> _paradas = [];

  final List<String> _ciudadesEjemplo = const [
    'Bogotá',
    'Medellín',
    'Cali',
    'Barranquilla',
    'Cartagena',
    'Bucaramanga',
  ];

  @override
  void dispose() {
    _nombreRutaCtrl.dispose();
    _fechaCtrl.dispose();
    _horaInicioCtrl.dispose();
    _descripcionCtrl.dispose();
    _pesoCtrl.dispose();
    _volumenCtrl.dispose();
    _tipoCargaCtrl.dispose();
    super.dispose();
  }

  void _agregarParada() {
    setState(() {
      _paradas.add(_ParadaData());
    });
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hola, Edwin Gonzalez',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: kTexto,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Creación de rutas',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: kTexto,
                      ),
                    ),
                    const SizedBox(height: 24),

                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: kBordeSuave),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ===== Datos de la ruta =====
                            Text(
                              'Datos de la ruta',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: _textField(
                                    controller: _nombreRutaCtrl,
                                    label: 'Nombre de la ruta',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: _textField(
                                    controller: _fechaCtrl,
                                    label: 'Fecha (YYYY-MM-DD)',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: _textField(
                                    controller: _horaInicioCtrl,
                                    label: 'Hora inicio (HH:mm)',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _textField(
                              controller: _descripcionCtrl,
                              label: 'Descripción (opcional)',
                            ),

                            const SizedBox(height: 16),
                            // ===== Datos de la carga =====
                            Text(
                              'Datos de la carga (opcional)',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _textField(
                                    controller: _pesoCtrl,
                                    label: 'Peso (kg)',
                                    keyboard: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _textField(
                                    controller: _volumenCtrl,
                                    label: 'Volumen (m³)',
                                    keyboard: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _textField(
                                    controller: _tipoCargaCtrl,
                                    label: 'Tipo de carga',
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),
                            // ===== Ciudad origen/destino =====
                            Text(
                              'Ciudad origen y destino',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _dropdownField<String>(
                                    value: _ciudadOrigen,
                                    label: 'Ciudad Origen',
                                    items: _ciudadesEjemplo,
                                    onChanged: (v) =>
                                        setState(() => _ciudadOrigen = v),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _dropdownField<String>(
                                    value: _ciudadDestino,
                                    label: 'Ciudad Destino',
                                    items: _ciudadesEjemplo,
                                    onChanged: (v) =>
                                        setState(() => _ciudadDestino = v),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),
                            // ===== Paradas =====
                            Text(
                              'Paradas',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),

                            Column(
                              children: [
                                for (int i = 0; i < _paradas.length; i++)
                                  _buildParadaCard(context, i),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: OutlinedButton.icon(
                                onPressed: _agregarParada,
                                icon: const Icon(Icons.add),
                                label: const Text('Agregar parada'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {
                          // luego aquí llamas al backend
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kNavy,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Crear ruta'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Helpers internos ----------
  Widget _textField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _dropdownField<T>({
    required T? value,
    required String label,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items
          .map(
            (e) => DropdownMenuItem<T>(
              value: e,
              child: Text(e.toString()),
            ),
          )
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildParadaCard(BuildContext context, int index) {
    final parada = _paradas[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: kBordeSuave),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Parada #${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _paradas.removeAt(index);
                    });
                  },
                  tooltip: 'Eliminar parada',
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: _dropdownField<String>(
                    value: parada.ciudadOrigen,
                    label: 'Ciudad Origen',
                    items: _ciudadesEjemplo,
                    onChanged: (v) =>
                        setState(() => parada.ciudadOrigen = v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _dropdownField<String>(
                    value: parada.ciudadDestino,
                    label: 'Ciudad Destino',
                    items: _ciudadesEjemplo,
                    onChanged: (v) =>
                        setState(() => parada.ciudadDestino = v),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ParadaData {
  String? ciudadOrigen;
  String? ciudadDestino;
}

// =============== Página: Rutas pendientes ==================
class RutasPendientesPage extends StatelessWidget {
  const RutasPendientesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final rutas = [
      _RutaPendiente(
        codigo: 'TRX-1763605304422',
        nombre: 'dgsfh',
        estado: 'planificada',
        conductor: 'Andres F Santos',
        paradas: 6,
      ),
    ];

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
                  const Text(
                    'Hola, Edwin Gonzalez',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: kTexto,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Rutas pendientes',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: kTexto,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: null,
                          decoration: const InputDecoration(
                            labelText: 'Filtrar por estado',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'planificada',
                              child: Text('planificada'),
                            ),
                            DropdownMenuItem(
                              value: 'en curso',
                              child: Text('en curso'),
                            ),
                            DropdownMenuItem(
                              value: 'finalizada',
                              child: Text('finalizada'),
                            ),
                          ],
                          onChanged: (v) {
                            // luego aquí filtras por estado
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          // luego aquí recargas lista desde backend
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Actualizar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: kBordeSuave),
                    ),
                    child: Column(
                      children: [
                        for (final r in rutas) _buildRutaPendienteRow(r),
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

  Widget _buildRutaPendienteRow(_RutaPendiente r) {
    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  r.codigo,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(flex: 3, child: Text(r.nombre)),
              Expanded(
                flex: 2,
                child: Text(
                  r.estado,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(flex: 3, child: Text(r.conductor)),
              Expanded(
                flex: 1,
                child: Text(
                  r.paradas.toString(),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {
                  // aquí luego abres el mapa de la ruta
                },
                icon: const Icon(Icons.map),
                label: const Text('Ver mapa'),
              ),
            ],
          ),
        ),
        const Divider(height: 0, color: kBordeSuave),
      ],
    );
  }
}

class _RutaPendiente {
  final String codigo;
  final String nombre;
  final String estado;
  final String conductor;
  final int paradas;

  _RutaPendiente({
    required this.codigo,
    required this.nombre,
    required this.estado,
    required this.conductor,
    required this.paradas,
  });
}
