import 'package:flutter/material.dart';
import '../../models/usuario_model.dart';
import '../../services/usuario_service.dart';

class UsuariosAdminScreen extends StatefulWidget {
  final String tipo;
  const UsuariosAdminScreen({super.key, required this.tipo});
  @override
  State<UsuariosAdminScreen> createState() => _UsuariosAdminScreenState();
}

class _UsuariosAdminScreenState extends State<UsuariosAdminScreen> {
  final service = UsuarioService();
  late Future<List<Usuario>> future;
  @override
  void initState() { super.initState(); future = service.listarUsuarios(rol: widget.tipo); }
  void recargar() => setState(() => future = service.listarUsuarios(rol: widget.tipo));

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.tipo == 'cliente' ? 'Gestionar clientes' : 'Gestionar repartidores')),
    body: FutureBuilder<List<Usuario>>(
      future: future,
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
        final lista = snap.data ?? [];
        if (lista.isEmpty) return const Center(child: Text('No hay usuarios'));
        return ListView.builder(padding: const EdgeInsets.all(12), itemCount: lista.length, itemBuilder: (_, i) {
          final u = lista[i]; final activo = u.estado == 1;
          return Card(child: ListTile(
            leading: CircleAvatar(child: Icon(widget.tipo == 'cliente' ? Icons.person : Icons.delivery_dining)),
            title: Text(u.nombreCompleto, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${u.correo}\n${u.telefono} • ${activo ? 'Activo' : 'Inactivo'}'),
            isThreeLine: true,
            trailing: Switch(value: activo, onChanged: (v) async {
              try { await service.cambiarEstado(u.idUsuario, v ? 1 : 0); recargar(); }
              catch(e){ if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
            }),
          ));
        });
      },
    ),
  );
}
