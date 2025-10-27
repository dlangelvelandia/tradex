import 'package:flutter/material.dart';
import 'package:tradex_web/conductores/conductores_rutas.dart';
import 'package:tradex_web/clientes/clientes_rutas.dart';   // <- IMPORTANTE

// Formularios simulados
import 'auth_forms.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioCtrl = TextEditingController();
  final _claveCtrl = TextEditingController();
  bool _cargando = false;
  bool _verClave = false;

  @override
  void dispose() {
    _usuarioCtrl.dispose();
    _claveCtrl.dispose();
    super.dispose();
  }

  // Inicia sesión "simulada" y redirige según rol
  Future<void> _iniciarSesion() async {
    final valido = _formKey.currentState?.validate() ?? false;
    if (!valido) return;

    setState(() => _cargando = true);
    try {
      final perfil = await FakeAuth.login(
        usuario: _usuarioCtrl.text.trim(),
        clave: _claveCtrl.text,
      );
      if (!mounted) return;

      if (perfil.rol == 'conductor') {
        Navigator.pushNamedAndRemoveUntil(
          context,
          ConductoresRoutes.rutas,
          (route) => false,
        );
      } else if (perfil.rol == 'cliente') {
        Navigator.pushNamedAndRemoveUntil(
          context,
          ClientesRoutes.creacion, // <= ESTE
          (route) => false,);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Rol no soportado en esta demo')));
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

 

  // Abre formulario de "¿Olvidaste tu contraseña?"
  void _abrirOlvidoContrasena() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ForgotPasswordPage()), // sin const
    );
  }

  // Abre formulario de "Crear cuenta"
  void _abrirCrearCuenta() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RegisterAccountPage()), // sin const
    );
  }

  @override
  Widget build(BuildContext context) {
    // Paleta mínima local para el mockup
    const kNavy = Color(0xFF0D2234);
    const kTextMuted = Color(0xFF6B7280);
    const kPanel = Color(0xFFF5F6FB); // fondo claro del panel derecho

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 18, offset: Offset(0, 6))
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Row(
                children: [
                  // ---------- Panel izquierdo (branding + líneas diagonales) ----------
                  Expanded(
                    child: Container(
                      height: 520,
                      color: kNavy,
                      child: Stack(
                        children: [
                          const Positioned.fill(child: _StripedBackground()),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.local_shipping, color: Colors.white, size: 44),
                                SizedBox(height: 10),
                                Text(
                                  'TRADEX LOGISTIC',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Bullets informativos al pie
                          Positioned(
                            left: 24,
                            right: 24,
                            bottom: 20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                _FeatureRow(
                                  icon: Icons.link,
                                  text: 'Gestión de rutas y despachos en tiempo real',
                                ),
                                SizedBox(height: 8),
                                _FeatureRow(
                                  icon: Icons.inventory_2,
                                  text: 'Control de inventario y trazabilidad',
                                ),
                                SizedBox(height: 8),
                                _FeatureRow(
                                  icon: Icons.verified_user,
                                  text: 'Seguridad y cumplimiento para tu operación',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ---------- Panel derecho (formulario de login) ----------
                  Expanded(
                    child: Container(
                      color: kPanel,
                      height: 520,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 26),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Iniciar sesión',
                              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 18),

                            TextFormField(
                              controller: _usuarioCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Usuario',
                                hintText: 'correo o usuario',
                              ),
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty) ? 'Ingresa tu usuario' : null,
                            ),
                            const SizedBox(height: 12),

                            TextFormField(
                              controller: _claveCtrl,
                              obscureText: !_verClave,
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                hintText: '•••••••',
                                suffixIcon: IconButton(
                                  onPressed: () => setState(() => _verClave = !_verClave),
                                  icon: Icon(_verClave ? Icons.visibility_off : Icons.visibility),
                                ),
                              ),
                              validator: (v) =>
                                  (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
                            ),
                            const SizedBox(height: 18),

                            // Botones principales
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _cargando ? null : _iniciarSesion,
                                    child: _cargando
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : const Text('Iniciar sesión'),
                                  ),
                                ),
                                
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Enlaces → abren formularios simulados
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: _abrirOlvidoContrasena,
                                  child: const Text('¿Olvidaste tu contraseña?'),
                                  style: TextButton.styleFrom(foregroundColor: kTextMuted),
                                ),
                                TextButton(
                                  onPressed: _abrirCrearCuenta,
                                  child: const Text('Crear cuenta'),
                                  style: TextButton.styleFrom(foregroundColor: kTextMuted),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Al iniciar sesión aceptas nuestros Términos y Política de Privacidad • v1.0.0',
                              style: TextStyle(color: kTextMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fondo con líneas diagonales sutiles (estilo mockup)
class _StripedBackground extends StatelessWidget {
  const _StripedBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _StripePainter());
  }
}

class _StripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 1;

    const gap = 22.0;
    for (double x = -size.height; x < size.width + size.height; x += gap) {
      final p1 = Offset(x, size.height);
      final p2 = Offset(x + size.height, 0);
      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ),
      ],
    );
  }
}

/// -------------------- Mini backend simulado --------------------
class FakeAuth {
  static Future<_Perfil> login({
    required String usuario,
    required String clave,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // DEMO: credenciales por rol
    // Cliente:   cliente@demo.com / 123456
    // Conductor: conductor@demo.com / 123456
    if (usuario.toLowerCase() == 'cliente@demo.com' && clave == '123456') {
      return const _Perfil(id: 'c1', nombre: 'Cliente Demo', rol: 'cliente');
    }
    if (usuario.toLowerCase() == 'conductor@demo.com' && clave == '123456') {
      return const _Perfil(id: 'd1', nombre: 'Conductor Demo', rol: 'conductor');
    }

    // Fallback de demo: si no coincide, lo mandamos como conductor
    return const _Perfil(id: 'd1', nombre: 'Conductor Demo', rol: 'conductor');
  }
}

class _Perfil {
  final String id;
  final String nombre;
  final String rol; // 'conductor' | 'cliente'
  const _Perfil({required this.id, required this.nombre, required this.rol});
}

