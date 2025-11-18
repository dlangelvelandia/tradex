import 'package:flutter/material.dart';
import 'package:tradex_web/administrador/admin_vehiculos_page.dart';
import 'admin_pages.dart';
import 'admin_usuarios_page.dart';

class AdminRoutes {
  static const dashboard = '/admin/dashboard';
  static const usuarios = '/admin/usuarios';
  static const vehiculos = '/admin/vehiculos';
  static const rutas = '/admin/rutas';

  static Route<dynamic>? build(RouteSettings settings) {
    switch (settings.name) {
      case dashboard:
        return MaterialPageRoute(
          builder: (_) => const AdminDashboardPage(),
          settings: settings,
        );

      case usuarios:
        return MaterialPageRoute(
          builder: (_) => AdminUsuariosPage(),
          settings: settings,
        );

      case vehiculos:
        return MaterialPageRoute(
          builder: (_) => const AdminVehiculosPage(),
          settings: settings,
        );

      case rutas:
        return MaterialPageRoute(
          builder: (_) => const AdminRutasPage(),
          settings: settings,
        );
    }
    return null;
  }
}
