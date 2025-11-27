import 'package:flutter/material.dart';
import 'sidebar_admin.dart';
import 'package:tradex_web/services/api.dart';

class AdminUsuariosPage extends StatefulWidget {
  const AdminUsuariosPage({super.key});

  @override
  State<AdminUsuariosPage> createState() => _AdminUsuariosPageState();
}

class _AdminUsuariosPageState extends State<AdminUsuariosPage> {
  bool _cargando = false;
  List<Map<String, dynamic>> _usuarios = [];
  String? _filtroRol;

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    setState(() => _cargando = true);
    try {
      if (_filtroRol != null) {
        _usuarios = await Api.listarUsuariosPorRol(_filtroRol!, perPage: 200);
      } else {
        // Cargar todos los usuarios
        _usuarios = [];
        for (final rol in ['Admin', 'Cliente', 'Conductor']) {
          final lista = await Api.listarUsuariosPorRol(rol, perPage: 200);
          _usuarios.addAll(lista);
        }
      }
      if (mounted) setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar usuarios: $e')),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _eliminarUsuario(int id, String nombre) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Eliminar a $nombre?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    try {
      // Llamar endpoint DELETE (necesitas agregarlo en api.dart)
      final uri = Uri.parse('http://localhost:5000/api/usuarios/$id');
      final res = await http.delete(uri);
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception('Error ${res.statusCode}');
      }
      _cargarUsuarios();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario eliminado')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e')),
      );
    }
  }

  Future<void> _mostrarFormulario({Map<String, dynamic>? usuario}) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (_) => _FormularioUsuario(usuario: usuario),
    );
    if (resultado == true) {
      _cargarUsuarios();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Row(
        children: [
          const SidebarAdmin(selected: '/admin/usuarios'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Gestión de usuarios',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _mostrarFormulario(),
                        icon: const Icon(Icons.add),
                        label: const Text('Nuevo Usuario'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Filtrar por rol:',
                          style: TextStyle(color: Colors.grey)),
                      const SizedBox(width: 12),
                      DropdownButton<String>(
                        value: _filtroRol,
                        hint: const Text('Todos'),
                        items: const [
                          DropdownMenuItem(
                              value: 'Admin', child: Text('Admin')),
                          DropdownMenuItem(
                              value: 'Cliente', child: Text('Cliente')),
                          DropdownMenuItem(
                              value: 'Conductor', child: Text('Conductor')),
                        ],
                        onChanged: (v) {
                          setState(() => _filtroRol = v);
                          _cargarUsuarios();
                        },
                      ),
                      if (_filtroRol != null)
                        TextButton(
                          onPressed: () {
                            setState(() => _filtroRol = null);
                            _cargarUsuarios();
                          },
                          child: const Text('Limpiar filtro'),
                        ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _cargarUsuarios,
                        tooltip: 'Actualizar',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: kBordeSuave),
                      ),
                      child: _cargando
                          ? const Center(child: CircularProgressIndicator())
                          : _usuarios.isEmpty
                              ? const Center(child: Text('Sin usuarios'))
                              : ListView.separated(
                                  itemCount: _usuarios.length,
                                  separatorBuilder: (_, __) => const Divider(
                                      height: 1, color: kBordeSuave),
                                  itemBuilder: (context, index) {
                                    final u = _usuarios[index];
                                    return ListTile(
                                      title:
                                          Text('${u['nombre_completo'] ?? u['nombre']}'),
                                      subtitle: Text('${u['email']}'),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: kNavy.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              '${u['rol_nombre'] ?? u['rol']}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: kNavy,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                size: 20),
                                            onPressed: () =>
                                                _mostrarFormulario(usuario: u),
                                            tooltip: 'Editar',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                size: 20, color: Colors.red),
                                            onPressed: () => _eliminarUsuario(
                                                u['id'],
                                                u['nombre_completo'] ??
                                                    u['nombre']),
                                            tooltip: 'Eliminar',
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Formulario para crear/editar usuario
class _FormularioUsuario extends StatefulWidget {
  final Map<String, dynamic>? usuario;

  const _FormularioUsuario({this.usuario});

  @override
  State<_FormularioUsuario> createState() => _FormularioUsuarioState();
}

class _FormularioUsuarioState extends State<_FormularioUsuario> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _telefonoCtrl;
  late TextEditingController _passwordCtrl;
  String _rol = 'Cliente';
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final u = widget.usuario;
    _nombreCtrl = TextEditingController(text: u?['nombre_completo'] ?? '');
    _emailCtrl = TextEditingController(text: u?['email'] ?? '');
    _telefonoCtrl = TextEditingController(text: u?['telefono'] ?? '');
    _passwordCtrl = TextEditingController();
    _rol = u?['rol_nombre'] ?? u?['rol'] ?? 'Cliente';
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _telefonoCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);
    try {
      if (widget.usuario == null) {
        // Crear
        await Api.crearUsuario(
          nombre: _nombreCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          telefono: _telefonoCtrl.text.trim().isEmpty
              ? null
              : _telefonoCtrl.text.trim(),
          password: _passwordCtrl.text,
          rol: _rol,
        );
      } else {
        // Editar (necesitas agregar método en Api)
        final uri =
            Uri.parse('http://localhost:5000/api/usuarios/${widget.usuario!['id']}');
        final body = {
          'nombre_completo': _nombreCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          if (_telefonoCtrl.text.trim().isNotEmpty)
            'telefono': _telefonoCtrl.text.trim(),
          'rol': _rol,
          if (_passwordCtrl.text.isNotEmpty) 'password': _passwordCtrl.text,
        };
        final res = await http.put(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body));
        if (res.statusCode < 200 || res.statusCode >= 300) {
          throw Exception('Error ${res.statusCode}: ${res.body}');
        }
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(widget.usuario == null
                ? 'Usuario creado'
                : 'Usuario actualizado')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.usuario == null ? 'Nuevo Usuario' : 'Editar Usuario',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nombreCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v?.trim().isEmpty == true ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      v?.trim().isEmpty == true ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _telefonoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _rol,
                  decoration: const InputDecoration(
                    labelText: 'Rol *',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                    DropdownMenuItem(value: 'Cliente', child: Text('Cliente')),
                    DropdownMenuItem(
                        value: 'Conductor', child: Text('Conductor')),
                  ],
                  onChanged: (v) => setState(() => _rol = v!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordCtrl,
                  decoration: InputDecoration(
                    labelText: widget.usuario == null
                        ? 'Contraseña *'
                        : 'Nueva contraseña (dejar vacío para no cambiar)',
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (v) {
                    if (widget.usuario == null && v?.trim().isEmpty == true) {
                      return 'Requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _guardando
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _guardando ? null : _guardar,
                      child: _guardando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Guardar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
