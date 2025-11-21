import 'package:flutter/material.dart';
import 'conductores_rutas.dart';

// --------- Paleta local mínima ---------
const kNavy = Color(0xFF0D2234);
const kNavy2 = Color(0xFF12314A);
const kVerde = Color(0xFF21BF73);
const kBg = Color(0xFFF3F5F9);
const kTexto = Color(0xFF111827);
const kBordeSuave = Color(0xFFE5E7EB);
const kLilaSuave = Color(0xFFF3E8FF);

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

          // navegación
          _item(
            context,
            icon: Icons.turn_slight_right_rounded,
            label: 'Rutas asignadas',
            route: ConductoresRoutes.rutas,
            selected: selected,
          ),
          const SizedBox(height: 8),
          _item(
            context,
            icon: Icons.directions_car_filled_rounded,
            label: 'Vehículos vinculados',
            route: ConductoresRoutes.vehiculos,
            selected: selected,
          ),

          const Spacer(),

          // separador y botón de salida
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
    final bool isSelected = selected == route;
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

// ============ Pantalla: Rutas asignadas ============
class RutasAsignadasPage extends StatelessWidget {
  const RutasAsignadasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final filas = [
      _RutaData(
        codigo: 'TRX-1763605304422',
        nombre: 'dgsfh',
        estado: 'Planificada',
        cliente: 'Edwin Gonzalez',
      ),
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
                  const Text(
                    'Hola, Andres F Santos',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: kTexto,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Rutas asignadas',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: kTexto,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Mapa (placeholder)
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: kBordeSuave),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: SizedBox(
                      height: 360,
                      width: double.infinity,
                      child: Image.network(
                        'https://tile.openstreetmap.org/12/1205/1538.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return const Center(
                            child: Text('Aquí irá el mapa de la ruta'),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tabla de rutas
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: kBordeSuave),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
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
            _Cell('Nombre', flex: 3, isHeader: true),
            _Cell('Estado', flex: 2, isHeader: true),
            _Cell('Cliente', flex: 3, isHeader: true),
            _Cell('Acciones', flex: 4, isHeader: true),
          ],
        ),
      );

  Widget _rowRuta(_RutaData d) {
    const estados = ['Planificada', 'En curso', 'Finalizada'];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Row(
            children: [
              _Cell(d.codigo, flex: 2),
              _Cell(d.nombre, flex: 3),
              _Cell(d.estado, flex: 2, emphasize: true, color: Colors.orange),
              _Cell(d.cliente, flex: 3),
              Expanded(
                flex: 4,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Nuevo estado'),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 160,
                        child: _EstadoDropdown(
                          initialValue: d.estado,
                          opciones: estados,
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Guardar'),
                      ),
                    ],
                  ),
                ),
              ),
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
      _Vehiculo(
        placa: 'FRA132',
        marcaModelo: 'Chevrolet 2026',
        anio: '2026',
        capacidadKg: '100.00',
        volumenM3: '100.000',
        estado: 'activo',
      ),
    ];

    return Scaffold(
      backgroundColor: kBg,
      body: Row(
        children: [
          const SidebarConductor(selected: ConductoresRoutes.vehiculos),
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hola, Andres F Santos',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: kTexto,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Vehículos vinculados',
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Column(
                            children: [
                              _headerVehiculos(),
                              const Divider(height: 24, color: kBordeSuave),
                              for (final v in items) _rowVehiculo(v),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Actualizar lista'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),

                // ==== BOTÓN FLOTANTE Registrar vehículo ====
                Positioned(
                  right: 32,
                  bottom: 32,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierDismissible:
                            false, // para obligar a usar X o Guardar
                        builder: (ctx) => const RegistrarVehiculoDialog(),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Registrar vehículo'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: const Color(0xFFEDE9FE),
                      foregroundColor: const Color(0xFF4C1D95),
                      elevation: 4,
                    ),
                  ),
                ),
              ],
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
            _Cell('Placa', flex: 2, isHeader: true),
            _Cell('Marca / Modelo', flex: 4, isHeader: true),
            _Cell('Año', flex: 2, isHeader: true),
            _Cell('Cap. (kg)', flex: 2, isHeader: true),
            _Cell('Vol. (m³)', flex: 2, isHeader: true),
            _Cell('Estado', flex: 2, isHeader: true),
          ],
        ),
      );

  Widget _rowVehiculo(_Vehiculo v) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Row(
            children: [
              _Cell(v.placa, flex: 2, emphasize: true),
              _Cell(v.marcaModelo, flex: 4),
              _Cell(v.anio, flex: 2),
              _Cell(v.capacidadKg, flex: 2),
              _Cell(v.volumenM3, flex: 2),
              _Cell(v.estado, flex: 2, emphasize: true, color: kVerde),
            ],
          ),
        ),
        const Divider(height: 0, color: kBordeSuave),
      ],
    );
  }
}

