import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
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

  @override
  Widget build(BuildContext context) {
    List camiones = widget.camionesmostrar.where((tipo) => tipo['Tipo'] == 'MeMuevo').toList();
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
                            width: _botoncamiones ? 72 : 140,
                            height: 51,
                            decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(40)),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _botoncamiones = false;
                                });
                              },
                              style: ButtonStyle(
                                  elevation: MaterialStatePropertyAll(0),
                                  backgroundColor: _botoncamiones
                                      ? MaterialStatePropertyAll(Colors.white)
                                      : MaterialStatePropertyAll(
                                          Colors.orange)),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.directions_bus,
                                      color: _botoncamiones
                                          ? Colors.grey
                                          : Colors.white,
                                    ),
                                    Text(_botoncamiones ? "" : "MeMuevo",
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
                            width: _botoncamiones == false ? 72 : 152,
                            height: 51,
                            decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(40)),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _botoncamiones = true;
                                });
                              },
                              style: ButtonStyle(
                                  elevation: MaterialStatePropertyAll(0),
                                  backgroundColor: _botoncamiones == false
                                      ? MaterialStatePropertyAll(Colors.white)
                                      : MaterialStatePropertyAll(
                                          Colors.orange)),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.directions_bus_outlined,
                                      color: _botoncamiones == false
                                          ? Colors.grey
                                          : Colors.white,
                                    ),
                                    Text(
                                        _botoncamiones == false
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                  child: _botoncamiones
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(22, 10, 22, 10),
                          child: Container(
                            height:
                                MediaQuery.of(context).size.height / 2 + 115,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25)),
                            child: ListView.builder(
                                itemCount: camiones1.length,
                                itemBuilder: (context, index) {
                                  var camion = camiones1[index];
                                  Provider.of<MarkerProvider>(context,
                                              listen: false)
                                          .cantidadcamionesrealizado =
                                      camiones1.length;
                                  var numerocamion = index + 1;
                                  return CardCamion(
                                      mapcontrollerrealizado:
                                          widget.mapcontrollerrealizado,
                                      camion: camion,
                                      numerocamion: numerocamion);
                                }),
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
                            child: ListView.builder(
                                itemCount: camiones.length,
                                itemBuilder: (context, index) {
                                  var camion = camiones[index];
                                  Provider.of<MarkerProvider>(context,
                                              listen: false)
                                          .cantidadcamionesrealizado =
                                      camiones.length;
                                  var numerocamion = index + 1;
                                  return CardCamion(
                                      mapcontrollerrealizado:
                                          widget.mapcontrollerrealizado,
                                      camion: camion,
                                      numerocamion: numerocamion);
                                }),
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

class CardCamion extends StatelessWidget {
  final Map<String, dynamic> camion;
  final GoogleMapController? mapcontrollerrealizado;
  final int numerocamion;

  CardCamion(
      {required this.mapcontrollerrealizado,
      required this.camion,
      required this.numerocamion});

  @override
  Widget build(BuildContext context) {
    MarkerProvider markerProvider = Provider.of<MarkerProvider>(context);
    String camionnombre = camion['Camion'];
    return Center(
      child: Card(
        color: Colors.white,
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
                    child: Text(numerocamion.toString(),
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
                  Provider.of<MarkerProvider>(context, listen: false)
                      .setbotoncardrealizado(numerocamion,
                          !markerProvider.getbotoncardrealizado(numerocamion));
                },
                child: Icon(
                  markerProvider.getbotoncardrealizado(numerocamion)
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
                height: markerProvider.getbotoncardrealizado(numerocamion)
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
                            Text("Guadalupe",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 9),
                        Row(
                          children: [
                            Icon(Icons.location_city_rounded,
                                color: Colors.grey),
                            const SizedBox(width: 8),
                            Text("Guadalupe",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 9),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                color: Colors.grey),
                            const SizedBox(width: 8),
                            Text("Guadalupe",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 5),
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
                            child: const Text('Filtrar',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white)),
                            onPressed: () {
                              mapcontrollerrealizado!
                                  .animateCamera(CameraUpdate.newCameraPosition(
                                CameraPosition(
                                  target: LatLng(camion['localizacion']['lat'],
                                      camion['localizacion']['lng']),
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
