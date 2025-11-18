import 'package:flutter/material.dart';
import 'admin_pages.dart' hide SidebarAdmin;
import 'sidebar_admin.dart';

class AdminVehiculosPage extends StatelessWidget {
  const AdminVehiculosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vehiculos = [
      {"placa": "ABC123", "modelo": "Toyota Hilux", "estado": "Activo"},
      {"placa": "XYZ987", "modelo": "Chevrolet NKR", "estado": "Mantenimiento"},
      {"placa": "JKL456", "modelo": "Ford Ranger", "estado": "Activo"},
    ];

    return Scaffold(
      backgroundColor: kBg,
      body: Row(
        children: [
          SidebarAdmin(selected: '/admin/vehiculos'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Gestión de Vehículos",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: kTexto,
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: 300,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Buscar vehículo...",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: kBordeSuave),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListView.separated(
                        itemCount: vehiculos.length,
                        separatorBuilder: (_, __) =>
                            Divider(color: kBordeSuave),
                        itemBuilder: (_, i) {
                          return ListTile(
                            leading: const Icon(Icons.local_shipping),
                            title: Text(vehiculos[i]["modelo"]!),
                            subtitle: Text(vehiculos[i]["placa"]!),
                            trailing: Text(
                              vehiculos[i]["estado"]!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
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
