// Archivo: lib/auth_forms.dart
// Contiene los formularios de:
//  - Recuperar contraseña (ForgotPasswordPage) [simulado]
//  - Crear cuenta (RegisterAccountPage)       [INTEGRADO A API]

import 'package:flutter/material.dart';
import 'package:tradex_web/services/api.dart';

// ------------------ FORGOT PASSWORD (simulado) ------------------
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _enviando = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviarEnlace() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    setState(() => _enviando = true);
    await Future.delayed(const Duration(milliseconds: 800)); // simulación
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Te enviamos un enlace a ${_emailCtrl.text.trim()} (simulado)')),
    );
    setState(() => _enviando = false);

    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) Navigator.pop(context); // volver al login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar contraseña')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Ingresa tu correo y te enviaremos un enlace para restablecer tu contraseña.',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo',
                        hintText: 'tucorreo@dominio.com',
                      ),
                      validator: (v) {
                        final t = (v ?? '').trim();
                        if (t.isEmpty) return 'Ingresa tu correo';
                        if (!t.contains('@') || !t.contains('.')) return 'Correo no válido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _enviando ? null : _enviarEnlace,
                      child: _enviando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Enviar enlace'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------ REGISTER ACCOUNT (integrado a API) ------------------
class RegisterAccountPage extends StatefulWidget {
  const RegisterAccountPage({super.key});

  @override
  State<RegisterAccountPage> createState() => _RegisterAccountPageState();
}

class _RegisterAccountPageState extends State<RegisterAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _claveCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _guardando = false;
  bool _verClave = false;
  bool _verConfirm = false;

  // Selector de rol
  final List<String> _roles = const ['Cliente', 'Conductor']; // agrega 'Admin' si quieres
  String _rolSeleccionado = 'Cliente';

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _correoCtrl.dispose();
    _telefonoCtrl.dispose();
    _claveCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    setState(() => _guardando = true);
    try {
      final resp = await Api.crearUsuario(
        nombre: _nombreCtrl.text.trim(),
        email: _correoCtrl.text.trim().toLowerCase(),
        telefono: _telefonoCtrl.text.trim().isEmpty ? null : _telefonoCtrl.text.trim(),
        password: _claveCtrl.text,      // el backend la hashea
        rol: _rolSeleccionado,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuario creado')),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) Navigator.pop(context); // volver al login
    } on ApiError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo crear el usuario')),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Nombre + Rol
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _nombreCtrl,
                            decoration: const InputDecoration(labelText: 'Nombre completo'),
                            validator: (v) => (v == null || v.trim().length < 3)
                                ? 'Ingresa tu nombre'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: _rolSeleccionado,
                            decoration: const InputDecoration(
                              labelText: 'Rol',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: _roles
                                .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                                .toList(),
                            onChanged: (v) => setState(() => _rolSeleccionado = v ?? 'Cliente'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Correo + Teléfono
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _correoCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(labelText: 'Correo'),
                            validator: (v) {
                              final t = (v ?? '').trim();
                              if (t.isEmpty) return 'Ingresa tu correo';
                              if (!t.contains('@') || !t.contains('.')) return 'Correo no válido';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _telefonoCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(labelText: 'Teléfono'),
                            validator: (v) =>
                                (v == null || v.trim().length < 7) ? 'Teléfono no válido' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Contraseña + Confirmación
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _claveCtrl,
                            obscureText: !_verClave,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              suffixIcon: IconButton(
                                onPressed: () => setState(() => _verClave = !_verClave),
                                icon: Icon(_verClave ? Icons.visibility_off : Icons.visibility),
                              ),
                            ),
                            validator: (v) =>
                                (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _confirmCtrl,
                            obscureText: !_verConfirm,
                            decoration: InputDecoration(
                              labelText: 'Confirmar contraseña',
                              suffixIcon: IconButton(
                                onPressed: () => setState(() => _verConfirm = !_verConfirm),
                                icon: Icon(_verConfirm ? Icons.visibility_off : Icons.visibility),
                              ),
                            ),
                            validator: (v) =>
                                (v != _claveCtrl.text) ? 'No coincide con la contraseña' : null,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _guardando ? null : _guardar,
                        child: _guardando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Guardar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

