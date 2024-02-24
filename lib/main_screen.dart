import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'location_service.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'http_service.dart';
import 'dart:async';
import 'my_button.dart';
import 'marker_provider.dart';

class MainScreen extends StatefulWidget {
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MainScreen> with SingleTickerProviderStateMixin {
  String? _mapStyle;
  GoogleMapController? mapController;
  Set<Marker> _markers = {};
  double? _direction = 0.0;
  BitmapDescriptor? northMarker;
  BitmapDescriptor? southMarker;
  BitmapDescriptor? eastMarker;
  BitmapDescriptor? westMarker;
  BitmapDescriptor? northeastMarker;
  BitmapDescriptor? northwestMarker;
  BitmapDescriptor? southeastMarker;
  BitmapDescriptor? southwestMarker;

  Map<String, double> markerDirecciones = {};

  Set<Polyline> _polylines = {};

  Timer? timer;
  StreamSubscription<Position>? positionStream;

  @override
  void initState() {
    super.initState();

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), "lib/img/camionatras.png")
    .then((icon) => northMarker = icon);
   BitmapDescriptor.fromAssetImage(
          ImageConfiguration(), "lib/img/camionatras.png")
      .then((icon) => northeastMarker = icon);
   BitmapDescriptor.fromAssetImage(
          ImageConfiguration(), "lib/img/camionatras.png")
      .then((icon) => northwestMarker = icon);
   BitmapDescriptor.fromAssetImage(
          ImageConfiguration(), "lib/img/camion.png")
      .then((icon) => southMarker = icon);
   BitmapDescriptor.fromAssetImage(
          ImageConfiguration(), "lib/img/camion.png")
      .then((icon) => southeastMarker = icon);
   BitmapDescriptor.fromAssetImage(
          ImageConfiguration(), "lib/img/camion.png")
      .then((icon) => southwestMarker = icon);
   BitmapDescriptor.fromAssetImage(
          ImageConfiguration(), "lib/img/camion.png")
      .then((icon) => eastMarker = icon);
   BitmapDescriptor.fromAssetImage(
          ImageConfiguration(), "lib/img/camion.png")
      .then((icon) => westMarker = icon);
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
    FlutterCompass.events!.listen((CompassEvent event) {
      setState(() {
        _direction = event.heading;
      });
    });
    String url;
    String? filtroaplicado =
        Provider.of<MarkerProvider>(context, listen: false).filtroaplicado;
    if (filtroaplicado == null) {
      url =
      "https://appserverapirealizado15-dev-zsrt.1.us-1.fl0.io/obtener_ubicacion";
    } else {
      url =
      "https://appserverapirealizado15-dev-zsrt.1.us-1.fl0.io/obtener_ubicacion/$filtroaplicado";
    }
    var headers = {
      "Authorization": "Basic " +
          base64Encode(utf8.encode(
              "apprastreoadministracionproyectorealizado:PASSCODEFIMERASTREO14")),
    };
    var response = await http.get(Uri.parse(url), headers: headers);
    var localizaciones = jsonDecode(response.body);

