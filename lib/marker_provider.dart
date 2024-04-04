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
  LatLng _datosdispositivo = LatLng(0, 0);

  List<bool> _botoncardrealizado = [];
  Map<String, dynamic> _datosfirestore = {};
  Map<String, dynamic> get datosfirestore => _datosfirestore;
  Map<String, Future<String>> arrivalTime = {};
  Map<String, Future<String>> locationName = {};

  bool _botoncamiones = false;

  LatLng get datosdispositivo => _datosdispositivo;
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

  void setdatosdispositivo(LatLng valor) {
    _datosdispositivo = valor;
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

  void setDatosFirestore(Map<String, dynamic> datos) {
    _datosfirestore = datos;
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
