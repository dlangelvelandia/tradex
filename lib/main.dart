import 'package:flutter/material.dart';
import 'package:tradex_web/login_page.dart';
import 'package:tradex_web/conductores/conductores_rutas.dart';
import 'package:tradex_web/clientes/clientes_rutas.dart';   // <- IMPORTANTE


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TradexApp());
}

class TradexApp extends StatelessWidget {
  const TradexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TRADEX Logística',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      initialRoute: '/login',
      onGenerateRoute: (settings) {
  final r1 = ConductoresRoutes.build(settings);
  if (r1 != null) return r1;

  final r2 = ClientesRoutes.build(settings);   // <- AQUÍ
  if (r2 != null) return r2;

  switch (settings.name) {
    case '/':
    case '/login':
      return MaterialPageRoute(builder: (_) => const LoginPage(), settings: settings);
  }
  return MaterialPageRoute(builder: (_) => const LoginPage(), settings: settings);
},
    );
  }
}

/// Tema visual (Material 3) con estilos suaves.
ThemeData buildTheme() {
  const kNavy = Color(0xFF0D2234);
  const kBg   = Color(0xFFF5F6FB);
  const kText = Color(0xFF0F172A);

  final base = ThemeData.light(useMaterial3: true);

  return base.copyWith(
    scaffoldBackgroundColor: kBg,
    colorScheme: base.colorScheme.copyWith(
      primary: kNavy,
      onPrimary: Colors.white,
      surface: Colors.white,
      onSurface: kText,
    ),
    textTheme: base.textTheme.copyWith(
      headlineLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: kText),
      headlineMedium: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: kText),
      titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kText),
      bodyMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: kText),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      foregroundColor: kText,
    ),
cardTheme: const CardThemeData(
  color: Colors.white,
  elevation: 0,
  // OJO: en SDKs antiguos NO existe surfaceTintColor.
  // OJO: shadowColor puede no existir en versiones muy viejas; si te falla,
  // coméntala también.
  // shadowColor: Colors.transparent,
  shape: RoundedRectangleBorder(
    // Usamos 'all(Radius.circular(...))' para que sea const-compatible.
    borderRadius: BorderRadius.all(Radius.circular(12)),
    side: BorderSide(color: Color(0xFFE5E7EB)),
  ),
),


    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kNavy,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFFE5E7EB)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      isDense: true,
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFFE5E7EB), thickness: 1),
  );
}


