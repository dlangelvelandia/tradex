import 'package:flutter/material.dart';
import 'package:tradex_web/conductores/conductores_rutas.dart';
import 'package:tradex_web/clientes/clientes_rutas.dart';
import 'package:tradex_web/administrador/admin_rutas.dart';

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
  bool _mostrarClave = false;

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
            context, ConductoresRoutes.rutas, (r) => false);
      } else if (perfil.rol == 'cliente') {
        Navigator.pushNamedAndRemoveUntil(
            context, ClientesRoutes.creacion, (r) => false);
      } else if (perfil.rol == 'admin') {
        Navigator.pushNamedAndRemoveUntil(
            context, '/admin/dashboard', (r) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rol no soportado')),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const kNavy = Color(0xFF0D2234);
    const kBg = Color(0xFFF5F6FB);
    const kTexto = Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: kBg,
      body: Row(
        children: [
          // Panel izquierdo con logo y fondo
          Expanded(
            flex: 2,
            child: Container(
              color: kNavy,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.local_shipping,
                        color: Colors.white, size: 64),
                    SizedBox(height: 16),
                    Text(
                      'TRADEX LOGISTIC',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Gestión de transporte inteligente',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Panel derecho con formulario
          Expanded(
            flex: 3,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  elevation: 2,
                  margin: const EdgeInsets.all(24),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Iniciar sesión',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: kTexto,
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _usuarioCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Correo electrónico',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Ingrese su correo'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _claveCtrl,
                            obscureText: !_mostrarClave,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_mostrarClave
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () {
                                  setState(
                                      () => _mostrarClave = !_mostrarClave);
                                },
                              ),
                            ),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Ingrese su contraseña'
                                : null,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kNavy,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _cargando ? null : _iniciarSesion,
                              child: _cargando
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Ingresar',
                                      style: TextStyle(fontSize: 16),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 8),
                          const Text(
                            'Demo roles válidos:',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Cliente → cliente@demo.com / 123456\n'
                            'Conductor → conductor@demo.com / 123456\n'
                            'Administrador → admin@tradex.com / admin123',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FakeAuth {
  static Future<_Perfil> login({
    required String usuario,
    required String clave,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (usuario.toLowerCase() == 'cliente@demo.com' && clave == '123456') {
      return const _Perfil(id: 'c1', nombre: 'Cliente Demo', rol: 'cliente');
    }
    if (usuario.toLowerCase() == 'conductor@demo.com' && clave == '123456') {
      return const _Perfil(id: 'd1', nombre: 'Conductor Demo', rol: 'conductor');
    }
    if (usuario.toLowerCase() == 'admin@tradex.com' && clave == 'admin123') {
      return const _Perfil(id: 'a1', nombre: 'Administrador', rol: 'admin');
    }

    throw Exception('Credenciales inválidas');
  }
}

class _Perfil {
  final String id;
  final String nombre;
  final String rol;

  const _Perfil({
    required this.id,
    required this.nombre,
    required this.rol,
  });
}
