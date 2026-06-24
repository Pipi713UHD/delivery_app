import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapaSeleccionScreen extends StatefulWidget {
  const MapaSeleccionScreen({super.key});

  @override
  State<MapaSeleccionScreen> createState() =>
      _MapaSeleccionScreenState();
}

class _MapaSeleccionScreenState
    extends State<MapaSeleccionScreen> {

  GoogleMapController? _mapController;

  LatLng _posicion =
      const LatLng(14.0723, -87.1921);

  Marker? _marker;

  @override
  void initState() {
    super.initState();

    _obtenerUbicacionActual();
  }

  Future<void> _obtenerUbicacionActual() async {

    bool servicio =
        await Geolocator.isLocationServiceEnabled();

    if (!servicio) return;

    LocationPermission permiso =
        await Geolocator.checkPermission();

    if (permiso == LocationPermission.denied) {
      permiso =
          await Geolocator.requestPermission();
    }

    if (permiso ==
            LocationPermission.denied ||
        permiso ==
            LocationPermission.deniedForever) {
      return;
    }

    final posicion =
        await Geolocator.getCurrentPosition();

    setState(() {

      _posicion = LatLng(
        posicion.latitude,
        posicion.longitude,
      );

      _marker = Marker(
        markerId:
            const MarkerId("ubicacion"),
        position: _posicion,
      );
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        _posicion,
        17,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Seleccionar ubicación",
        ),
      ),

      body: GoogleMap(
        initialCameraPosition:
            CameraPosition(
          target: _posicion,
          zoom: 15,
        ),

        myLocationEnabled: true,

        myLocationButtonEnabled: true,

        markers: _marker == null
            ? {}
            : {_marker!},

        onMapCreated: (controller) {
          _mapController = controller;
        },

        onTap: (LatLng posicion) {

          setState(() {

            _posicion = posicion;

            _marker = Marker(
              markerId:
                  const MarkerId(
                      "ubicacion"),
              position: posicion,
            );
          });
        },
      ),

      floatingActionButton:
          FloatingActionButton.extended(

        onPressed: () {

          Navigator.pop(
            context,
            {
              "latitud":
                  _posicion.latitude,
              "longitud":
                  _posicion.longitude,
            },
          );
        },

        label: const Text(
          "Guardar",
        ),

        icon:
            const Icon(Icons.check),
      ),
    );
  }
}