import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'marker_provider.dart';
import 'http_service.dart';

class MyButton extends StatefulWidget {
  final List<String>? TodoslosCamiones;

  MyButton({this.TodoslosCamiones});

  @override
  _MyButtonState createState() => _MyButtonState();
}

class AutocompleteWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueNotifier<List<String>?> todoslosCamiones;
  AutocompleteWidget(
      {required this.controller, required this.todoslosCamiones});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<String>?>(
        valueListenable: todoslosCamiones,
        builder: (context, value, child) {
          return Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text == '' || value == null) {
                return const Iterable<String>.empty();
              }
              return value.where((String option) {
                return option.contains(textEditingValue.text.toLowerCase());
              });
            },
            fieldViewBuilder: (BuildContext context,
                TextEditingController controladorTexto,
                FocusNode nodoEnfoque,
                VoidCallback alEnviarCampo) {
              return TextFormField(
                controller: controladorTexto,
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.fromLTRB(0, 7, 0, 12),
                  labelText: controladorTexto.text.trim().isNotEmpty
                      ? null
                      : "Filtrar por nombre camion",
                  hintText: (nodoEnfoque.hasFocus &&
                          controladorTexto.text.trim().isEmpty)
                      ? "Escribir nombre del camion. "
                      : (nodoEnfoque.hasFocus == false &&
                              controladorTexto.text.trim().isEmpty)
                          ? "Escribir nombre del camion. "
                          : null,
                ),
                focusNode: nodoEnfoque,
                onChanged: (String texto) {
                  controladorTexto.text = texto;
                },
                onFieldSubmitted: (String seleccion) {
                  alEnviarCampo();
                  print("El valor ingresado es $seleccion");
                },
              );
            },
            // Quite el async del onselect
            onSelected: (String value) {
              controller.text = value;
            },
          );
        });
  }
}

class _MyButtonState extends State<MyButton> {
  String filter = '';
  bool _estacargando = false;
  bool _estacargandotipo = false;
  final _controller = TextEditingController();

