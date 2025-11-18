import 'package:flutter/material.dart';

class SidebarAdmin extends StatelessWidget {
  final String selected;
  const SidebarAdmin({super.key, required this.selected});

  @override
  Widget build(BuildContext context) {
    const kNavy = Color(0xFF0D2234);

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