    BitmapDescriptor markerIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'lib/img/camion.png');


    return (localizaciones as Map<String, dynamic>).entries.map((entry) {
      var latitudLng = LatLng(entry.value['localizacion']['lat'] ?? 0.0,
          entry.value['localizacion']['lng'] ?? 0);
      double newDireccion = entry.value['Direccion'];

      markerDirecciones[entry.key] = newDireccion;

      return Marker(
        markerId: MarkerId(entry.key),
        position: latitudLng,
        infoWindow: InfoWindow(title: entry.key),
        icon:  markerDirecciones[entry.key]! >= 0 && markerDirecciones[entry.key]!  < 45
          ? northeastMarker ?? markerIcon
          : markerDirecciones[entry.key]!  >= 45 && markerDirecciones[entry.key]!  < 90
            ? eastMarker ?? markerIcon
          : markerDirecciones[entry.key]!  >= 90 && markerDirecciones[entry.key]!  < 135
            ? southeastMarker ?? markerIcon
          : markerDirecciones[entry.key]!  >= 135 && markerDirecciones[entry.key]!  < 180
            ? southMarker ?? markerIcon
          : markerDirecciones[entry.key]!  >= 180 && markerDirecciones[entry.key]!  < 225
            ? southwestMarker ?? markerIcon
          : markerDirecciones[entry.key]!  >= 225 && markerDirecciones[entry.key]!  < 270
            ? westMarker ?? markerIcon
            : northwestMarker ?? markerIcon,
        rotation: markerDirecciones[entry.key] ?? 0,
      );
    }).toSet();
  }

  Future<Set<Marker>> _createMarkersFromdata(Map<String, dynamic> data) async {
    final markerIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), "lib/img/camion.png");
    return data.entries.map((entry) {
      var latitudlng = LatLng(
          entry.value['localizacion']['lat'], entry.value['localizacion']['lng']);
      return Marker(
        markerId: MarkerId(entry.key),
        position: latitudlng,
        infoWindow: InfoWindow(title: entry.key),
        icon: BitmapDescriptor.defaultMarker,
      );
    }).toSet();
  }

  void iniciarLocalizacion() {
    positionStream = Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.high,
      intervalDuration: Duration(seconds: 1),
    ).listen(
          (Position position) async {
        enviarLocalizacion(position, _direction);
        CompassEvent? compassEvent = await FlutterCompass.events?.first;
        double? direction = compassEvent != null ? compassEvent.heading : null;

    BitmapDescriptor markerIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'lib/img/camion.png');

        Marker marker = Marker(
            markerId: MarkerId('device_location'),
            position: LatLng(position.latitude, position.longitude),
            infoWindow: InfoWindow(title: 'Mi ubicacion'),
            icon: markerIcon,
            rotation: direction ?? 0
        );
        setState(() {
          _markers.add(marker);
        });
      },
    );

    timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _getMarkers());
  }

  Polyline _crearRuta() {
    var rutaPuntos = <LatLng>[];

    return Polyline(
      polylineId: PolylineId('101 - Ebanos'),
      visible: true,
      points: rutaPuntos,
      color: Colors.blue,
    );
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
              polylines: _polylines,
              markers: Provider.of<MarkerProvider>(context).markers,
            ),
            Consumer<MarkerProvider>(
              builder: (context, markerProvider, child) {
                if (markerProvider.filtroaplicado != null) {
                  return Container(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(10.0),
                        backgroundColor: Colors.orange,
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white70,
                        size: 49,
                      ),
                      onPressed: () {
                        markerProvider.filtroaplicado = null;
                      },
                    ),
                  );
                } else {
                  return Container(
                    padding: const EdgeInsets.fromLTRB(17, 10, 17, 10),
                    child: Center(
                      child: Column(
                        children: [
                          SizedBox(height: 40.0),
                          SizedBox(height: 7),
                          ElevatedButton(
                            child: Row(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.search,
                                      color: Colors.white70,
                                      size: 40,
                                    ),
                                    SizedBox(width: 21),
                                    Text(
                                      '¿A donde quieres ir?',
                                      style: TextStyle(
                                          fontSize: 19, color: Colors.white54),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                Icon(
                                  Icons.keyboard_arrow_up,
                                  color: Colors.white70,
                                  size: 40,
                                ),
                              ],
                            ),
                            onPressed: () {
                              showModalBottomSheet(
                                  backgroundColor: Colors.transparent,
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (context) {
                                    return Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 100, 0, 0),
                                      child: Container(
                                          height: MediaQuery
                                              .of(context)
                                              .size
                                              .height,
                                          child: MyButton()
                                      ),
                                    );
                                  });
                              //Navigator.of(context).push(
                              //MaterialPageRoute(builder: (context) => MyButton()),
                              //);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: EdgeInsets.fromLTRB(17, 11, 17, 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              }
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
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(100))),
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
                                      borderRadius: BorderRadius.vertical(
                                          bottom: Radius.circular(100))),
                                ),
                              ),
                            ],
                          )),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 25, 10, 100),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(10),
                          backgroundColor: Colors.orange
                      ),
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
    FlutterCompass.events?.drain();
    detenerLocalizacion(timer, positionStream);
    borrarubicacion();
    super.dispose();
  }
}