// ----------------- Widgets / modelos auxiliares -----------------
class _Cell extends StatelessWidget {
  final String text;
  final int flex;
  final bool isHeader;
  final bool emphasize;
  final Color? color;

  const _Cell(
    this.text, {
    this.flex = 1,
    this.isHeader = false,
    this.emphasize = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle style = isHeader
        ? Theme.of(context).textTheme.titleMedium!
        : Theme.of(context).textTheme.bodyMedium!;

    if (emphasize) {
      style = style.copyWith(fontWeight: FontWeight.w700);
    }
    if (color != null) {
      style = style.copyWith(color: color);
    }

    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: style,
      ),
    );
  }
}

class _EstadoDropdown extends StatefulWidget {
  final String initialValue;
  final List<String> opciones;

  const _EstadoDropdown({
    required this.initialValue,
    required this.opciones,
    super.key,
  });

  @override
  State<_EstadoDropdown> createState() => _EstadoDropdownState();
}

class _EstadoDropdownState extends State<_EstadoDropdown> {
  late String _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: _value,
      items: widget.opciones
          .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
          .toList(),
      onChanged: (val) => setState(() => _value = val ?? _value),
      decoration: const InputDecoration(
        isDense: true,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}

class _RutaData {
  final String codigo;
  final String nombre;
  final String estado;
  final String cliente;
  _RutaData({
    required this.codigo,
    required this.nombre,
    required this.estado,
    required this.cliente,
  });
}

class _Vehiculo {
  final String placa;
  final String marcaModelo;
  final String anio;
  final String capacidadKg;
  final String volumenM3;
  final String estado;
  _Vehiculo({
    required this.placa,
    required this.marcaModelo,
    required this.anio,
    required this.capacidadKg,
    required this.volumenM3,
    required this.estado,
  });
}

// ========== DIÁLOGO: Registrar vehículo ==========
class RegistrarVehiculoDialog extends StatefulWidget {
  const RegistrarVehiculoDialog({super.key});

  @override
  State<RegistrarVehiculoDialog> createState() =>
      _RegistrarVehiculoDialogState();
}

class _RegistrarVehiculoDialogState extends State<RegistrarVehiculoDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _placaCtrl = TextEditingController();
  final TextEditingController _marcaCtrl = TextEditingController();
  final TextEditingController _modeloCtrl = TextEditingController();
  final TextEditingController _anioCtrl = TextEditingController();
  final TextEditingController _capacidadCtrl = TextEditingController();
  final TextEditingController _volumenCtrl = TextEditingController();
  String _estado = 'Activo';

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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 80, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
        decoration: BoxDecoration(
          color: kLilaSuave,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --------- Título + botón cerrar -----------
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Registrar vehículo',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // --------- Campos en 2 columnas ----------
              LayoutBuilder(
                builder: (context, constraints) {
                  final bool isNarrow = constraints.maxWidth < 500;
                  final children = <Widget>[
                    _textField(
                      controller: _placaCtrl,
                      label: 'Placa *',
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Requerido' : null,
                    ),
                    _textField(controller: _marcaCtrl, label: 'Marca'),
                    _textField(controller: _modeloCtrl, label: 'Modelo'),
                    _textField(controller: _anioCtrl, label: 'Año'),
                    _textField(
                      controller: _capacidadCtrl,
                      label: 'Capacidad (kg)',
                      keyboard: TextInputType.number,
                    ),
                    _textField(
                      controller: _volumenCtrl,
                      label: 'Volumen (m³)',
                      keyboard: TextInputType.number,
                    ),
                  ];

                  if (isNarrow) {
                    // una sola columna en pantallas muy pequeñas
                    return Column(
                      children: [
                        for (var w in children) ...[
                          w,
                          const SizedBox(height: 8),
                        ],
                      ],
                    );
                  }

                  // dos columnas (como en el diseño)
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: children[0]),
                          const SizedBox(width: 8),
                          Expanded(child: children[1]),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: children[2]),
                          const SizedBox(width: 8),
                          Expanded(child: children[3]),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: children[4]),
                          const SizedBox(width: 8),
                          Expanded(child: children[5]),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),

              // Estado
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Estado',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                value: _estado,
                items: const [
                  DropdownMenuItem(value: 'Activo', child: Text('Activo')),
                  DropdownMenuItem(value: 'Inactivo', child: Text('Inactivo')),
                ],
                onChanged: (val) => setState(() => _estado = val ?? 'Activo'),
                decoration: const InputDecoration(
                  isDense: true,
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 18),

              // Botón guardar
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;

                    // aquí iría la llamada al backend o lógica para guardar
                    // por ahora solo cerramos el diálogo
                    Navigator.of(context).pop();

                    // si quieres, podrías mostrar un snackbar:
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   const SnackBar(content: Text('Vehículo registrado')),
                    // );
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kNavy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        filled: true,
        fillColor: Colors.white.withOpacity(0.7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: kNavy2),
        ),
      ),
    );
  }
}
