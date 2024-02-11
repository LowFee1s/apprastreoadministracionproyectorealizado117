import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:device_info/device_info.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class MarkerProvider with ChangeNotifier {
  Set<Marker> _markers = {};
  Set<Marker> get markers => _markers;

  void updateMarkers(Set<Marker> newMarkers) {
    _markers = newMarkers;
    notifyListeners();
  }
}

void main() {
  runApp(ChangeNotifierProvider(
      create: (context) => MarkerProvider(), child: MyApp()));
}

Timer? timer;
StreamSubscription<Position>? positionStream;

void enviarLocalizacion(Position position) async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  String Iddevice = androidInfo.androidId;

  var url = Uri.parse('https://api-dev-jqhg.2.us-1.fl0.io/update_ubicacion');
  var headers = {
    "Content-type": "application/json",
    "Authorization": "Basic " +
        base64Encode(utf8.encode(
            "apprastreoadministracionproyectorealizado:PASSCODEFIMERASTREO14")),
  };
  var body = jsonEncode({
    'id_usuario': Iddevice,
    'localizacion': {'lat': position.latitude, 'lng': position.longitude}
  });

  var response = await http.post(url, headers: headers, body: body);

  if (response.statusCode == 200) {
    print("Ubicacion actualizada con exito!");
  } else {
    print("Error al actualizar la ubicacion: ${response.statusCode}");
  }
}

void detenerLocalizacion() {
  positionStream?.cancel();
  timer?.cancel();
}

void borrarubicacion() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  String Iddevice = androidInfo.androidId;

  var url = Uri.parse('https://api-dev-jqhg.2.us-1.fl0.io/quitar_ubicacion');
  var headers = {
    "Content-type": "application/json",
    "Authorization": "Basic " +
        base64Encode(utf8.encode(
            "apprastreoadministracionproyectorealizado:PASSCODEFIMERASTREO14")),
  };
  var body = jsonEncode({
    'id_usuario': Iddevice,
  });

  var response = await http.post(url, headers: headers, body: body);

  if (response.statusCode == 200) {
    print("Ubicacion quitada con exito!");
  } else {
    print("Error al quitar la ubicacion: ${response.statusCode}");
  }
}

class MyApp extends StatefulWidget {
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _mapStyle;
  GoogleMapController? mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    rootBundle.loadString('lib/assets/mapastyle14.json').then((string) {
      _mapStyle = string;
    });
    iniciarLocalizacion();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) async {
      Provider.of<MarkerProvider>(context, listen: false)
          .updateMarkers(await _getMarkers());
    });
  }

  Future<Set<Marker>> _getMarkers() async {
    var url = Uri.parse("https://api-dev-jqhg.2.us-1.fl0.io/obtener_ubicacion");
    var headers = {
      "Authorization": "Basic " +
          base64Encode(utf8.encode(
              "apprastreoadministracionproyectorealizado:PASSCODEFIMERASTREO14")),
    };
    var response = await http.get(url, headers: headers);
    var localizaciones = jsonDecode(response.body);

    BitmapDescriptor markerIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'lib/img/camion.png');

    return (localizaciones as Map<String, dynamic>).entries.map((entry) {
      var latitudLng = LatLng(entry.value['lat'], entry.value['lng']);
      return Marker(
        markerId: MarkerId(entry.key),
        position: latitudLng,
        infoWindow: InfoWindow(title: entry.key),
        icon: markerIcon,
      );
    }).toSet();
  }

  void iniciarLocalizacion() {
    positionStream = Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.high,
      intervalDuration: Duration(seconds: 2),
    ).listen(
      (Position position) async {
        enviarLocalizacion(position);
        CompassEvent? compassEvent = await FlutterCompass.events?.first;
        double? direction = compassEvent != null ? compassEvent.heading : null;
        BitmapDescriptor markerIcon = await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(), 'lib/img/camion.png');
        Marker marker = Marker(
            markerId: MarkerId('device_location'),
            position: LatLng(position.latitude, position.longitude),
            infoWindow: InfoWindow(title: 'Mi ubicaion'),
            icon: markerIcon,
            rotation: direction ?? 0);
        setState(() {
          _markers.add(marker);
        });
      },
    );

    timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _getMarkers());
  }

  Stream<Set<Marker>> _getMarkersStream() async* {
    while (true) {
      await Future.delayed(Duration(seconds: 1));
      yield await _getMarkers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Mi Aplicacion"),
        ),
        body: Stack(
          children: [
            GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
                if (_mapStyle != null) {
                  controller.setMapStyle(_mapStyle);
                }
                print("Mapa creado!");
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(0, 0),
                zoom: 17,
              ),
              markers: Provider.of<MarkerProvider>(context).markers,
            ),
            IconButton(
              icon: Icon(Icons.location_on),
              onPressed: () {
                if (mapController != null && _markers.isNotEmpty) {
                  Marker? deviceMarker = _markers.firstWhere((marker) =>
                      marker.markerId == MarkerId('device_location'));
                  if (deviceMarker != null) {
                    mapController!.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: deviceMarker.position,
                          zoom: 17,
                        ),
                      ),
                    );
                  }
                }
              },
            ),
            StreamBuilder<Set<Marker>>(
              stream: _getMarkersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else if (snapshot.hasData) {
                  _markers = snapshot.data ?? {};
                  return Container();
                } else {
                  return Container();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    detenerLocalizacion();
    borrarubicacion();
    super.dispose();
  }
}
