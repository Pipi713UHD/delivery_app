import 'package:flutter/material.dart';

import '../../models/usuario_model.dart';
import '../../services/usuario_service.dart';

class RepartidoresAdminScreen extends StatefulWidget {
  const RepartidoresAdminScreen({super.key});

  @override
  State<RepartidoresAdminScreen> createState() =>
      _RepartidoresAdminScreenState();
}

class _RepartidoresAdminScreenState
    extends State<RepartidoresAdminScreen> {

  final UsuarioService service = UsuarioService();

  late Future<List<Usuario>> futureRepartidores;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  void cargarDatos() {
    futureRepartidores =
        service.listarUsuarios(rol: "repartidor");
  }

  void recargar() {
    setState(() {
      cargarDatos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Gestionar repartidores",
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mostrarFormulario();
        },
        child: const Icon(Icons.add),
      ),

      body: FutureBuilder<List<Usuario>>(
        future: futureRepartidores,
        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }

          final repartidores =
              snapshot.data ?? [];

          if (repartidores.isEmpty) {
            return const Center(
              child: Text(
                "No hay repartidores",
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: repartidores.length,
            itemBuilder: (context, index) {

              final repartidor =
                  repartidores[index];

              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(
                      Icons.delivery_dining,
                    ),
                  ),

                  title: Text(
                    repartidor.nombreCompleto,
                  ),

                  subtitle: Text(
                    "${repartidor.correo}\n${repartidor.telefono}",
                  ),

                  trailing: Switch(
                    value:
                        repartidor.estado == 1,

                    onChanged: (valor) async {

                      try {

                        await service
                            .cambiarEstado(
                          repartidor.idUsuario,
                          valor ? 1 : 0,
                        );

                        recargar();

                      } catch (e) {

                        if (!mounted) return;

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          SnackBar(
                            content:
                                Text(e.toString()),
                          ),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _mostrarFormulario() async {

    final nombre =
        TextEditingController();

    final apellido =
        TextEditingController();

    final correo =
        TextEditingController();

    final telefono =
        TextEditingController();

    final password =
        TextEditingController();

    final vehiculo =
        TextEditingController();

    final placa =
        TextEditingController();

    final licencia =
        TextEditingController();

    showDialog(
      context: context,
      builder: (_) {

        return AlertDialog(
          title: const Text(
            "Nuevo repartidor",
          ),

          content:
              SingleChildScrollView(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [

                TextField(
                  controller: nombre,
                  decoration:
                      const InputDecoration(
                    labelText: "Nombre",
                  ),
                ),

                TextField(
                  controller: apellido,
                  decoration:
                      const InputDecoration(
                    labelText: "Apellido",
                  ),
                ),

                TextField(
                  controller: correo,
                  decoration:
                      const InputDecoration(
                    labelText: "Correo",
                  ),
                ),

                TextField(
                  controller: telefono,
                  decoration:
                      const InputDecoration(
                    labelText: "Teléfono",
                  ),
                ),

                TextField(
                  controller: password,
                  decoration:
                      const InputDecoration(
                    labelText: "Contraseña",
                  ),
                ),

                TextField(
                  controller: vehiculo,
                  decoration:
                      const InputDecoration(
                    labelText:
                        "Tipo vehículo",
                  ),
                ),

                TextField(
                  controller: placa,
                  decoration:
                      const InputDecoration(
                    labelText: "Placa",
                  ),
                ),

                TextField(
                  controller: licencia,
                  decoration:
                      const InputDecoration(
                    labelText: "Licencia",
                  ),
                ),
              ],
            ),
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Cancelar",
              ),
            ),

            ElevatedButton(
              onPressed: () async {

                try {

                  await service
                      .crearRepartidor({

                    "nombre":
                        nombre.text,

                    "apellido":
                        apellido.text,

                    "correo":
                        correo.text,

                    "telefono":
                        telefono.text,

                    "password":
                        password.text,

                    "tipo_vehiculo":
                        vehiculo.text,

                    "placa":
                        placa.text,

                    "licencia":
                        licencia.text,
                  });

                  if (!mounted) return;

                  Navigator.pop(context);

                  recargar();

                  ScaffoldMessenger.of(
                          context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Repartidor creado correctamente",
                      ),
                    ),
                  );

                } catch (e) {

                  if (!mounted) return;

                  ScaffoldMessenger.of(
                          context)
                      .showSnackBar(
                    SnackBar(
                      content:
                          Text(e.toString()),
                    ),
                  );
                }
              },
              child: const Text(
                "Guardar",
              ),
            ),
          ],
        );
      },
    );
  }
}