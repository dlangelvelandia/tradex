import 'package:flutter/material.dart';

/// Paleta para el módulo admin (misma que cliente)
const kNavy = Color(0xFF0D2234);
const kBg = Color(0xFFF5F6FB);
const kTexto = Color(0xFF0F172A);
const kBordeSuave = Color(0xFFE5E7EB);
const kVerde = Color(0xFF21BF73);

class SidebarAdmin extends StatelessWidget {
  final String selected; // ruta actual

  const SidebarAdmin({super.key, required this.selected});

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
            if (!sel) {
              Navigator.pushReplacementNamed(context, route);
            }
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
                'ADMIN TRADEX',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Opciones
          item(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            route: '/admin/dashboard',
          ),
          item(
            icon: Icons.people_alt_outlined,
            label: 'Usuarios',
            route: '/admin/usuarios',
          ),
          item(
            icon: Icons.local_shipping_outlined,
            label: 'Vehículos',
            route: '/admin/vehiculos',
          ),
          item(
            icon: Icons.alt_route,
            label: 'Rutas',
            route: '/admin/rutas',
          ),

          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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

