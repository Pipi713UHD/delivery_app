import 'package:flutter/material.dart';

import '../../models/producto_model.dart';
import '../../models/restaurante_model.dart';
import '../../services/producto_service.dart';
import '../../services/restaurante_service.dart';

class ProductosAdminScreen extends StatefulWidget {
  const ProductosAdminScreen({super.key});

  @override
  State<ProductosAdminScreen> createState() => _ProductosAdminScreenState();
}

class _ProductosAdminScreenState extends State<ProductosAdminScreen> {
  final ProductoService service = ProductoService();
  final RestauranteService restauranteService = RestauranteService();

  late Future<List<Producto>> futureProductos;

  @override
  void initState() {
    super.initState();
    cargarProductos();
  }

  void cargarProductos() {
    futureProductos = service.listarAdmin();
  }

  void recargar() {
    setState(() {
      cargarProductos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestionar productos"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: abrirFormulario,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Producto>>(
        future: futureProductos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
              ),
            );
          }

          final productos = snapshot.data ?? [];

          if (productos.isEmpty) {
            return const Center(
              child: Text("No hay productos"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: productos.length,
            itemBuilder: (context, index) {
              final producto = productos[index];

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      producto.nombre.isNotEmpty
                          ? producto.nombre[0].toUpperCase()
                          : "P",
                    ),
                  ),
                  title: Text(
                    producto.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "${producto.categoria}\nL. ${producto.precio}",
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> abrirFormulario() async {
    final nombre = TextEditingController();
    final descripcion = TextEditingController();
    final precio = TextEditingController();

    final restaurantes =
        await restauranteService.listarRestaurantes(soloActivos: true);

    Restaurante? restauranteSeleccionado;

    if (restaurantes.isNotEmpty) {
      restauranteSeleccionado = restaurantes.first;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text("Agregar producto"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nombre,
                      decoration: const InputDecoration(
                        labelText: "Nombre",
                      ),
                    ),

                    TextField(
                      controller: descripcion,
                      decoration: const InputDecoration(
                        labelText: "Descripción",
                      ),
                    ),

                    TextField(
                      controller: precio,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Precio",
                      ),
                    ),

                    const SizedBox(height: 15),

                    DropdownButtonFormField<Restaurante>(
                      value: restauranteSeleccionado,
                      decoration: const InputDecoration(
                        labelText: "Restaurante",
                      ),
                      items: restaurantes.map((r) {
                        return DropdownMenuItem<Restaurante>(
                          value: r,
                          child: Text(r.nombre),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          restauranteSeleccionado = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await service.crearProducto({
                        "id_restaurante":
                            restauranteSeleccionado!.idRestaurante,

                        // Temporal
                        "id_categoria_producto": 1,

                        "nombre": nombre.text,
                        "descripcion": descripcion.text,
                        "precio": precio.text,
                        "imagen": ""
                      });

                      if (!mounted) return;

                      Navigator.pop(context);

                      recargar();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Producto creado correctamente",
                          ),
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            e.toString(),
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text("Guardar"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}