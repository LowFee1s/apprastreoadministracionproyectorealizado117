import 'package:apprastreoadministracionproyectorealizado/camionscreenrealizado.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'location_service.dart';
import 'package:flutter/services.dart' show DeviceOrientation, SystemChrome, rootBundle;
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

class _MyAppState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  String? _mapStyle;
  GoogleMapController? mapController;
  Set<Marker> _markers = {};
  double? _direction = 0.0;
  User? currentuser = FirebaseAuth.instance.currentUser;
  BitmapDescriptor? northMarker;
  BitmapDescriptor? southMarker;
  BitmapDescriptor? eastMarker;
  BitmapDescriptor? westMarker;
  BitmapDescriptor? northeastMarker;
  BitmapDescriptor? northwestMarker;
  BitmapDescriptor? southeastMarker;
  BitmapDescriptor? southwestMarker;
  Map<String, dynamic> datos = {};
  StreamSubscription<CompassEvent>? _compassSubscription;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  Map<String, double> markerDirecciones = {};
  var TodoslosCamiones;
  bool botoncamionrealizado = false;
  List<Map<String, dynamic>> camionesmostrar = [];
  String? camionfiltradorealizado;
  String? camionfiltradotiporealizado;
  double _opacidadfiltrar = 1;

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
    BitmapDescriptor.fromAssetImage(ImageConfiguration(), "lib/img/camion.png")
        .then((icon) => southMarker = icon);
    BitmapDescriptor.fromAssetImage(ImageConfiguration(), "lib/img/camion.png")
        .then((icon) => southeastMarker = icon);
    BitmapDescriptor.fromAssetImage(ImageConfiguration(), "lib/img/camion.png")
        .then((icon) => southwestMarker = icon);
    BitmapDescriptor.fromAssetImage(ImageConfiguration(), "lib/img/camion.png")
        .then((icon) => eastMarker = icon);
    BitmapDescriptor.fromAssetImage(ImageConfiguration(), "lib/img/camion.png")
        .then((icon) => westMarker = icon);
    rootBundle.loadString('lib/assets/mapastyle14.json').then((string) {
      _mapStyle = string;
    });
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      cargarCamiones().then((camiones) => setState(() {
            camionesmostrar = camiones;
          }));
    });
    checardatos();
    iniciarLocalizacion();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) async {
      Provider.of<MarkerProvider>(context, listen: false)
          .updateMarkers(await _getMarkers());
    });
  }

  void checardatos() async {
    if (currentuser != null) {
      DocumentSnapshot documentSnapshot = await users.doc(currentuser!.uid).get();
      if (documentSnapshot.exists) {
        datos = documentSnapshot.data() as Map<String, dynamic>;
      }
    }
  }

  Future<Set<Marker>> _getMarkers() async {
    _compassSubscription = FlutterCompass.events!.listen((CompassEvent event) {
      if (this.mounted) {
        setState(() {
          _direction = event.heading;
        });
      }
    });
    String url;
    String? filtroaplicadotipo =
        Provider.of<MarkerProvider>(context, listen: false)
            .filtroaplicadorealizado;
    String? filtroaplicado =
        Provider.of<MarkerProvider>(context, listen: false).filtroaplicado;
    camionfiltradorealizado =
        Provider.of<MarkerProvider>(context, listen: false).filtroaplicado;
    camionfiltradotiporealizado =
        Provider.of<MarkerProvider>(context, listen: false)
            .filtroaplicadorealizado;
    if (filtroaplicado == null && filtroaplicadotipo == null) {
      url = "https://chaosqrz.pythonanywhere.com/obtener_ubicacion";
    } else if (filtroaplicado != null) {
      url =
          "https://chaosqrz.pythonanywhere.com/obtener_ubicacion/$filtroaplicado";
    } else if (filtroaplicadotipo != null) {
      url =
          "https://chaosqrz.pythonanywhere.com/obtener_ubicacion_tipo/$filtroaplicadotipo";
    } else {
      url = "";
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
  BitmapDescriptor markerIcon1 = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'lib/img/camion11.png');
  BitmapDescriptor markerIcon11 = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'lib/img/camion1.png');

    return (localizaciones as Map<String, dynamic>).entries.map((entry) {
      var latitudLng = LatLng(entry.value['localizacion']['lat'] ?? 0.0,
          entry.value['localizacion']['lng'] ?? 0);
      double newDireccion = entry.value['Direccion'];

      markerDirecciones[entry.key] = newDireccion;

      return Marker(
        markerId: MarkerId(entry.key),
        position: latitudLng,
        infoWindow: InfoWindow(title: entry.key),
        icon: /* markerDirecciones[entry.key]! >= 0 &&
                markerDirecciones[entry.key]! < 45
            ? northeastMarker ?? markerIcon
            : markerDirecciones[entry.key]! >= 45 &&
                    markerDirecciones[entry.key]! < 90
                ? eastMarker ?? markerIcon
                : markerDirecciones[entry.key]! >= 90 &&
                        markerDirecciones[entry.key]! < 135
                    ? southeastMarker ?? markerIcon
                    : markerDirecciones[entry.key]! >= 135 &&
                            markerDirecciones[entry.key]! < 180
                        ? southMarker ?? markerIcon
                        : markerDirecciones[entry.key]! >= 180 &&
                                markerDirecciones[entry.key]! < 225
                            ? southwestMarker ?? markerIcon
                            : markerDirecciones[entry.key]! >= 225 &&
                                    markerDirecciones[entry.key]! < 270
                                ? westMarker ?? markerIcon
                                : northwestMarker ?? markerIcon, */
        entry.value['Tipo'] == "MeMuevo"
            ? markerIcon
            : entry.value['Tipo'] == "Transmetro"
                ? markerIcon1
                : entry.value['Tipo'] == "Ecovia"
                    ? markerIcon11
                    : markerIcon,
        rotation: markerDirecciones[entry.key] ?? 0,
      );
    }).toSet();
  }

  Future<Set<Marker>> _createMarkersFromdata(Map<String, dynamic> data) async {
    final markerIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), "lib/img/camion.png");
    return data.entries.map((entry) {
      var latitudlng = LatLng(entry.value['localizacion']['lat'],
          entry.value['localizacion']['lng']);
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
        String direccion11 = '';
        try {
          var response = await http.get(Uri.parse(
              'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=AIzaSyAw2XSrncREAXbnAWDN_eHfesp_5YmvVsM'));

          if (response.statusCode == 200) {
            var data = jsonDecode(response.body);
            var results = data['results'];
            if (results.isNotEmpty) {
              var addressComponents = results[0]['address_components'];
              String route = '';
              String locality = '';
              String streetNumber = '';

              for (var component in addressComponents) {
                var types = component['types'];
                if (types.contains('route')) {
                  route = component['long_name'];
                } else if (types.contains('locality')) {
                  locality = component['long_name'];
                } else if (types.contains('street_number')) {
                  streetNumber = component['long_name'];
                }
              }

              direccion11 = '$streetNumber, $route, $locality';

            }
          } else {
            print("No se pudo obtener la dirección");
          }
        } catch (e) {
          print("Error al obtener la dirección: $e");
        }

        enviarLocalizacion(currentuser!.uid, direccion11, Provider.of<MarkerProvider>(context, listen: false).datosfirestore, position, _direction);
        CompassEvent? compassEvent = await FlutterCompass.events?.first;
        double? direction = compassEvent != null ? compassEvent.heading : null;

        BitmapDescriptor markerIcon = await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(), 'lib/img/camion.png');
        BitmapDescriptor markerIcon1 = await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(), 'lib/img/camion11.png');
        BitmapDescriptor markerIcon11 = await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(), 'lib/img/camion1.png');

        Provider.of<MarkerProvider>(context, listen: false).setdatosdispositivo(LatLng(position.latitude, position.longitude));

        Marker marker = Marker(
            markerId: MarkerId('device_location'),
            position: LatLng(position.latitude, position.longitude),
            infoWindow: InfoWindow(title: 'Mi ubicacion'),
            icon: datos['tipo_camion'] == "MeMuevo" ? markerIcon : datos['tipo_camion'] == "Transmetro" ? markerIcon1 : datos['tipo_camion'] == "Ecovia" ? markerIcon11 : markerIcon,
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

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    MarkerProvider markerProvider = Provider.of<MarkerProvider>(context);
    bool _botonmostrar = markerProvider.botonmostrar;
    int? totalcamionesrealizado =
        Provider.of<MarkerProvider>(context, listen: false).markers.length;
    Marker? deviceMarker1 = _markers.firstWhere(
      (marker) => marker.markerId == MarkerId('device_location'),
    );
    LatLng rastreo;
    if (deviceMarker1 != null) {
      rastreo = deviceMarker1.position ?? LatLng(0, 0);
    } else {
      rastreo = LatLng(0, 0);
    }
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
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
                myLocationButtonEnabled: false,
                rotateGesturesEnabled: false,
                mapToolbarEnabled: false,
                myLocationEnabled: markerProvider.datosfirestore["tipo_user"] == "camion" ? false : true,
                markers: Provider.of<MarkerProvider>(context).markers,
              ),
              Container(
                child: markerProvider.filtroChecar == null
                    ? Center(child: CircularProgressIndicator())
                    : markerProvider.filtroChecar
                        ? Stack(
                            alignment: AlignmentDirectional.bottomCenter,
                            children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 49, 0, 0),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Container(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          shape: CircleBorder(),
                                          padding: EdgeInsets.all(21.0),
                                          backgroundColor: Colors.orange,
                                        ),
                                        child: Icon(
                                          Icons.arrow_back,
                                          color: Colors.white70,
                                          size: 31,
                                        ),
                                        onPressed: () {
                                          markerProvider.quitarFiltro();
                                          setState(() {
                                            _opacidadfiltrar =
                                                _opacidadfiltrar == 1 ? 1 : 1;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 0, 15, 31),
                                  child: Container(
                                    alignment: Alignment.bottomCenter,
                                    height:
                                        MediaQuery.of(context).size.height / 4.5,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(40),
                                            bottom: Radius.circular(40)),
                                        color: Colors.orange),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 15, 0, 0),
                                          child: Container(
                                            height: 5,
                                            width: 140,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(50)),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              17, 21, 10, 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    height: 31,
                                                    width: 49,
                                                    decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                              top:
                                                                  Radius.circular(
                                                                      9),
                                                              bottom:
                                                                  Radius.circular(
                                                                      9)),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                          camionfiltradorealizado!
                                                              .substring(0, 3),
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w800,
                                                          )),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 9),
                                                  Icon(
                                                    Icons.directions_bus,
                                                    color: Colors.white,
                                                    size: 19,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.fromLTRB(
                                                            11, 0, 0, 0),
                                                    child: Text(
                                                      camionfiltradorealizado!
                                                          .substring(6),
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w800),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.fromLTRB(
                                                            25, 0, 0, 0),
                                                    child: Icon(
                                                      Icons.arrow_forward,
                                                      color: Colors.white,
                                                      size: 19,
                                                    ),
                                                  ),
                                                  Container(
                                                    width: 35,
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Center(
                                                      child: Text(
                                                          totalcamionesrealizado
                                                              .toString(),
                                                          style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800)),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ])
                        : markerProvider.filtroTipo
                            ? Stack(
                                alignment: AlignmentDirectional.bottomCenter,
                                children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(15, 49, 0, 0),
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Container(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              shape: CircleBorder(),
                                              padding: EdgeInsets.all(21.0),
                                              backgroundColor: Colors.orange,
                                            ),
                                            child: Icon(
                                              Icons.arrow_back,
                                              color: Colors.white70,
                                              size: 31,
                                            ),
                                            onPressed: () {
                                              markerProvider.quitarFiltro();
                                              setState(() {
                                                _opacidadfiltrar =
                                                    _opacidadfiltrar == 1 ? 1 : 1;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          15, 0, 15, 31),
                                      child: Container(
                                        alignment: Alignment.bottomCenter,
                                        height:
                                            MediaQuery.of(context).size.height /
                                                4.5,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(40),
                                                bottom: Radius.circular(40)),
                                            color: markerProvider
                                                        .filtroaplicadorealizado ==
                                                    'MeMuevo'
                                                ? Colors.green
                                                : markerProvider
                                                            .filtroaplicadorealizado ==
                                                        'Transmetro'
                                                    ? Colors.blueAccent
                                                    : markerProvider
                                                                .filtroaplicadorealizado ==
                                                            'Ecovia'
                                                        ? Colors.lightGreen
                                                        : markerProvider
                                                                    .filtroaplicadorealizado ==
                                                                'UANL'
                                                            ? Colors.blueAccent
                                                            : Colors.orange),
                                        child: Column(
                                          children: [
                                            Stack(
                                              clipBehavior: Clip.none,
                                              children: [
                                                Positioned(
                                                  top: markerProvider
                                                              .filtroaplicadorealizado ==
                                                          'MeMuevo'
                                                      ? 11
                                                      : markerProvider
                                                                  .filtroaplicadorealizado ==
                                                              'Ecovia'
                                                          ? 17
                                                          : markerProvider
                                                                      .filtroaplicadorealizado ==
                                                                  'Transmetro'
                                                              ? -21
                                                              : markerProvider
                                                                          .filtroaplicadorealizado ==
                                                                      'UANL'
                                                                  ? -7
                                                                  : 11,
                                                  right: markerProvider
                                                              .filtroaplicadorealizado ==
                                                          'MeMuevo'
                                                      ? 15
                                                      : markerProvider
                                                                  .filtroaplicadorealizado ==
                                                              'Ecovia'
                                                          ? -131
                                                          : markerProvider
                                                                      .filtroaplicadorealizado ==
                                                                  'Transmetro'
                                                              ? -17
                                                              : markerProvider
                                                                          .filtroaplicadorealizado ==
                                                                      'UANL'
                                                                  ? -55
                                                                  : 21,
                                                  child: Image.asset(
                                                      markerProvider
                                                                  .filtroaplicadorealizado ==
                                                              'MeMuevo'
                                                          ? "lib/img/logo.png"
                                                          : markerProvider
                                                                      .filtroaplicadorealizado ==
                                                                  'Ecovia'
                                                              ? "lib/img/ecovialogo.png"
                                                              : markerProvider
                                                                          .filtroaplicadorealizado ==
                                                                      'Transmetro'
                                                                  ? "lib/img/transmetrologo.png"
                                                                  : markerProvider
                                                                              .filtroaplicadorealizado ==
                                                                          'UANL'
                                                                      ? "lib/img/logouanl.png"
                                                                      : "lib/img/logo.png",
                                                      opacity: markerProvider
                                                                      .filtroaplicadorealizado !=
                                                                  'MeMuevo' &&
                                                              markerProvider
                                                                      .filtroaplicadorealizado !=
                                                                  'UANL'
                                                          ? AlwaysStoppedAnimation(
                                                              0.29)
                                                          : null,
                                                      color: markerProvider
                                                                  .filtroaplicadorealizado ==
                                                              'MeMuevo'
                                                          ? Colors.yellow
                                                              .withOpacity(0.29)
                                                          : null),
                                                  height: markerProvider
                                                              .filtroaplicadorealizado ==
                                                          'MeMuevo'
                                                      ? 170
                                                      : markerProvider
                                                                  .filtroaplicadorealizado ==
                                                              'Ecovia'
                                                          ? 130
                                                          : markerProvider
                                                                      .filtroaplicadorealizado ==
                                                                  'Transmetro'
                                                              ? 240
                                                              : markerProvider
                                                                          .filtroaplicadorealizado ==
                                                                      'UANL'
                                                                  ? 190
                                                                  : 130,
                                                ),
                                                Positioned(
                                                  top: markerProvider
                                                              .filtroaplicadorealizado ==
                                                          'MeMuevo'
                                                      ? -60
                                                      : markerProvider
                                                                  .filtroaplicadorealizado ==
                                                              'Ecovia'
                                                          ? -90
                                                          : markerProvider
                                                                      .filtroaplicadorealizado ==
                                                                  'Transmetro'
                                                              ? -60
                                                              : markerProvider
                                                                          .filtroaplicadorealizado ==
                                                                      'UANL'
                                                                  ? -60
                                                                  : -60,
                                                  right: markerProvider
                                                              .filtroaplicadorealizado ==
                                                          'MeMuevo'
                                                      ? -12
                                                      : markerProvider
                                                                  .filtroaplicadorealizado ==
                                                              'Ecovia'
                                                          ? -30
                                                          : markerProvider
                                                                      .filtroaplicadorealizado ==
                                                                  'Transmetro'
                                                              ? -12
                                                              : markerProvider
                                                                          .filtroaplicadorealizado ==
                                                                      'UANL'
                                                                  ? -42
                                                                  : -22,
                                                  child: Image.asset(
                                                    markerProvider
                                                                .filtroaplicadorealizado ==
                                                            'MeMuevo'
                                                        ? "lib/img/camionicon.png"
                                                        : markerProvider
                                                                    .filtroaplicadorealizado ==
                                                                'Ecovia'
                                                            ? "lib/img/busicon.png"
                                                            : markerProvider
                                                                        .filtroaplicadorealizado ==
                                                                    'Transmetro'
                                                                ? "lib/img/transmetrocamion.png"
                                                                : markerProvider
                                                                            .filtroaplicadorealizado ==
                                                                        'UANL'
                                                                    ? "lib/img/transmetrocamion.png"
                                                                    : "lib/img/camionicon.png",
                                                    height: markerProvider
                                                                .filtroaplicadorealizado ==
                                                            'MeMuevo'
                                                        ? 105
                                                        : markerProvider
                                                                    .filtroaplicadorealizado ==
                                                                'Ecovia'
                                                            ? 170
                                                            : markerProvider
                                                                        .filtroaplicadorealizado ==
                                                                    'Transmetro'
                                                                ? 105
                                                                : markerProvider
                                                                            .filtroaplicadorealizado ==
                                                                        'UANL'
                                                                    ? 105
                                                                    : 115,
                                                    opacity:
                                                        AlwaysStoppedAnimation(
                                                            .8),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          0, 65, 0, 0),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                          camionfiltradotiporealizado!
                                                              .substring(0),
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w900,
                                                            fontSize: 24,
                                                            letterSpacing: 4.0,
                                                          )),
                                                      Text(
                                                          totalcamionesrealizado
                                                              .toString(),
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w900,
                                                            fontSize: 24,
                                                            letterSpacing: 4.0,
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ])
                            : Container(
                                padding:
                                    const EdgeInsets.fromLTRB(17, 10, 17, 10),
                                child: Center(
                                  child: Column(
                                    children: [
                                      SizedBox(height: 40.0),
                                      SizedBox(height: 7),
                                      Stack(children: [
                                        AnimatedOpacity(
                                          opacity: markerProvider.filtroChecar ||
                                                  markerProvider.filtroTipo
                                              ? 0
                                              : 1,
                                          duration: Duration(seconds: 10),
                                          child: ElevatedButton(
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
                                                          fontSize: 19,
                                                          color: Colors.white54),
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
                                              getCamiones().then(
                                                  (camiones) => setState(() {
                                                        TodoslosCamiones =
                                                            camiones;
                                                      }));
                                              showModalBottomSheet(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  isScrollControlled: true,
                                                  context: context,
                                                  builder: (context) {
                                                    return Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(0, 100, 0, 0),
                                                      child: Container(
                                                          height: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .height,
                                                          child: MyButton(
                                                              TodoslosCamiones:
                                                                  TodoslosCamiones)),
                                                    );
                                                  });
                                              //Navigator.of(context).push(
                                              //MaterialPageRoute(builder: (context) => MyButton()),
                                              //);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.orange,
                                              padding: EdgeInsets.fromLTRB(
                                                  17, 11, 17, 11),
                                            ),
                                          ),
                                        ),
                                      ]),
                                    ],
                                  ),
                                ),
                              ),
              ),
              markerProvider.filtroTipo || markerProvider.filtroChecar
                  ? Container()
                  : Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 35),
                        child: Container(
                          height: 57,
                          width: 311,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(40)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                width: 157,
                                height: 51,
                                decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(40)),
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ButtonStyle(
                                      elevation: MaterialStatePropertyAll(0),
                                      backgroundColor: _botonmostrar
                                          ? MaterialStatePropertyAll(Colors.white)
                                          : MaterialStatePropertyAll(
                                              Colors.orange)),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.near_me_outlined,
                                          color: _botonmostrar
                                              ? Colors.grey
                                              : Colors.white,
                                        ),
                                        Text(_botonmostrar ? "" : "Cerca de ti",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 17,
                                                color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 140,
                                height: 51,
                                decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(40)),
                                child: ElevatedButton(
                                  onPressed: botoncamionrealizado
                                      ? null
                                      : () {
                                          setState(() {
                                            botoncamionrealizado = true;
                                          });
                                          Provider.of<MarkerProvider>(context,
                                                  listen: false)
                                              .botonmostrar = true;
                                          final controllermodal =
                                              showCupertinoModalPopup(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(0, 0, 0, 0),
                                                      child: Container(
                                                        height:
                                                            MediaQuery.of(context)
                                                                .size
                                                                .height,
                                                        child: camionscreenrealizado(
                                                            mapcontrollerrealizado:
                                                                mapController,
                                                            camionesmostrar:
                                                                camionesmostrar),
                                                      ),
                                                    );
                                                  });
                                          controllermodal.then((_) {
                                            Provider.of<MarkerProvider>(context,
                                                    listen: false)
                                                .botonmostrar = false;
                                            setState(() {
                                              botoncamionrealizado = false;
                                            });
                                          });
                                        },
                                  style: ButtonStyle(
                                      elevation: MaterialStatePropertyAll(0),
                                      backgroundColor: _botonmostrar
                                          ? MaterialStatePropertyAll(
                                              Colors.orange)
                                          : MaterialStatePropertyAll(
                                              Colors.white)),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.polyline_outlined,
                                          color: _botonmostrar
                                              ? Colors.white
                                              : Colors.grey,
                                        ),
                                        Text(_botonmostrar ? "Rutas" : "",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 17,
                                                color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
              Stack(children: [
                AnimatedPositioned(
                  right: 0,
                  bottom: markerProvider.filtroChecar || markerProvider.filtroTipo
                      ? 150
                      : 0,
                  duration: Duration(seconds: 1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(17, 0, 17, 0),
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
                        padding: const EdgeInsets.fromLTRB(10, 25, 10, 10),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(10),
                                backgroundColor: Colors.orange),
                            child: Icon(
                              Icons.person,
                              color: Colors.white70,
                              size: 49,
                            ),
                            onPressed: () {
                              Navigator.of(context).pushNamed('/configuracion');
                            },
                          ),
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
                                Marker? deviceMarker = _markers.firstWhere(
                                    (marker) =>
                                        marker.markerId ==
                                        MarkerId('device_location'));
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
                ),
              ]),
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
      ),
    );
  }

  @override
  void dispose() {
    FlutterCompass.events?.drain();
    _compassSubscription?.cancel();
    timer?.cancel();
    detenerLocalizacion(timer, positionStream);
    borrarubicacion();
    super.dispose();
  }
}
