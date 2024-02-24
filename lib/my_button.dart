import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'marker_provider.dart';
import 'http_service.dart';

class MyButton extends StatefulWidget {
  @override
  _MyButtonState createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  String filter = '';
  bool _filtroAplicado = false;
  String _filtro = '';
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
                  // Add other widgets here...

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

                                              setState(() {
                                                _filtroAplicado = true;
                                                _filtro = _controller.text;
                                              });

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
