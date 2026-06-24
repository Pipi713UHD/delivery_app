import 'package:flutter/material.dart';
import '../../models/restaurante_model.dart';
import '../../services/restaurante_service.dart';

class RestaurantesAdminScreen extends StatefulWidget {
  const RestaurantesAdminScreen({super.key});
  @override
  State<RestaurantesAdminScreen> createState() => _RestaurantesAdminScreenState();
}

class _RestaurantesAdminScreenState extends State<RestaurantesAdminScreen> {
  final service = RestauranteService();
  late Future<List<Restaurante>> future;
  @override
  void initState() { super.initState(); future = service.listarRestaurantes(soloActivos: false); }
  void recargar() => setState(() => future = service.listarRestaurantes(soloActivos: false));

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Gestionar restaurantes')),
    floatingActionButton: FloatingActionButton(onPressed: () => abrirFormulario(), child: const Icon(Icons.add)),
    body: FutureBuilder<List<Restaurante>>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
        final lista = snap.data ?? [];
        if (lista.isEmpty) return const Center(child: Text('No hay restaurantes'));
        return ListView.builder(
          padding: const EdgeInsets.all(12), itemCount: lista.length,
          itemBuilder: (_, i) { final r = lista[i]; final activo = r.estado == 1;
            return Card(child: ListTile(
              leading: CircleAvatar(child: Text(r.nombre.isEmpty ? 'R' : r.nombre[0].toUpperCase())),
              title: Text(r.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${r.categoria} • ${r.telefono}\n${activo ? 'Activo' : 'Inactivo'}'),
              isThreeLine: true,
              trailing: PopupMenuButton<String>(onSelected: (v) async {
                try {
                  if (v == 'editar') abrirFormulario(restaurante: r);
                  if (v == 'estado') { await service.cambiarEstado(r.idRestaurante, activo ? 0 : 1); recargar(); }
                  if (v == 'eliminar') { await service.eliminarRestaurante(r.idRestaurante); recargar(); }
                } catch(e){ if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
              }, itemBuilder: (_) => [
                const PopupMenuItem(value:'editar', child: Text('Editar')),
                PopupMenuItem(value:'estado', child: Text(activo ? 'Desactivar' : 'Activar')),
                const PopupMenuItem(value:'eliminar', child: Text('Eliminar')),
              ]),
            ));
          },
        );
      },
    ),
  );

  void abrirFormulario({Restaurante? restaurante}) {
    final nombre = TextEditingController(text: restaurante?.nombre ?? '');
    final descripcion = TextEditingController(text: restaurante?.descripcion ?? '');
    final telefono = TextEditingController(text: restaurante?.telefono ?? '');
    final correo = TextEditingController(text: restaurante?.correo ?? '');
    final direccion = TextEditingController(text: restaurante?.direccion ?? '');
    final costo = TextEditingController(text: restaurante?.costoEnvio ?? '0');
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text(restaurante == null ? 'Crear restaurante' : 'Editar restaurante'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nombre, decoration: const InputDecoration(labelText: 'Nombre')),
        TextField(controller: descripcion, decoration: const InputDecoration(labelText: 'Descripción')),
        TextField(controller: telefono, decoration: const InputDecoration(labelText: 'Teléfono')),
        TextField(controller: correo, decoration: const InputDecoration(labelText: 'Correo')),
        TextField(controller: direccion, decoration: const InputDecoration(labelText: 'Dirección')),
        TextField(controller: costo, decoration: const InputDecoration(labelText: 'Costo envío')),
      ])),
      actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Cancelar')), ElevatedButton(onPressed: () async {
        final body = { 'id_restaurante': restaurante?.idRestaurante, 'nombre': nombre.text, 'descripcion': descripcion.text, 'telefono': telefono.text, 'correo': correo.text, 'direccion': direccion.text, 'costo_envio': costo.text, 'id_categoria_restaurante': 1, 'hora_apertura': '08:00:00', 'hora_cierre': '22:00:00'};
        try { restaurante == null ? await service.crearRestaurante(body) : await service.editarRestaurante(body); if(mounted){Navigator.pop(context); recargar();}}
        catch(e){ if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
      }, child: const Text('Guardar'))],
    ));
  }
}
