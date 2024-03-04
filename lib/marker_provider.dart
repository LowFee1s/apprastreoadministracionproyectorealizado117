import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerProvider with ChangeNotifier {
  Set<Marker> _markers = {};
  Set<Marker> get markers => _markers;

  String? _filtroaplicado;
  String? _filtroaplicadorealizado;
  int _cantidadcamionesrealizado = 10;
  bool _filtroChecar = false;
  bool _filtrotipo = false;

  bool _botonmostrar = false;

  List<bool> _botoncardrealizado = [];

  bool _botoncamiones = false;

  bool get botonmostrar => _botonmostrar;

  int get cantidadcamionesrealizado => _cantidadcamionesrealizado;

  bool getbotoncardrealizado(int index) => _botoncardrealizado[index];

  bool get botoncamiones => _botoncamiones;

  bool get filtroChecar => _filtroChecar;
  bool get filtroTipo => _filtrotipo;

  String? get filtroaplicadorealizado => _filtroaplicadorealizado;

  String? get filtroaplicado => _filtroaplicado;

  set filtroChecar(bool valor) {
    _filtroChecar = valor;
    notifyListeners();
  }

  set filtroTipo(bool valor) {
    _filtrotipo = valor;
    notifyListeners();
  }

  MarkerProvider() {
    _botoncardrealizado = List<bool>.filled(_cantidadcamionesrealizado, false);
  }

  set botoncamiones (bool valor11) {
    _botoncamiones = valor11;
    notifyListeners();
  }

  void setbotoncardrealizado(int index, bool valor17) {
    _botoncardrealizado[index] = valor17;
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

  set filtroaplicadorealizado(String? valor17) {
    _filtroaplicadorealizado = valor17;
    notifyListeners();
  }

  set cantidadcamionesrealizado(int valor) {
    _cantidadcamionesrealizado = valor;
    notifyListeners();
  }

  void updateMarkers(Set<Marker> newMarkers) {
    _markers = newMarkers;
    notifyListeners();
  }

  void quitarFiltro() {
    _filtroChecar = false;
    _filtrotipo = false;
    _filtroaplicadorealizado = null;
    _filtroaplicado = null;
    notifyListeners();
  }

}
