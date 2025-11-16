import 'package:flutter/material.dart';
import 'clientes_pages.dart';

class ClientesRoutes {
  static const creacion   = '/cliente/creacion';
  static const pendientes = '/cliente/pendientes';

  static Route<dynamic>? build(RouteSettings settings) {
    switch (settings.name) {
      case creacion:
        return MaterialPageRoute(
          builder: (_) => const CreacionRutaPage(),
          settings: settings,
        );
      case pendientes:
        return MaterialPageRoute(
          builder: (_) => const RutasPendientesPage(),
          settings: settings,
        );
    }
    return null;
  }
}
