import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:device_info/device_info.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
    'Camion': 'Camion',
    'Ruta': {},
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

class MainScreen extends StatefulWidget {
  _MyAppState createState() => _MyAppState();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LocationScreen(),
    );
  }
}

class LocationScreen extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  bool _isLoading = false;

  void _onButtonPressed() async {
    setState(() {
      _isLoading = true;
    });
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
    } else {
      Position position = await Geolocator.getCurrentPosition();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Activar ubicacion'),
        ),
        body: Center(
          child: _isLoading
              ? CircularProgressIndicator()
              : ElevatedButton(
                  child: Text('Activar ubicacion y continuar'),
                  onPressed: _onButtonPressed,
                ),
        ),
      ),
    );
  }
}

class _MyAppState extends State<MainScreen> {
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
            infoWindow: InfoWindow(title: 'Mi ubicacion'),
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
    Marker? deviceMarker1 = _markers.firstWhere(
      (marker) => marker.markerId == MarkerId('device_location'),
    );
    LatLng rastreo;
    if (deviceMarker1 != null) {
      rastreo = deviceMarker1.position ?? LatLng(0, 0);
    } else {
      rastreo = LatLng(0, 0);
    }
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              zoomControlsEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
                if (_mapStyle != null) {
                  controller.setMapStyle(_mapStyle);
                }
                print("Mapa creado!");
              },
              initialCameraPosition: CameraPosition(
                target: rastreo,
                zoom: 15,
              ),
              markers: Provider.of<MarkerProvider>(context).markers,
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                child: Column(
                  children: [
                    SizedBox(height: 49.0),
                    SizedBox(height: 17),
                    ElevatedButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                Icons.search,
                                color: Colors.white70,
                                size: 40,
                              ),
                              Text(
                                '¿A donde quieres ir?',
                                style: TextStyle(
                                    fontSize: 19, color: Colors.white70),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.keyboard_arrow_up,
                                color: Colors.white70,
                                size: 40,
                              ),
                            ],
                          )
                        ],
                      ),
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding:
                            EdgeInsets.symmetric(horizontal: 49, vertical: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 17, 0),
                  child: Column(
                    children: [
                      Align(
                          alignment: Alignment.bottomRight,
                          child: Column(
                            children: [
                              Container(
                                height: 50,
                                width: 50,
                                child: FloatingActionButton(
                                  child: Icon(
                                      Icons.add,
                                      color: Colors.blueGrey,
                                  ),
                                  onPressed: () {
                                    mapController?.animateCamera(
                                      CameraUpdate.zoomIn(),
                                    );
                                  },
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(100))
                                  ),
                                ),
                              ),
                              Container(
                                height: 50,
                                width: 50,
                                child: FloatingActionButton(
                                    child: Icon(
                                        Icons.remove,
                                        color: Colors.blueGrey,
                                    ),
                                    onPressed: () {
                                      mapController?.animateCamera(
                                        CameraUpdate.zoomOut(),
                                      );
                                    },
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(100))
                                  ),
                                ),
                              ),
                            ],
                          )),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(10, 25, 10, 100),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(10),
                          backgroundColor: Colors.orange),
                      child: Icon(
                        Icons.my_location_rounded,
                        color: Colors.white70,
                        size: 49,
                      ),
                      onPressed: () {
                        if (mapController != null && _markers.isNotEmpty) {
                          Marker? deviceMarker = _markers.firstWhere((marker) =>
                              marker.markerId == MarkerId('device_location'));
                          if (deviceMarker != null) {
                            mapController!.animateCamera(
                              CameraUpdate.newCameraPosition(
                                CameraPosition(
                                  target: deviceMarker.position,
                                  zoom: 15,
                                ),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            StreamBuilder<Set<Marker>>(
              stream: _getMarkersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container();
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
