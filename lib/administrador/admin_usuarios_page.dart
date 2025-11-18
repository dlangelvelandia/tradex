import 'package:flutter/material.dart';
import 'admin_pages.dart';

class AdminUsuariosPage extends StatelessWidget {
  const AdminUsuariosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final usuarios = [
      {"nombre": "Carlos Gómez", "email": "carlos@test.com", "rol": "Cliente"},
      {"nombre": "Ana Pérez", "email": "ana@test.com", "rol": "Conductor"},
      {"nombre": "Luis Ramírez", "email": "luis@test.com", "rol": "Cliente"},
    ];

    return Scaffold(
      backgroundColor: kBg,
      body: Row(
        children: [
          SidebarAdmin(selected: '/admin/usuarios'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Gestión de Usuarios",
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
                        hintText: "Buscar usuario...",
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
                        itemCount: usuarios.length,
                        separatorBuilder: (_, __) =>
                            Divider(color: kBordeSuave),
                        itemBuilder: (_, i) {
                          return ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(usuarios[i]["nombre"]!),
                            subtitle: Text(usuarios[i]["email"]!),
                            trailing: Text(
                              usuarios[i]["rol"]!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: kAzul,
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
