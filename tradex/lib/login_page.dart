import 'package:flutter/material.dart';
import 'package:tradex_web/conductores/conductores_rutas.dart';
import 'package:tradex_web/clientes/clientes_rutas.dart';
import 'package:tradex_web/administrador/admin_rutas.dart';
import 'services/api.dart';
import 'session.dart';
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

  Future<void> _iniciarSesion() async {
    final valido = _formKey.currentState?.validate() ?? false;
    if (!valido) return;

    setState(() => _cargando = true);
    try {
      final resp = await Api.login(
        email: _usuarioCtrl.text.trim().toLowerCase(),
        password: _claveCtrl.text,
      );
      Session.userId = resp['id'] as int?;
      Session.name   = resp['nombre'] as String?;
      Session.role   = resp['rol'] as String?;

      if (!mounted) return;

      // ---- Redirección según rol ----
      if (Session.role == 'Admin') {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AdminRoutes.dashboard,      // '/admin/dashboard'
          (_) => false,
        );
      } else if (Session.role == 'Conductor') {
        Navigator.pushNamedAndRemoveUntil(
          context,
          ConductoresRoutes.rutas,
          (_) => false,
        );
      } else if (Session.role == 'Cliente') {
        Navigator.pushNamedAndRemoveUntil(
          context,
          ClientesRoutes.creacion,
          (_) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rol no soportado')),
        );
      }
    } on ApiError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No se pudo iniciar sesión')));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _abrirOlvidoContrasena() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
    );
  }

  void _abrirCrearCuenta() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterAccountPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const kNavy = Color(0xFF0D2234);
    const kTextMuted = Color(0xFF6B7280);
    const kPanel = Color(0xFFF5F6FB);

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
                  // ---------- Panel izquierdo ----------
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

                  // ---------- Panel derecho (form) ----------
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
                                labelText: 'Correo',
                                hintText: 'tucorreo@dominio.com',
                              ),
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty) ? 'Ingresa tu correo' : null,
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
