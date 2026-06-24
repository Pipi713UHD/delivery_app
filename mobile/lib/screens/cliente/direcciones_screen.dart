import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../models/direccion_model.dart';
import '../../services/direccion_service.dart';
import 'mapa_seleccion_screen.dart';

class DireccionesScreen extends StatefulWidget {
  const DireccionesScreen({super.key});

  @override
  State<DireccionesScreen> createState() => _DireccionesScreenState();
}

class _DireccionesScreenState extends State<DireccionesScreen> {
  final Color colorPrincipal = const Color(0xffe9004f);
  final Color colorTexto = const Color(0xff12051f);

  final DireccionService _direccionService = DireccionService();

  late Future<List<Direccion>> _direccionesFuture;

  @override
  void initState() {
    super.initState();
    _cargarDirecciones();
  }

  void _cargarDirecciones() {
    final idCliente = context.read<AuthProvider>().idCliente;
    if (idCliente == null) {
      _direccionesFuture = Future.value([]);
      return;
    }
    _direccionesFuture = _direccionService.listarPorCliente(idCliente);
  }

  Future<void> _recargar() async {
    setState(() {
      _cargarDirecciones();
    });
  }

  Future<void> _abrirFormulario({Direccion? direccion}) async {
    final idCliente = context.read<AuthProvider>().idCliente;

    if (idCliente == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No se encontró el cliente logueado"),
        ),
      );
      return;
    }

    final guardado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _FormularioDireccion(
          idCliente: idCliente,
          direccion: direccion,
          direccionService: _direccionService,
          colorPrincipal: colorPrincipal,
          colorTexto: colorTexto,
        );
      },
    );

    if (guardado == true) {
      _recargar();
    }
  }

  Future<void> _marcarPrincipal(Direccion direccion) async {
    final idCliente = context.read<AuthProvider>().idCliente;
    if (idCliente == null) return;

    try {
      await _direccionService.marcarPrincipal(
        idDireccion: direccion.idDireccion,
        idCliente: idCliente,
      );
      _recargar();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))),
      );
    }
  }

  Future<void> _confirmarEliminar(Direccion direccion) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Eliminar dirección"),
          content: Text(
            "¿Seguro que deseas eliminar \"${direccion.titulo.isEmpty ? direccion.direccion : direccion.titulo}\"?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                "Eliminar",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    try {
      await _direccionService.eliminar(direccion.idDireccion);
      _recargar();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorPrincipal,
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _encabezado(),
            Expanded(
              child: FutureBuilder<List<Direccion>>(
                future: _direccionesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: colorPrincipal),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          "Error: ${snapshot.error}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  }

                  final direcciones = snapshot.data ?? [];

                  if (direcciones.isEmpty) {
                    return _sinDirecciones();
                  }

                  return RefreshIndicator(
                    color: colorPrincipal,
                    onRefresh: _recargar,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                      itemCount: direcciones.length,
                      itemBuilder: (context, index) {
                        return _direccionCard(direcciones[index]);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _encabezado() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
      decoration: BoxDecoration(
        color: colorPrincipal,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Text(
              "Mis direcciones",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sinDirecciones() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off_outlined,
              color: colorPrincipal,
              size: 85,
            ),
            const SizedBox(height: 18),
            Text(
              "No tienes direcciones guardadas",
              style: TextStyle(
                color: colorTexto,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "Agrega una dirección para poder recibir tus pedidos.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 15),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _abrirFormulario(),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Agregar dirección",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorPrincipal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _direccionCard(Direccion direccion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xfff2f1f4),
        borderRadius: BorderRadius.circular(22),
        border: direccion.principal
            ? Border.all(color: colorPrincipal, width: 1.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xffffd6e6),
                child: Icon(Icons.location_on, color: colorPrincipal),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            direccion.titulo.isEmpty
                                ? "Dirección"
                                : direccion.titulo,
                            style: TextStyle(
                              color: colorTexto,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (direccion.principal) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: colorPrincipal,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Principal",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      direccion.direccion,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                    if (direccion.referencia.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        direccion.referencia,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (!direccion.principal)
                TextButton.icon(
                  onPressed: () => _marcarPrincipal(direccion),
                  icon: Icon(Icons.star_border, color: colorPrincipal, size: 18),
                  label: Text(
                    "Hacer principal",
                    style: TextStyle(color: colorPrincipal, fontWeight: FontWeight.bold),
                  ),
                ),
              const Spacer(),
              IconButton(
                onPressed: () => _abrirFormulario(direccion: direccion),
                icon: const Icon(Icons.edit_outlined, color: Colors.black54),
              ),
              IconButton(
                onPressed: () => _confirmarEliminar(direccion),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FormularioDireccion extends StatefulWidget {
  final int idCliente;
  final Direccion? direccion;
  final DireccionService direccionService;
  final Color colorPrincipal;
  final Color colorTexto;

  const _FormularioDireccion({
    required this.idCliente,
    required this.direccion,
    required this.direccionService,
    required this.colorPrincipal,
    required this.colorTexto,
  });

  @override
  State<_FormularioDireccion> createState() => _FormularioDireccionState();
}

class _FormularioDireccionState extends State<_FormularioDireccion> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _tituloController;
  late final TextEditingController _direccionController;
  late final TextEditingController _referenciaController;

  bool _marcarPrincipal = false;
  bool _guardando = false;
  double? _latitud = 0.0;
  double? _longitud = 0.0;

  bool get _esEdicion => widget.direccion != null;



  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.direccion?.titulo ?? "");
    _direccionController = TextEditingController(text: widget.direccion?.direccion ?? "");
    _referenciaController = TextEditingController(text: widget.direccion?.referencia ?? "");
    _marcarPrincipal = widget.direccion?.principal ?? false;
    _latitud = widget.direccion?.latitud;
    _longitud = widget.direccion?.longitud;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _direccionController.dispose();
    _referenciaController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarUbicacion() async {

  final resultado =
      await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) =>
          const MapaSeleccionScreen(),
    ),
  );

  if (resultado == null) return;

  setState(() {

    _latitud =
        resultado["latitud"];

    _longitud =
        resultado["longitud"];
  });

  ScaffoldMessenger.of(context)
      .showSnackBar(
    const SnackBar(
      content: Text(
        "Ubicación seleccionada",
      ),
    ),
  );
}

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _guardando = true;
    });

    try {
      if (_esEdicion) {
        await widget.direccionService.editar(
  idDireccion: widget.direccion!.idDireccion,
  titulo: _tituloController.text.trim(),
  direccion: _direccionController.text.trim(),
  referencia: _referenciaController.text.trim(),
  latitud: _latitud,
  longitud: _longitud,
);

        if (_marcarPrincipal && !widget.direccion!.principal) {
          await widget.direccionService.marcarPrincipal(
            idDireccion: widget.direccion!.idDireccion,
            idCliente: widget.idCliente,
          );
        }
      } else {
        await widget.direccionService.crear(
  idCliente: widget.idCliente,
  titulo: _tituloController.text.trim(),
  direccion: _direccionController.text.trim(),
  referencia: _referenciaController.text.trim(),
  latitud: _latitud,
  longitud: _longitud,
  principal: _marcarPrincipal,
);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  _esEdicion ? "Editar dirección" : "Nueva dirección",
                  style: TextStyle(
                    color: widget.colorTexto,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _tituloController,
                  decoration: _decoracion("Título (ej. Casa, Trabajo)", Icons.label_outline),
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return "Ingrese un título";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

TextFormField(
  controller: _direccionController,
  maxLines: 2,
  decoration: _decoracion(
    "Dirección completa",
    Icons.location_on_outlined,
  ),
  validator: (valor) {
    if (valor == null || valor.trim().isEmpty) {
      return "Ingrese la dirección";
    }
    return null;
  },
),

const SizedBox(height: 10),

SizedBox(
  width: double.infinity,
  child: OutlinedButton.icon(
    onPressed: _seleccionarUbicacion,
    icon: const Icon(Icons.map),
    label: Text(
      _latitud == null
          ? "Seleccionar en mapa"
          : "Ubicación seleccionada",
    ),
  ),
),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _referenciaController,
                  decoration: _decoracion(
                    "Referencia (opcional)",
                    Icons.info_outline,
                  ),
                ),
                const SizedBox(height: 6),
                CheckboxListTile(
                  value: _marcarPrincipal,
                  onChanged: (valor) {
                    setState(() {
                      _marcarPrincipal = valor ?? false;
                    });
                  },
                  activeColor: widget.colorPrincipal,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text(
                    "Usar como dirección principal",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _guardando ? null : _guardar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.colorPrincipal,
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _guardando
                        ? const SizedBox(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : Text(
                            _esEdicion ? "Guardar cambios" : "Guardar dirección",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _decoracion(String label, IconData icono) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icono, color: widget.colorPrincipal),
      filled: true,
      fillColor: const Color(0xfff2f1f4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }
}
