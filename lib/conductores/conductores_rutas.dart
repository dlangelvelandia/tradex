import 'package:flutter/material.dart';
import 'conductores_pages.dart';
import 'conductores_rutas.dart';

Map<String, WidgetBuilder> conductorRoutes = {
  ConductoresRoutes.rutas: (context) => const RutasAsignadasPage(),
  ConductoresRoutes.vehiculos: (context) => const VehiculosVinculadosPage(),
};

class ConductoresRoutes {
  static const shell     = '/conductor';
  static const rutas     = '/conductor/rutas';
  static const vehiculos = '/conductor/vehiculos';
  

  static Route<dynamic>? build(RouteSettings settings) {
    switch (settings.name) {
      case rutas:
      case shell:
        return MaterialPageRoute(
          builder: (_) => const RutasAsignadasPage(),
          settings: settings,
        );
      case vehiculos:
        return MaterialPageRoute(
          builder: (_) => const VehiculosVinculadosPage(),
          settings: settings,
        );
      default:
        return null;
    }
  }
}
