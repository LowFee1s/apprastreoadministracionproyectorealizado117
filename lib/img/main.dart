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

  String? _filtroaplicado;

  String? get filtroaplicado => _filtroaplicado;

  set filtroaplicado(String? valor) {
    _filtroaplicado = valor;
    notifyListeners();
  }

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

  var url = Uri.parse(
      'https://appserverapirealizado15-dev-zsrt.1.us-1.fl0.io/update_ubicacion');
  var headers = {
    "Content-type": "application/json",
    "Authorization": "Basic " +
        base64Encode(utf8.encode(
            "apprastreoadministracionproyectorealizado:PASSCODEFIMERASTREO14")),
  };
  var body = jsonEncode({
    'id_usuario': Iddevice,
    'Camion': '101 - Ebanos',
    'Ruta': [
      {"lat": 25.7969811, "lng": -100.25335319999999},
      {"lat": 25.796800899999997, "lng": -100.2530536},
      {"lat": 25.7969811, "lng": -100.25335319999999},
      {"lat": 25.784658399999998, "lng": -100.2540162},
      {"lat": 25.784972, "lng": -100.2664976},
      {"lat": 25.7710959, "lng": -100.2653776},
      {"lat": 25.7676545, "lng": -100.2919534},
      {"lat": 25.7238853, "lng": -100.31255279999999},
      {"lat": 25.757854899999998, "lng": -100.2960626},
      {"lat": 25.7615654, "lng": -100.28786579999999},
      {"lat": 25.783837, "lng": -100.2486119},
      {"lat": 25.796800899999997, "lng": -100.2530536},
    ],
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

  var url = Uri.parse(
      'https://appserverapirealizado15-dev-zsrt.1.us-1.fl0.io/quitar_ubicacion');
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

class MyButton extends StatefulWidget {
  @override
  _MyButtonState createState() => _MyButtonState();
}

Future<List<String>> getCamiones() async {
  final url = Uri.parse(
      "https://appserverapirealizado15-dev-zsrt.1.us-1.fl0.io/camiones");
  final headers = {
    "Authorization": "Basic " +
        base64Encode(utf8.encode(
            "apprastreoadministracionproyectorealizado:PASSCODEFIMERASTREO14")),
  };

  var response = await http.get(url, headers: headers);

  var camiones = jsonDecode(response.body).cast<String>();

  return camiones;
}

class _MyButtonState extends State<MyButton> {
  String filter = '';
  final _controller = TextEditingController();
  var TodoslosCamiones;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
        future: getCamiones(),
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            TodoslosCamiones = snapshot.data;
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else {
            TodoslosCamiones = snapshot.data;
          }
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(255, 207, 164, 1),
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(40),
                              topLeft: Radius.circular(40),
                            )),
                        height: 140,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              SizedBox(height: 15),
                              Container(
                                width: 200,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(50)
                                ),
                                child: ElevatedButton(
                                  child: Container(),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                              SizedBox(height: 41),
                              Container(
                                height: 51,
                                child: Material(
                                  color: Colors.transparent,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(50),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.grey.withOpacity(0.7),
                                              spreadRadius: 5,
                                              blurRadius: 7,
                                              offset: Offset(0, 3)),
                                        ]),
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(15, 0, 15, 0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Autocomplete<String>(
                                              optionsBuilder: (TextEditingValue
                                                  textEditingValue) {
                                                if (textEditingValue.text == '') {
                                                  return const Iterable<
                                                      String>.empty();
                                                }
                                                return TodoslosCamiones.where(
                                                    (String option) {
                                                  return option.contains(
                                                      textEditingValue.text
                                                          .toLowerCase());
                                                });
                                              },
                                              fieldViewBuilder: (BuildContext
                                                      context,
                                                  TextEditingController
                                                      controladorTexto,
                                                  FocusNode nodoEnfoque,
                                                  VoidCallback alEnviarCampo) {
                                                return TextFormField(
                                                  controller: controladorTexto,
                                                  decoration: InputDecoration(
                                                    floatingLabelBehavior:
                                                        FloatingLabelBehavior
                                                            .never,
                                                    border: InputBorder.none,
                                                    contentPadding:
                                                        EdgeInsets.fromLTRB(
                                                            0, 12, 0, 12),
                                                    labelText: controladorTexto
                                                            .text
                                                            .trim()
                                                            .isNotEmpty
                                                        ? null
                                                        : "Filtrar por camion",
                                                    hintText: (nodoEnfoque
                                                                .hasFocus &&
                                                            controladorTexto.text
                                                                .trim()
                                                                .isEmpty)
                                                        ? "Escribir nombre del camion. "
                                                        : (nodoEnfoque.hasFocus ==
                                                                    false &&
                                                                controladorTexto
                                                                    .text
                                                                    .trim()
                                                                    .isEmpty)
                                                            ? "Escribir nombre del camion. "
                                                            : null,
                                                  ),
                                                  focusNode: nodoEnfoque,
                                                  onChanged: (String texto) {
                                                    setState(() {
                                                      controladorTexto.text =
                                                          texto;
                                                    });
                                                  },
                                                  onFieldSubmitted:
                                                      (String seleccion) {
                                                    alEnviarCampo();
                                                    print(
                                                        "El valor ingresado es $seleccion");
                                                  },
                                                );
                                              },
                                              onSelected: (String value) async {
                                                _controller.text = value;
                                              },
                                            ),
                                          ),
                                          IconButton(
                                              icon: Icon(Icons.search),
                                              onPressed: () async {
                                                String camion = _controller.text;

                                                if (camion.isEmpty) {
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          title:
                                                              Text('Campo vacio'),
                                                          content: Text(
                                                              'Por favor, ingresa un valor valido.  '),
                                                          actions: <Widget>[
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: Text('Ok'),
                                                            ),
                                                          ],
                                                        );
                                                      });
                                                }

                                                print('Has ingresado: $camion');

                                                var url = Uri.parse(
                                                    "https://appserverapirealizado15-dev-zsrt.1.us-1.fl0.io/obtener_ubicacion/$camion");
                                                var headers = {
                                                  "Authorization": "Basic " +
                                                      base64Encode(utf8.encode(
                                                          "apprastreoadministracionproyectorealizado:PASSCODEFIMERASTREO14")),
                                                };
                                                var response = await http.get(url,
                                                    headers: headers);
                                                var localizaciones =
                                                    jsonDecode(response.body);

                                                Provider.of<MarkerProvider>(
                                                        context,
                                                        listen: false)
                                                    .filtroaplicado = camion;
                                                Navigator.of(context).pop();

                                                if (localizaciones.isEmpty) {
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          title: Text(
                                                              'No se encontraron camiones'),
                                                          content: Text(
                                                              'No se encontraron camiones con el nombre: $camion'),
                                                          actions: <Widget>[
                                                            TextButton(
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                child: Text('Ok'))
                                                          ],
                                                        );
                                                      });
                                                }
                                              }),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ),
          );
        });
  }
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

class _MyAppState extends State<MainScreen> {
  String? _mapStyle;
  GoogleMapController? mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

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
            Container(
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
                                padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
                                child: Container(
                                    height: MediaQuery.of(context).size.height,
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
