import 'package:flutter/material.dart';
import 'sidebar_admin.dart';

class AdminUsuariosPage extends StatelessWidget {
  const AdminUsuariosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final usuarios = [
      {'nombre': 'Carlos Gómez', 'email': 'carlos@test.com', 'rol': 'Cliente'},
      {'nombre': 'Ana Pérez', 'email': 'ana@test.com', 'rol': 'Conductor'},
      {'nombre': 'Luis Ramírez', 'email': 'luis@test.com', 'rol': 'Cliente'},
      {'nombre': 'Admin Demo', 'email': 'admin@tradex.com', 'rol': 'Admin'},
    ];

    return Scaffold(
      backgroundColor: kBg,
      body: Row(
        children: [
          const SidebarAdmin(selected: '/admin/usuarios'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gestión de usuarios',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Listado simple de usuarios (demo)',
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
                        itemCount: usuarios.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, color: kBordeSuave),
                        itemBuilder: (context, index) {
                          final u = usuarios[index];
                          return ListTile(
                            title: Text('${u['nombre']}'),
                            subtitle: Text('${u['email']}'),
                            trailing: Text(
                              '${u['rol']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: kNavy,
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

