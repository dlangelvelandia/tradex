import 'package:flutter/material.dart';
import 'sidebar_admin.dart';

class AdminRutasPage extends StatelessWidget {
  const AdminRutasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: const [
          SidebarAdmin(selected: "/admin/rutas"),
          Expanded(
            child: Center(
              child: Text(
                "Gestión de Rutas (pendiente)",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
