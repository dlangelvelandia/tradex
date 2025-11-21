import 'package:flutter/material.dart';
import 'sidebar_admin.dart';

class AdminVehiculosPage extends StatelessWidget {
  const AdminVehiculosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vehiculos = [
      {'placa': 'ABC123', 'modelo': 'Toyota Hilux', 'estado': 'Activo'},
      {'placa': 'XYZ987', 'modelo': 'Chevrolet NKR', 'estado': 'Mantenimiento'},
      {'placa': 'JKL456', 'modelo': 'Ford Ranger', 'estado': 'Activo'},
    ];

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
                  Text(
                    'Gestión de vehículos',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Listado simple de vehículos (demo)',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: kBordeSuave),
                      ),
                      child: ListView.separated(
                        itemCount: vehiculos.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, color: kBordeSuave),
                        itemBuilder: (context, index) {
                          final v = vehiculos[index];
                          return ListTile(
                            title: Text('${v['placa']} • ${v['modelo']}'),
                            trailing: Text(
                              '${v['estado']}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: v['estado'] == 'Activo'
                                    ? kVerde
                                    : Colors.orange,
                              ),
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

