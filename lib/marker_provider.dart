import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerProvider with ChangeNotifier {
  Set<Marker> _markers = {};
  Set<Marker> get markers => _markers;

  String? _filtroaplicado;
  bool _filtroChecar = false;

  bool get filtroChecar => _filtroChecar;

  String? get filtroaplicado => _filtroaplicado;

  set filtroChecar(bool valor) {
    _filtroChecar = valor;
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