  Future<void> handleSearch() async {
    String camion = _controller.text;

    setState(() {
      _estacargando = true;
      _estacargandotipo = true;
    });

    if (camion.isEmpty) {
      var alert = showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Campo vacio'),
              content: Text('Por favor, ingresa un valor valido.  '),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _estacargando = false;
                      _estacargandotipo = false;
                    });
                  },
                  child: Text('Ok'),
                ),
              ],
            );
          });

      alert.then((_) {
        setState(() {
          _estacargando = false;
          _estacargandotipo = false;
        });
      });

    }

    print('Has ingresado: $camion');

    var url = Uri.parse(
        "https://chaosqrz.pythonanywhere.com/obtener_ubicacion/$camion");
    var headers = {
      "Authorization": "Basic " +
          base64Encode(utf8.encode(
              "apprastreoadministracionproyectorealizado:PASSCODEFIMERASTREO14")),
    };
    var response = await http.get(url, headers: headers);
    var localizaciones = jsonDecode(response.body);

    Provider.of<MarkerProvider>(context, listen: false).filtroaplicado = camion;

    Navigator.of(context).pop();

    Provider.of<MarkerProvider>(context, listen: false).filtroChecar = true;

    if (localizaciones.isEmpty) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('No se encontraron camiones'),
              content:
                  Text('No se encontraron camiones con el nombre: $camion'),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _estacargando = false;
                        _estacargandotipo = false;
                      });
                    },
                    child: Text('Ok'))
              ],
            );
          });
    }
    setState(() {
      _estacargando = false;
      _estacargandotipo = false;

    });
  }

  Future<void> handleFilter(String camion1) async {

    String camion = camion1;

    setState(() {
      _estacargando = true;
      _estacargandotipo = true;
    });


    var url = Uri.parse(
        "https://chaosqrz.pythonanywhere.com/obtener_ubicacion_tipo/$camion");
    var headers = {
      "Authorization": "Basic " +
          base64Encode(utf8.encode(
              "apprastreoadministracionproyectorealizado:PASSCODEFIMERASTREO14")),
    };
    var response = await http.get(url, headers: headers);
    var localizaciones = jsonDecode(response.body);

    Provider.of<MarkerProvider>(context, listen: false).filtroaplicadorealizado = camion;

    Navigator.of(context).pop();

    Provider.of<MarkerProvider>(context, listen: false).filtroTipo = true;

    if (localizaciones.isEmpty) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('No se encontraron camiones'),
              content:
                  Text('No se encontraron camiones de este tipo: $camion'),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _estacargando = true;
                        _estacargandotipo = true;
                      });

                    },
                    child: Text('Ok'))
              ],
            );
          });
    }
    setState(() {
      _estacargando = true;
      _estacargandotipo = true;
    });

  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    ValueNotifier<List<String>?> todoslosCamionesNotifier =
        ValueNotifier<List<String>?>(widget.TodoslosCamiones);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Container(
                decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 207, 164, 1),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(40),
                      topLeft: Radius.circular(40),
                    )),
                height: 172,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  // Esto agrega un scroll a el filtro porque ocupa espacio entonces hay que salir del
                  // input para normal, pero si esta es pone un scroll ahi.
                  child: Column(
                      children: [
                        SizedBox(height: 15),
                        Container(
                          width: 200,
                          height: 10,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50)),
                          child: ElevatedButton(
                            child: Container(),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        SizedBox(height: 41),
                        Material(
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
                                    child: AutocompleteWidget(
                                        controller: _controller,
                                        todoslosCamiones:
                                        todoslosCamionesNotifier),
                                  ),
                                  IconButton(
                                      icon: _estacargando || _estacargandotipo
                                          ? CircularProgressIndicator()
                                          : Icon(Icons.search),
                                      onPressed: _estacargando || _estacargandotipo
                                          ? null
                                          : handleSearch),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                ),
              ),


            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 207, 164, 1),
                   ),
                height: 150,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 1, 10, 10),
                  // Esto agrega un scroll a el filtro porque ocupa espacio entonces hay que salir del
                  // input para normal, pero si esta es pone un scroll ahi.
                  child: SingleChildScrollView(
                    child: Column(
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height / 1.5,
                              decoration: BoxDecoration(
                                  color: Color.fromRGBO(255, 226, 200, 1),
                                  borderRadius: BorderRadius.circular(25)),
                              child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            11, 50, 15, 17),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Container(
                                              height: 150,
                                              width: 150,
                                              decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  borderRadius:
                                                      BorderRadius.circular(35)),
                                              child: ElevatedButton(
                                                style: ButtonStyle(
                                                  elevation:
                                                      MaterialStatePropertyAll(0),
                                                  backgroundColor:
                                                      MaterialStatePropertyAll(
                                                          Colors.green),
                                                ),
                                                child:
                                                Stack(
                                                  clipBehavior: Clip.none,
                                                  children: [
                                                    Positioned(
                                                      top: -51,
                                                      right: 11,
                                                      child: Image.asset(
                                                          "lib/img/logo.png",
                                                          color: Colors.yellow
                                                              .withOpacity(0.29)),
                                                      height: 130,
                                                    ),
                                                    Positioned(
                                                      top: -95,
                                                      right: -51,
                                                      child: Image.asset(
                                                        "lib/img/camionicon.png",
                                                        height: 85,
                                                        opacity:
                                                            AlwaysStoppedAnimation(
                                                                .8),
                                                      ),
                                                    ),
                                                    Text('MeMuevo',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          fontSize: 17,
                                                          letterSpacing: 2.0,
                                                        )),
                                                  ],
                                                ),
                                                onPressed: _estacargando || _estacargandotipo ? null : () {handleFilter("MeMuevo");},
                                              ),
                                            ),
                                            const SizedBox(width: 1),
                                            Container(
                                              height: 150,
                                              width: 150,
                                              decoration: BoxDecoration(
                                                  color: Colors.lightGreen,
                                                  borderRadius:
                                                      BorderRadius.circular(35)),
                                              child: ElevatedButton(
                                                style: ButtonStyle(
                                                  elevation:
                                                      MaterialStatePropertyAll(0),
                                                  backgroundColor:
                                                      MaterialStatePropertyAll(
                                                          Colors.lightGreen),
                                                ),
                                                child: Stack(
                                                  clipBehavior: Clip.none,
                                                  children: [
                                                    Positioned(
                                                      top: -15,
                                                      right: -15,
                                                      child: Image.asset(
                                                          "lib/img/ecovialogo.png",
                                                          opacity:
                                                              AlwaysStoppedAnimation(
                                                                  0.29)),
                                                      height: 45,
                                                    ),
                                                    Positioned(
                                                      top: -117,
                                                      right: -55,
                                                      child: Image.asset(
                                                        "lib/img/busicon.png",
                                                        height: 140,
                                                        opacity:
                                                            AlwaysStoppedAnimation(
                                                                0.8),
                                                      ),
                                                    ),
                                                    Text('Ecovia',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          fontSize: 19,
                                                          letterSpacing: 7.0,
                                                        )),
                                                  ],
                                                ),
                                                onPressed: _estacargando || _estacargandotipo ? null : () {handleFilter("Ecovia");},
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                                      Center(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              height: 150,
                                              width: 150,
                                              decoration: BoxDecoration(
                                                  color: Colors.blueAccent,
                                                  borderRadius:
                                                      BorderRadius.circular(35)),
                                              child: ElevatedButton(
                                                style: ButtonStyle(
                                                  elevation:
                                                      MaterialStatePropertyAll(0),
                                                  backgroundColor:
                                                      MaterialStatePropertyAll(
                                                          Colors.blueAccent),
                                                ),
                                                child: Stack(
                                                  clipBehavior: Clip.none,
                                                  children: [
                                                    Positioned(
                                                      top: -51,
                                                      right: -23,
                                                      child: Image.asset(
                                                          "lib/img/transmetrologo.png",
                                                          opacity:
                                                              AlwaysStoppedAnimation(
                                                                  0.29)),
                                                      height: 147,
                                                    ),
                                                    Positioned(
                                                      top: -105,
                                                      right: -25,
                                                      child: Image.asset(
                                                        "lib/img/transmetrocamion.png",
                                                        height: 90,
                                                        opacity:
                                                            AlwaysStoppedAnimation(
                                                                0.8),
                                                      ),
                                                    ),
                                                    Text('Transmetro',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          fontSize: 17,
                                                        )),
                                                  ],
                                                ),
                                                onPressed: _estacargando || _estacargandotipo ? null : () {handleFilter("Transmetro");},
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                            )
                          ],
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
