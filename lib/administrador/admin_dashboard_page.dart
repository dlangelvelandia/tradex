import 'package:flutter/material.dart';
import 'sidebar_admin.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: const [
          SizedBox(
            width: 250, // ← sidebar ocupa solo 250px
            child: SidebarAdmin(selected: "/admin/dashboard"),
          ),
          Expanded(
            child: Center(
              child: Text(
                "Bienvenido Administrador",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
