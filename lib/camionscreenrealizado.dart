import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'marker_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class camionscreenrealizado extends StatefulWidget {
  final List<Map<String, dynamic>> camionesmostrar;
  final GoogleMapController? mapcontrollerrealizado;

  camionscreenrealizado(
      {required this.mapcontrollerrealizado, required this.camionesmostrar});

  @override
  _camionrealizado createState() => _camionrealizado();
}

class _camionrealizado extends State<camionscreenrealizado> {

  bool _botoncamiones = false;
  bool _botoncamiones1 = false;
  Timer? timer;
  bool firstTime = true;
  bool firstTime1 = true;
  MarkerProvider markerProviderCamion = MarkerProvider();
  MarkerProvider markerProviderCamion11 = MarkerProvider();
  MarkerProvider markerProviderCamion1 = MarkerProvider();

  @override
  void initState() {
    super.initState();
    MarkerProvider markerProvider = Provider.of<MarkerProvider>(context, listen: false);
    timer = Timer.periodic(Duration(seconds: 5), (Timer t) {
      for (var camion in widget.camionesmostrar) {
        markerProvider.arrivalTime[camion['IdCamion']] =
            calculateArrivalTimes(camion);
        markerProvider.locationName[camion['IdCamion']] =
            getLocationName(camion);
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<String> calculateArrivalTimes(Map<String, dynamic> camion) async {
   MarkerProvider markerProvider = Provider.of<MarkerProvider>(context, listen: false);
    LatLng currentLocation = markerProvider.datosdispositivo;
    if (currentLocation == null) {
      return "No se pudo obtener la ubicación";
    }
   /*

    try {
      currentLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } on Exception {
      print('No se pudo obtener la ubicación');
      return "Error al obtener la ubicación";
    } */

    var response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=${camion['localizacion']['lat']},${camion['localizacion']['lng']}&destination=${currentLocation.latitude},${currentLocation.longitude}&key=AIzaSyAw2XSrncREAXbnAWDN_eHfesp_5YmvVsM'));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var routes = data['routes'];
      if (routes.isNotEmpty) {
        var legs = routes[0]['legs'];
        if (legs.isNotEmpty) {
          var duration = legs[0]['duration'];
          if (firstTime) {
            firstTime = false;
            return "....";
          }
          return duration['text'];
        }
      }
    } else {
      print("No se pudo obtener la duración del viaje");
      return "Error al obtener la duración del viaje";
    }
    return "No se pudo obtener la duración del viaje";
}

  Future<String> getLocationName(Map<String, dynamic> camion) async {
    try {
      var response = await http.get(Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=${camion['localizacion']['lat']},${camion['localizacion']['lng']}&key=AIzaSyAw2XSrncREAXbnAWDN_eHfesp_5YmvVsM'));

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

          if (firstTime1) {
            firstTime1 = false;
            return "....";
          }

          return '$streetNumber,\n $route,\n $locality';

        }
      } else {
        print("No se pudo obtener la dirección");
        return "Error al obtener la dirección";
      }
    } catch (e) {
      print("Error al obtener la dirección: $e");
      return "Error al obtener la dirección";
    }
    return "No se pudo obtener la dirección";
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp, DeviceOrientation.portraitDown
    ]);

    List camiones = widget.camionesmostrar.where((tipo) => tipo['Tipo'] == 'MeMuevo').toList();
    List camiones11 = widget.camionesmostrar.where((tipo) => tipo['Tipo'] == 'Ecovia').toList();
    List camiones1 = widget.camionesmostrar.where((tipo) => tipo['Tipo'] == 'Transmetro').toList();
    bool _botonmostrar =
        Provider.of<MarkerProvider>(context, listen: false).botonmostrar;
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 207, 164, 1),
      body: SafeArea(
        child: Container(
          color: Color.fromRGBO(255, 226, 200, 1),
          child: Column(
            children: [
              Container(
                color: Color.fromRGBO(255, 207, 164, 1),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(21, 21, 21, 21),
                  child: Container(
                    height: 60,
                    width: 390,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.7),
                              spreadRadius: 4,
                              blurRadius: 9,
                              offset: Offset(0, 1))
                        ]),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                      child: Row(
                        children: [
                          Container(
                            width: _botoncamiones || _botoncamiones1 ? 72 : 140,
                            height: 51,
                            decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(40)),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _botoncamiones = false;
                                  _botoncamiones1 = false;
                                });
                              },
                              style: ButtonStyle(
                                  elevation: MaterialStatePropertyAll(0),
                                  backgroundColor: _botoncamiones || _botoncamiones1
                                      ? MaterialStatePropertyAll(Colors.white)
                                      : MaterialStatePropertyAll(
                                          Colors.orange)),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.directions_bus,
                                      color: _botoncamiones || _botoncamiones1
                                          ? Colors.grey
                                          : Colors.white,
                                    ),
                                    Text(_botoncamiones || _botoncamiones1 ? "" : "MeMuevo",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                            color: Colors.white)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 4)),
                          Container(
                            width: _botoncamiones == false || _botoncamiones1 ? 72 : 152,
                            height: 51,
                            decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(40)),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _botoncamiones = true;
                                  _botoncamiones1 = false;
                                });
                              },
                              style: ButtonStyle(
                                  elevation: MaterialStatePropertyAll(0),
                                  backgroundColor: _botoncamiones == false || _botoncamiones1
                                      ? MaterialStatePropertyAll(Colors.white)
                                      : MaterialStatePropertyAll(
                                          Colors.orange)),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.directions_bus_outlined,
                                      color: _botoncamiones == false || _botoncamiones1
                                          ? Colors.grey
                                          : Colors.white,
                                    ),
                                    Text(
                                        _botoncamiones == false || _botoncamiones1
                                            ? ""
                                            : "Transmetro",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                            color: Colors.white))
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 4)),
                          Container(
                            width: _botoncamiones1 ? 141 : 72,
                            height: 51,
                            decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(40)),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _botoncamiones = false;
                                  _botoncamiones1 = true;
                                });
                              },
                              style: ButtonStyle(
                                  elevation: MaterialStatePropertyAll(0),
                                  backgroundColor: _botoncamiones1 == false
                                      ? MaterialStatePropertyAll(Colors.white)
                                      : MaterialStatePropertyAll(
                                          Colors.orange)),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.directions_bus_rounded,
                                      color: _botoncamiones1 == false
                                          ? Colors.grey
                                          : Colors.white,
                                    ),
                                    Text(
                                        _botoncamiones1
                                            ? "Ecovia"
                                            : "",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                            color: Colors.white))
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
              ),
              Container(
                  child: _botoncamiones1
                      ? Padding(
                    padding: const EdgeInsets.fromLTRB(22, 10, 22, 10),
                    child: Container(
                      height:
                      MediaQuery.of(context).size.height / 2 + 115,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25)),
                      child: camiones11.length >= 1 ? ListView.builder(
                          itemCount: camiones11.length,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                                        Provider.of<MarkerProvider>(context,
                                                    listen: false)
                                                .cantidadcamionesrealizado =
                                            camiones11.length;
                                      }
                            var camion = camiones11[index];
                            var numerocamion = index + 1;
                            return CardCamion(
                                mapcontrollerrealizado:
                                widget.mapcontrollerrealizado,
                                camion: camion,
                                numerocamion: numerocamion, markerProvider: markerProviderCamion11);
                          }) : Center(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 50, color: Colors.red),
                          Text("No hay camiones de Ecovia", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04, fontWeight: FontWeight.w800),)
                        ],
                      )),
                    ),
                  )
                      : _botoncamiones
                      ? Padding(
                        padding: const EdgeInsets.fromLTRB(22, 10, 22, 10),
                        child: Container(
                          height:
                          MediaQuery.of(context).size.height / 2 + 115,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25)),
                          child: camiones1.length >= 1 ? ListView.builder(
                              itemCount: camiones1.length,
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  Provider.of<MarkerProvider>(context,
                                              listen: false)
                                          .cantidadcamionesrealizado =
                                      camiones1.length;
                                }
                                var camion = camiones1[index];
                                var numerocamion = index + 1;
                                return CardCamion(
                                    mapcontrollerrealizado:
                                    widget.mapcontrollerrealizado,
                                    camion: camion,
                                    numerocamion: numerocamion, markerProvider: markerProviderCamion1);
                              }) : Center(child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 50, color: Colors.red),
                              Text("No hay camiones de Transmetro", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04, fontWeight: FontWeight.w800),)
                            ],
                          )),
                        ),
                      )
                      : Padding(
                          padding: const EdgeInsets.fromLTRB(22, 10, 22, 10),
                          child: Container(
                            height:
                                MediaQuery.of(context).size.height / 2 + 115,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25)),
                            child: camiones.length >= 1 ? ListView.builder(
                                itemCount: camiones.length,
                                itemBuilder: (context, index) {
                                  if (index == 0) {
                                    Provider.of<MarkerProvider>(context,
                                                listen: false)
                                            .cantidadcamionesrealizado =
                                        camiones.length;
                                  }
                                  var camion = camiones[index];
                                  var numerocamion = index + 1;
                                  return CardCamion(
                                      mapcontrollerrealizado:
                                          widget.mapcontrollerrealizado,
                                      camion: camion,
                                      numerocamion: numerocamion, markerProvider: markerProviderCamion);
                                }) : Center(child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.error_outline, size: 50, color: Colors.red),
                                          Text("No hay camiones de MeMuevo", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04, fontWeight: FontWeight.w800),)
                                        ],
                                      )),
                          ),
                        )
              ),
              Expanded(
                child: Align(
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
                              onPressed: () {
                                Provider.of<MarkerProvider>(context,
                                        listen: false)
                                    .botonmostrar = false;
                                Navigator.of(context).pop();
                              },
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
                              onPressed: () {},
                              style: ButtonStyle(
                                  backgroundColor: _botonmostrar
                                      ? MaterialStatePropertyAll(Colors.orange)
                                      : MaterialStatePropertyAll(Colors.white)),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CardCamion extends StatefulWidget {
  final Map<String, dynamic> camion;
  final GoogleMapController? mapcontrollerrealizado;
  final int numerocamion;
  final MarkerProvider markerProvider;

  CardCamion(
      {
        required this.mapcontrollerrealizado,
        required this.camion,
        required this.numerocamion,
        required this.markerProvider,
      }
  );

  @override
  _CardCamionState createState() => _CardCamionState();
}

class _CardCamionState extends State<CardCamion> {
 // late Future<String> arrivalTimeFuture = Future.value("....");
//  late Future<String> locationNameFuture = Future.value("....");
  Timer? timer;
  bool firstTime = true;
  bool firstTime1 = true;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 5), (Timer t) {
      if (mounted) {
        setState(() {
         // arrivalTimeFuture = calculateArrivalTimes();
         // locationNameFuture = getLocationName();
        });
      }
    });

  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<String> calculateArrivalTimes() async {
   MarkerProvider markerProvider = Provider.of<MarkerProvider>(context, listen: false);
    LatLng currentLocation = markerProvider.datosdispositivo;
    if (currentLocation == null) {
      return "No se pudo obtener la ubicación";
    }
   /*

    try {
      currentLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } on Exception {
      print('No se pudo obtener la ubicación');
      return "Error al obtener la ubicación";
    } */

    var response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=${widget.camion['localizacion']['lat']},${widget.camion['localizacion']['lng']}&destination=${currentLocation.latitude},${currentLocation.longitude}&key=AIzaSyAw2XSrncREAXbnAWDN_eHfesp_5YmvVsM'));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var routes = data['routes'];
      if (routes.isNotEmpty) {
        var legs = routes[0]['legs'];
        if (legs.isNotEmpty) {
          var duration = legs[0]['duration'];
          if (firstTime) {
            firstTime = false;
            return "....";
          }
          return duration['text'];
        }
      }
    } else {
      print("No se pudo obtener la duración del viaje");
      return "Error al obtener la duración del viaje";
    }
    return "No se pudo obtener la duración del viaje";
}

  Future<String> getLocationName() async {
    try {
      var response = await http.get(Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=${widget.camion['localizacion']['lat']},${widget.camion['localizacion']['lng']}&key=AIzaSyAw2XSrncREAXbnAWDN_eHfesp_5YmvVsM'));

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

          if (firstTime1) {
            firstTime1 = false;
            return "....";
          }

          return '$streetNumber,\n $route,\n $locality';

        }
      } else {
        print("No se pudo obtener la dirección");
        return "Error al obtener la dirección";
      }
    } catch (e) {
      print("Error al obtener la dirección: $e");
      return "Error al obtener la dirección";
    }
    return "No se pudo obtener la dirección";
  }

  @override
  Widget build(BuildContext context) {

    MarkerProvider markerProvider = widget.markerProvider;
    MarkerProvider markerProvider1 = Provider.of<MarkerProvider>(context);
    String camionnombre = widget.camion['Camion'];
    String camionId = widget.camion['IdCamion'];
    Future<String> arrivalTimeFuture = markerProvider1.arrivalTime[camionId] ?? Future.value("....");
    Future<String> locationNameFuture = markerProvider1.locationName[camionId] ?? Future.value("....");
    List<String> partes = widget.camion['Lugar'].split(", ");
    return Center(
      child: Card(
        color: Colors.transparent,
        elevation: 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Container(
                height: 35,
                width: 30,
                decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(14)),
                child: Center(
                    child: Text(widget.numerocamion.toString(),
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15))),
              ),
              title: Text(
                "\tRuta " + camionnombre.substring(0, 3),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              trailing: TextButton(
                style: ButtonStyle(
                  elevation: MaterialStatePropertyAll(0),
                  backgroundColor: MaterialStatePropertyAll(Colors.transparent),
                ),
                onPressed: () {
                  setState((){
                    widget.markerProvider
                        .setbotoncardrealizado(
                            widget.numerocamion,
                            !widget.markerProvider
                                .getbotoncardrealizado(widget.numerocamion));
                  });
                },
                child: Icon(
                  markerProvider.getbotoncardrealizado(widget.numerocamion)
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_up,
                  size: 40,
                ),
              ),
              subtitle: Row(
                children: [
                  Icon(Icons.arrow_right_alt_rounded, size: 17),
                  Text(
                    camionnombre.substring(5),
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
                duration: Duration(milliseconds: 11),
                height: markerProvider.getbotoncardrealizado(widget.numerocamion)
                    ? 115.0
                    : 0.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.access_time, color: Colors.grey),
                            const SizedBox(width: 8),
                            FutureBuilder<String>(
                                future: arrivalTimeFuture,
                                builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Text("....", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.03, color: Colors.grey));
                                  } else if (snapshot.hasError) {
                                    return Text("Error al calcular", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.03, color: Colors.grey));
                                  } else {
                                    return Text(textAlign: TextAlign.start, snapshot.data ?? "Calculando....", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.03, color: Colors.grey));
                                  }
                                }
                            ),
                          ],
                        ),
                        const SizedBox(height: 9),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                color: Colors.grey),
                            const SizedBox(width: 8),
                            /*RichText(text: TextSpan(
                                text: partes[0] + ",\n",
                                style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.029, color: Colors.grey),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: partes[1] + ",\n",
                                      style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.029, color: Colors.grey)),
                                  TextSpan(
                                      text: partes[2],
                                      style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.029, color: Colors.grey))
                                ]
                            )), */

                           FutureBuilder(
                                future: locationNameFuture,
                                builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Text(snapshot.data ?? "....", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.03, color: Colors.grey));
                                  } else if (snapshot.hasError) {
                                    return Text("Error al calcular", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.03, color: Colors.grey));
                                  } else {
                                    return Text(snapshot.data ?? "Calculando....", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.03, color: Colors.grey));
                                  }
                                }
                            ),
                          ],
                        ),
                        const SizedBox(height: 9),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        SizedBox(
                          height: 52,
                          width: 90,
                          child: TextButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(Colors.blueAccent),
                            ),
                            child: const Text('Mostrar\n ruta',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white)),
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 52,
                          width: 90,
                          child: TextButton(
                            style: ButtonStyle(
                              padding: MaterialStatePropertyAll(
                                  const EdgeInsets.all(10)),
                              backgroundColor:
                                  MaterialStatePropertyAll(Colors.blueAccent),
                            ),
                            child: const Text('Ubicar',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white)),
                            onPressed: () {
                              widget.mapcontrollerrealizado!
                                  .animateCamera(CameraUpdate.newCameraPosition(
                                CameraPosition(
                                  target: LatLng(widget.camion['localizacion']['lat'],
                                      widget.camion['localizacion']['lng']),
                                  zoom: 15,
                                ),
                              ));
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ],
                )),
            const SizedBox(height: 11),
            Divider(
              color: Colors.grey,
              thickness: 1.5,
              height: 0.0,
            ),
          ],
        ),
      ),
    );
  }
}
