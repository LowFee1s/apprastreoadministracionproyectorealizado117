import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerProvider with ChangeNotifier {
  Set<Marker> _markers = {};
  Set<Marker> get markers => _markers;

  String? _filtroaplicado;
  bool _filtroChecar = false;

  bool _botonmostrar = false;

  bool _botoncamiones = false;

  bool get botonmostrar => _botonmostrar;

  bool get botoncamiones => _botoncamiones;

  bool get filtroChecar => _filtroChecar;

  String? get filtroaplicado => _filtroaplicado;

  set filtroChecar(bool valor) {
    _filtroChecar = valor;
    notifyListeners();
  }

  set botoncamiones (bool valor11) {
    _botoncamiones = valor11;
    notifyListeners();
  }

  set botonmostrar(bool valor1) {
    _botonmostrar = valor1;
    notifyListeners();
  }

  set filtroaplicado(String? valor) {
    _filtroaplicado = valor;
    notifyListeners();
  }

  void updateMarkers(Set<Marker> newMarkers) {
    _markers = newMarkers;
    notifyListeners();
  }

  void quitarFiltro() {
    _filtroChecar = false;
    _filtroaplicado = null;
    notifyListeners();
  }

}
