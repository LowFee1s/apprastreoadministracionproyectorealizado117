import 'dart:async';

import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

class GlobalResourceHandler {
  StreamSubscription<CompassEvent>? _compassSubscription;
  Timer? timer;
  StreamSubscription<Position>? positionStream;

  void iniciarRecursos() {
    // Aquí va el código para iniciar los recursos (temporizadores, suscripciones, etc.)
  }

  void detenerRecursos() {
    _compassSubscription?.cancel();
    timer?.cancel();
    positionStream?.cancel();
    // Aquí va el código para detener los recursos
  }
}