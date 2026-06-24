import 'package:flutter/material.dart';
import '../../models/pedido_model.dart';
import '../../services/pedido_service.dart';

class PedidosAdminScreen extends StatefulWidget {
  const PedidosAdminScreen({super.key});
  @override
  State<PedidosAdminScreen> createState() => _PedidosAdminScreenState();
}

class _PedidosAdminScreenState extends State<PedidosAdminScreen> {
  final service = PedidoService();
  late Future<List<Pedido>> future;
  @override
  void initState() { super.initState(); future = service.listarTodosAdmin(); }
  void recargar() => setState(() => future = service.listarTodosAdmin());

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Gestionar pedidos')),
    body: FutureBuilder<List<Pedido>>(
      future: future,
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
        final lista = snap.data ?? [];
        if (lista.isEmpty) return const Center(child: Text('No hay pedidos'));
        return ListView.builder(padding: const EdgeInsets.all(12), itemCount: lista.length, itemBuilder: (_, i) {
          final p = lista[i];
          return Card(child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.receipt_long)),
            title: Text('Pedido #${p.idPedido} - L ${p.total}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${p.restaurante}\nEstado: ${p.estado}'),
            isThreeLine: true,
            trailing: PopupMenuButton<int>(onSelected: (estado) async {
              try { await service.cambiarEstadoAdmin(idPedido: int.parse(p.idPedido), idEstadoPedido: estado); recargar(); }
              catch(e){ if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
            }, itemBuilder: (_) => const [
              PopupMenuItem(value: 1, child: Text('Pendiente')),
              PopupMenuItem(value: 2, child: Text('Confirmado')),
              PopupMenuItem(value: 3, child: Text('Preparando')),
              PopupMenuItem(value: 4, child: Text('En camino')),
              PopupMenuItem(value: 5, child: Text('Entregado')),
              PopupMenuItem(value: 6, child: Text('Cancelado')),
            ]),
          ));
        });
      },
    ),
  );
}
