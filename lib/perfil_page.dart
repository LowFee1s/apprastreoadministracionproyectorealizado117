import 'package:apprastreoadministracionproyectorealizado/apis/cloud_servicios.dart';
import 'package:apprastreoadministracionproyectorealizado/location_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'location_screen.dart';
import 'marker_provider.dart';
import '../constantes.dart';
import 'Firebase/firebase_authuser.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {

  User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic> datos = {};
  String _opcionseleccionada = "-----";
  final textoruta = TextEditingController();

  void initState() {
    super.initState();
    datos = Provider.of<MarkerProvider>(context, listen: false).datosfirestore;
  }

  @override
  Widget build(BuildContext context) {


    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp, DeviceOrientation.portraitDown
    ]);

   // _opcionseleccionada = Provider.of<MarkerProvider>(context, listen: false).datosfirestore['tipo_camion'];
    double screenwidth = MediaQuery.of(context).size.width;

    return LayoutBuilder(
      builder: (context, constrains) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Configuracion", style: TextStyle(color: Colors.black)),
            backgroundColor: Constantes.kcOrangelight,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.logout, color: Colors.black),
                onPressed: () async {
                  FirebaseAuthUsuario firebase = FirebaseAuthUsuario();
                  await firebase.signOutconGoogle();
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (context) => LocationScreen()),
                  );
                },
              ),
            ],
          ),
          body: Stack(
            children: <Widget>[
              // Aquí va el contenido que estará detrás del contenedor deslizable
              Container(
                color: Constantes.kcOrangelight,
                child: Container(
                  margin: EdgeInsets.only(top: 21),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // user image sin circle avatar
                          Center(
                            child: CircleAvatar(
                              radius: 40,
                              backgroundImage: NetworkImage(user!.photoURL!),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            user!.displayName!,
                            style: TextStyle(
                              fontSize: screenwidth * 0.05,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 10,),
                          Text(
                            user!.email!,
                            style: TextStyle(
                              fontSize: screenwidth * 0.04,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 17, 0, 0),
                child: DraggableScrollableSheet(
                  initialChildSize: 0.82,
                  // Tamaño inicial del contenedor deslizable
                  minChildSize: 0.82,
                  // Tamaño mínimo del contenedor deslizable
                  maxChildSize: 1,
                  // Tamaño máximo del contenedor deslizable
                  builder: (BuildContext context,
                      ScrollController scrollController) {
                    return Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40),
                          ),
                        ),
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 9, 0, 0),
                                child: Container(
                                  margin: EdgeInsets.only(top: 21),
                                  width: 170,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(21),
                                  ),
                                ),
                              ),
                              SizedBox(height: 21),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                                child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(children: <TextSpan>[
                                      TextSpan(
                                          text: "Opciones",
                                          style: TextStyle(
                                            color: Constantes.kcDarkBlueColor,
                                            fontWeight: FontWeight.w500,
                                            fontSize: screenwidth * 0.07,
                                          )),
                                      TextSpan(
                                          text: "\ndatos de tu cuenta",
                                          style: TextStyle(
                                              color: Constantes.kcBlackColor,
                                              fontWeight: FontWeight.w500,
                                              fontSize: screenwidth * 0.05)),

                                    ])
                                ),
                              ),
                              SizedBox(height: MediaQuery
                                  .of(context)
                                  .size
                                  .height * 0.02),
                              // column del archivosscreen_boton agregar
                              datos['tipo_user'] == "camion"
                                  ? Column(
                                children: [
                                  const SizedBox(height: 11),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        30, 0, 30, 21),
                                    child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .start,
                                            children: [
                                              Text("Tipo de cuenta: ", style: TextStyle(
                                                  color: Constantes.kcDarkBlueColor,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: screenwidth * 0.05
                                              )),
                                              Text(datos['tipo_user'], style: TextStyle(
                                                  color: Constantes.kcBlackColor,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: screenwidth * 0.05
                                              )),
                                            ],
                                          ),
                                          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .start,
                                            children: [
                                              Text("Ruta: ", style: TextStyle(
                                                  color: Constantes.kcDarkBlueColor,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: screenwidth * 0.05
                                              )),
                                              Text(datos['ruta'], style: TextStyle(
                                                  color: Constantes.kcBlackColor,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: screenwidth * 0.05
                                              )),
                                            ],
                                          ),
                                          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .start,
                                            children: [
                                              Text("Camion: ", style: TextStyle(
                                                  color: Constantes.kcDarkBlueColor,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: screenwidth * 0.05
                                              )),
                                              Text(datos['nombre_camion'], style: TextStyle(
                                                  color: Constantes.kcBlackColor,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: screenwidth * 0.05
                                              )),
                                            ],
                                          ),
                                          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .start,
                                            children: [
                                              Text("Tipo de transporte: ", style: TextStyle(
                                                  color: Constantes.kcDarkBlueColor,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: screenwidth * 0.05
                                              )),
                                              Text(datos['tipo_camion'], style: TextStyle(
                                                  color: Constantes.kcBlackColor,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: screenwidth * 0.05
                                              )),
                                            ],
                                          ),
                                          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .start,
                                            children: [
                                              Text("Modelo del camion: ", style: TextStyle(
                                                  color: Constantes.kcDarkBlueColor,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: screenwidth * 0.05
                                              )),
                                              Text(datos['modelo_camion'], style: TextStyle(
                                                  color: Constantes.kcBlackColor,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: screenwidth * 0.05
                                              )),
                                            ],
                                          ),
                                          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                                          ElevatedButton(
                                            onPressed: () {
                                              // Boton que te permita editar los datos del camion
                                              showCupertinoModalPopup(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return CupertinoActionSheet(
                                                      title: Text("Editar datos del camion"),
                                                      message: Text("Modifica los datos del camion"),
                                                      actions: <Widget>[
                                                        CupertinoActionSheetAction(
                                                          child: Text("Editar ruta"),
                                                          onPressed: () {
                                                            Navigator.of(context).pop();
                                                            // dialog que muestre la ruta actual y permita editarla en la misma interfaz
                                                            showDialog(
                                                              context: context,
                                                              builder: (context) {
                                                                return Dialog(
                                                                  insetPadding: EdgeInsets.all(11),
                                                                  child: Container(
                                                                    height: MediaQuery.of(context).size.height * 0.4,
                                                                    child: AlertDialog(
                                                                      insetPadding: EdgeInsets.all(11),
                                                                      title: Text(
                                                                          "Editar ruta"),
                                                                      content: Column(
                                                                          mainAxisAlignment: MainAxisAlignment
                                                                              .center,
                                                                          children: [
                                                                            Text(
                                                                                "Ruta actual: ${datos['ruta']}", style: TextStyle(
                                                                              fontSize: screenwidth * 0.05,
                                                                            )),
                                                                            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                                                            Container(
                                                                              width: MediaQuery.of(context).size.width,
                                                                              decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(21),
                                                                                  color: Colors.orange.shade400,
                                                                                ),
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.fromLTRB(21, 0, 21, 0),
                                                                                child: TextField(
                                                                                  controller: textoruta,
                                                                                  inputFormatters: [
                                                                                    FilteringTextInputFormatter.digitsOnly,
                                                                                    LengthLimitingTextInputFormatter(3),
                                                                                  ],
                                                                                  decoration: InputDecoration(
                                                                                    border: InputBorder.none,
                                                                                    labelText: "Nuevo numero de ruta (3 digitos)",
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                      ),
                                                                      actions: [
                                                                        TextButton(
                                                                          onPressed: () {
                                                                            textoruta.text = "";
                                                                            Navigator
                                                                                .pop(
                                                                                context);
                                                                          },
                                                                          child: Text(
                                                                              "Cancelar"),
                                                                        ),
                                                                        TextButton(
                                                                          onPressed: textoruta.text.isNotEmpty ? () async {
                                                                            // Actualizar la ruta en la base de datos
                                                                            if (textoruta.text != "") {
                                                                              var markerProvider = Provider.of<MarkerProvider>(context, listen: false);
                                                                              markerProvider.setDatosFirestore({
                                                                                "ruta": textoruta.text,
                                                                                "nombre_camion": datos['nombre_camion'],
                                                                                "tipo_camion": datos['tipo_camion'],
                                                                                "modelo_camion": datos['modelo_camion'],
                                                                                "tipo_user": datos['tipo_user'],
                                                                              });
                                                                              await FirebaseFirestore.instance.collection("users").doc(user!.uid).update({
                                                                                "ruta": textoruta.text,
                                                                              }).then((value) {
                                                                                setState(() {
                                                                                  datos['ruta'] = textoruta.text;
                                                                                });
                                                                                textoruta.text = "";
                                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                                      SnackBar(
                                                                                        content: Text(
                                                                                            "Ruta actualizada", style: TextStyle(color: Colors.white)),
                                                                                        backgroundColor: Colors.lightGreen,
                                                                                      ),
                                                                                );
                                                                              }
                                                                            );
                                                                            Navigator.of(context).pop();
                                                                            }
                                                                          } : null,
                                                                          child: Text(
                                                                              "Guardar"),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                );
                                                              }
                                                            );
                                                          },
                                                        ),
                                                        CupertinoActionSheetAction(
                                                          child: Text("Editar nombre del camion"),
                                                          onPressed: () {
                                                            Navigator.of(context).pop();
                                                            // dialog que muestre la ruta actual y permita editarla en la misma interfaz
                                                            showDialog(
                                                              context: context,
                                                              builder: (context) {
                                                                return Dialog(
                                                                  insetPadding: EdgeInsets.all(11),
                                                                  child: Container(
                                                                    height: MediaQuery.of(context).size.height * 0.4,
                                                                    child: AlertDialog(
                                                                      insetPadding: EdgeInsets.all(11),
                                                                      title: Text(
                                                                          "Editar nombre camion", style: TextStyle(fontSize: screenwidth * 0.05)),
                                                                      content: Column(
                                                                          mainAxisAlignment: MainAxisAlignment
                                                                              .center,
                                                                          children: [
                                                                            Text(
                                                                                "Nombre del camion actual: ${datos['nombre_camion']}", style: TextStyle(
                                                                              fontSize: screenwidth * 0.04,
                                                                            )),
                                                                            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                                                            Container(
                                                                              width: MediaQuery.of(context).size.width,
                                                                              decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(21),
                                                                                  color: Colors.orange.shade400,
                                                                                ),
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.fromLTRB(21, 0, 21, 0),
                                                                                child: TextField(
                                                                                  controller: textoruta,
                                                                                  decoration: InputDecoration(
                                                                                    border: InputBorder.none,
                                                                                    labelText: "Nuevo nombre del camion",
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                      ),
                                                                      actions: [
                                                                        TextButton(
                                                                          onPressed: () {
                                                                            textoruta.text = "";
                                                                            Navigator
                                                                                .pop(
                                                                                context);
                                                                          },
                                                                          child: Text(
                                                                              "Cancelar"),
                                                                        ),
                                                                        TextButton(
                                                                          onPressed: textoruta.text.isNotEmpty ? () async {
                                                                            // Actualizar la ruta en la base de datos
                                                                            if (textoruta.text != "") {
                                                                              var markerProvider = Provider.of<MarkerProvider>(context, listen: false);
                                                                              markerProvider.setDatosFirestore({
                                                                                "ruta": datos['ruta'],
                                                                                "nombre_camion": textoruta.text,
                                                                                "tipo_camion": datos['tipo_camion'],
                                                                                "modelo_camion": datos['modelo_camion'],
                                                                                "tipo_user": datos['tipo_user'],
                                                                              });
                                                                              await FirebaseFirestore.instance.collection("users").doc(user!.uid).update({
                                                                                "nombre_camion": textoruta.text,
                                                                              }).then((value) {
                                                                                setState(() {
                                                                                  datos['nombre_camion'] = textoruta.text;
                                                                                });
                                                                                textoruta.text = "";
                                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                                      SnackBar(
                                                                                        content: Text(
                                                                                            "Nombre de camion actualizado", style: TextStyle(color: Colors.white)),
                                                                                        backgroundColor: Colors.lightGreen,
                                                                                      ),
                                                                                );
                                                                              }
                                                                            );
                                                                            Navigator.of(context).pop();
                                                                            }
                                                                          } : null,
                                                                          child: Text(
                                                                              "Guardar"),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                );
                                                              }
                                                            );
                                                          },
                                                        ),
                                                        CupertinoActionSheetAction(
                                                          child: Text("Editar tipo de transporte"),
                                                          onPressed: () {
                                                            Navigator.of(context).pop();
                                                            // dialog que muestre la ruta actual y permita editarla en la misma interfaz
                                                            showDialog(
                                                              context: context,
                                                              builder: (context) {
                                                                return Dialog(
                                                                  insetPadding: EdgeInsets.all(11),
                                                                  child: Container(
                                                                    height: MediaQuery.of(context).size.height * 0.4,
                                                                    child: AlertDialog(
                                                                      insetPadding: EdgeInsets.all(11),
                                                                      title: Text(
                                                                          "Editar tipo de camion", style: TextStyle(fontSize: screenwidth * 0.05) ),
                                                                      content: Column(
                                                                          mainAxisAlignment: MainAxisAlignment
                                                                              .center,
                                                                          children: [
                                                                            Text(
                                                                                "Tipo de camion actual: ${datos['tipo_camion']}", style: TextStyle(
                                                                              fontSize: screenwidth * 0.04,
                                                                            )),
                                                                            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                                                            Container(
                                                                              width: MediaQuery.of(context).size.width,
                                                                              decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(21),
                                                                                  color: Colors.orange.shade400,
                                                                                ),
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.fromLTRB(21, 0, 21, 0),
                                                                                child: CustomDropdownButton(
                                                                                  initialValue: _opcionseleccionada,
                                                                                  items: ["-----", "MeMuevo", "Ecovia", "Transmetro"],
                                                                                  onValueChanged: (newValue) {
                                                                                      setState(() {
                                                                                        _opcionseleccionada = newValue;
                                                                                      });
                                                                                    },
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                      ),
                                                                      actions: [
                                                                        TextButton(
                                                                          onPressed: () {
                                                                            textoruta.text = "";
                                                                            Navigator
                                                                                .pop(
                                                                                context);
                                                                          },
                                                                          child: Text(
                                                                              "Cancelar"),
                                                                        ),
                                                                        TextButton(
                                                                          onPressed: _opcionseleccionada.isNotEmpty ? () async {
                                                                            // Actualizar la ruta en la base de datos
                                                                            if (_opcionseleccionada != "" && _opcionseleccionada != datos['tipo_camion']) {
                                                                              var markerProvider = Provider.of<MarkerProvider>(context, listen: false);
                                                                              markerProvider.setDatosFirestore({
                                                                                "ruta": datos['ruta'],
                                                                                "nombre_camion": datos['nombre_camion'],
                                                                                "tipo_camion": _opcionseleccionada,
                                                                                "modelo_camion": datos['modelo_camion'],
                                                                                "tipo_user": datos['tipo_user'],
                                                                              });
                                                                              await FirebaseFirestore.instance.collection("users").doc(user!.uid).update({
                                                                                "tipo_camion": _opcionseleccionada,
                                                                              }).then((value) {
                                                                                setState(() {
                                                                                  datos['tipo_camion'] = _opcionseleccionada;
                                                                                });
                                                                                textoruta.text = "";
                                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                                      SnackBar(
                                                                                        content: Text(
                                                                                            "Tipo de camion actualizado", style: TextStyle(color: Colors.white)),
                                                                                        backgroundColor: Colors.lightGreen,
                                                                                      ),
                                                                                );
                                                                              }
                                                                            );
                                                                            Navigator.of(context).pop();
                                                                            }
                                                                          } : null,
                                                                          child: Text(
                                                                              "Guardar"),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                );
                                                              }
                                                            );
                                                          },
                                                        ),
                                                        CupertinoActionSheetAction(
                                                          child: Text("Editar modelo del camion"),
                                                          onPressed: () {
                                                            Navigator.of(context).pop();
                                                            // dialog que muestre la ruta actual y permita editarla en la misma interfaz
                                                            showDialog(
                                                              context: context,
                                                              builder: (context) {
                                                                return Dialog(
                                                                  insetPadding: EdgeInsets.all(11),
                                                                  child: Container(
                                                                    height: MediaQuery.of(context).size.height * 0.4,
                                                                    child: AlertDialog(
                                                                      insetPadding: EdgeInsets.all(11),
                                                                      title: Text(
                                                                          "Editar modelo del camion", style: TextStyle(fontSize: screenwidth * 0.05)),
                                                                      content: Column(
                                                                          mainAxisAlignment: MainAxisAlignment
                                                                              .center,
                                                                          children: [
                                                                            Text(
                                                                                "Modelo del camion actual: ${datos['modelo_camion']}", style: TextStyle(
                                                                              fontSize: screenwidth * 0.04,
                                                                            )),
                                                                            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                                                            Container(
                                                                              width: MediaQuery.of(context).size.width,
                                                                              decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(21),
                                                                                  color: Colors.orange.shade400,
                                                                                ),
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.fromLTRB(21, 0, 21, 0),
                                                                                child: TextField(
                                                                                  controller: textoruta,
                                                                                  decoration: InputDecoration(
                                                                                    border: InputBorder.none,
                                                                                    labelText: "Nuevo modelo del camion",
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                      ),
                                                                      actions: [
                                                                        TextButton(
                                                                          onPressed: () {
                                                                            textoruta.text = "";
                                                                            Navigator
                                                                                .pop(
                                                                                context);
                                                                          },
                                                                          child: Text(
                                                                              "Cancelar"),
                                                                        ),
                                                                        TextButton(
                                                                          onPressed: textoruta.text.isNotEmpty ? () async {
                                                                            // Actualizar la ruta en la base de datos
                                                                            if (textoruta.text != "") {
                                                                              var markerProvider = Provider.of<MarkerProvider>(context, listen: false);
                                                                              markerProvider.setDatosFirestore({
                                                                                "ruta": datos['ruta'],
                                                                                "nombre_camion": datos['nombre_camion'],
                                                                                "tipo_camion": datos['tipo_camion'],
                                                                                "modelo_camion": textoruta.text,
                                                                                "tipo_user": datos['tipo_user'],
                                                                              });
                                                                              await FirebaseFirestore.instance.collection("users").doc(user!.uid).update({
                                                                                "modelo_camion": textoruta.text,
                                                                              }).then((value) {
                                                                                setState(() {
                                                                                  datos['modelo_camion'] = textoruta.text;
                                                                                });
                                                                                textoruta.text = "";
                                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                                      SnackBar(
                                                                                        content: Text(
                                                                                            "Modelo del camion actualizado", style: TextStyle(color: Colors.white)),
                                                                                        backgroundColor: Colors.lightGreen,
                                                                                      ),
                                                                                );
                                                                              }
                                                                            );
                                                                            Navigator.of(context).pop();
                                                                            }
                                                                          } : null,
                                                                          child: Text(
                                                                              "Guardar"),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                );
                                                              }
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                      cancelButton: CupertinoActionSheetAction(
                                                        child: Text("Cancelar"),
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                        },
                                                      ),
                                                    );
                                                  }
                                              );
                                            },
                                            child: Text("Editar datos de tu cuenta"),
                                          ),
                                        ],
                                      ),
                                  ),
                                  const SizedBox(height: 21),
                                ],
                              )
                              : Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    30, 0, 30, 21),
                                child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .start,
                                        children: [
                                          Text("Usuario: ", style: TextStyle(
                                              color: Constantes.kcDarkBlueColor,
                                              fontWeight: FontWeight.w500,
                                              fontSize: screenwidth * 0.05
                                          )),
                                          Text(datos['usuario'], style: TextStyle(
                                              color: Constantes.kcBlackColor,
                                              fontWeight: FontWeight.w500,
                                              fontSize: screenwidth * 0.05
                                          )),
                                        ],
                                      ),
                                      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .start,
                                        children: [
                                          Text("Telefono: ", style: TextStyle(
                                              color: Constantes.kcDarkBlueColor,
                                              fontWeight: FontWeight.w500,
                                              fontSize: screenwidth * 0.05
                                          )),
                                          Text(datos['telefono'], style: TextStyle(
                                              color: Constantes.kcBlackColor,
                                              fontWeight: FontWeight.w500,
                                              fontSize: screenwidth * 0.05
                                          )),
                                        ],
                                      ),
                                      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                      ElevatedButton(
                                        onPressed: () {
                                          // Boton que te permita editar los datos del camion
                                          showCupertinoModalPopup(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return CupertinoActionSheet(
                                                  title: Text("Editar tus datos"),
                                                  message: Text("Modifica los datos de tu cuenta"),
                                                  actions: <Widget>[
                                                    CupertinoActionSheetAction(
                                                      child: Text("Editar nombre de usuario"),
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                        // dialog que muestre la ruta actual y permita editarla en la misma interfaz
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return Dialog(
                                                              insetPadding: EdgeInsets.all(11),
                                                              child: Container(
                                                                height: MediaQuery.of(context).size.height * 0.4,
                                                                child: AlertDialog(
                                                                  insetPadding: EdgeInsets.all(11),
                                                                  title: Text(
                                                                      "Editar nombre de usuario", style: TextStyle(fontSize: screenwidth * 0.05)),
                                                                  content: Column(
                                                                      mainAxisAlignment: MainAxisAlignment
                                                                          .center,
                                                                      children: [
                                                                        Text(
                                                                            "Nombre de usuario actual: ${datos['usuario']}", style: TextStyle(
                                                                          fontSize: screenwidth * 0.04,
                                                                        )),
                                                                        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                                                        Container(
                                                                          width: MediaQuery.of(context).size.width,
                                                                          decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(21),
                                                                              color: Colors.orange.shade400,
                                                                            ),
                                                                          child: Padding(
                                                                            padding: const EdgeInsets.fromLTRB(21, 0, 21, 0),
                                                                            child: TextField(
                                                                              controller: textoruta,
                                                                              decoration: InputDecoration(
                                                                                border: InputBorder.none,
                                                                                labelText: "Nuevo nombre de usuario",
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                  ),
                                                                  actions: [
                                                                    TextButton(
                                                                      onPressed: () {
                                                                        textoruta.text = "";
                                                                        Navigator
                                                                            .pop(
                                                                            context);
                                                                      },
                                                                      child: Text(
                                                                          "Cancelar"),
                                                                    ),
                                                                    TextButton(
                                                                      onPressed: textoruta.text.isNotEmpty ? () async {
                                                                        // Actualizar la ruta en la base de datos
                                                                        if (textoruta.text != "") {
                                                                          var markerProvider = Provider.of<MarkerProvider>(context, listen: false);
                                                                          markerProvider.setDatosFirestore({
                                                                            "usuario": textoruta.text,
                                                                            "telefono": datos['telefono'],
                                                                            "tipo_user": datos['tipo_user'],
                                                                          });
                                                                          await FirebaseFirestore.instance.collection("users").doc(user!.uid).update({
                                                                            "usuario": textoruta.text,
                                                                          }).then((value) {
                                                                            setState(() {
                                                                              datos['usuario'] = textoruta.text;
                                                                            });
                                                                            textoruta.text = "";
                                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                                                  SnackBar(
                                                                                    content: Text(
                                                                                        "Nombre de usuario actualizada", style: TextStyle(color: Colors.white)),
                                                                                    backgroundColor: Colors.lightGreen,
                                                                                  ),
                                                                            );
                                                                          }
                                                                        );
                                                                        Navigator.of(context).pop();
                                                                        }
                                                                      } : null,
                                                                      child: Text(
                                                                          "Guardar"),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                        );
                                                      },
                                                    ),
                                                    CupertinoActionSheetAction(
                                                      child: Text("Editar telefono"),
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                        // dialog que muestre la ruta actual y permita editarla en la misma interfaz
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return Dialog(
                                                              insetPadding: EdgeInsets.all(11),
                                                              child: Container(
                                                                height: MediaQuery.of(context).size.height * 0.4,
                                                                child: AlertDialog(
                                                                  insetPadding: EdgeInsets.all(11),
                                                                  title: Text(
                                                                      "Editar telefono", style: TextStyle(fontSize: screenwidth * 0.05)),
                                                                  content: Column(
                                                                      mainAxisAlignment: MainAxisAlignment
                                                                          .center,
                                                                      children: [
                                                                        Text(
                                                                            "Numero de telefono actual: ${datos['telefono']}", style: TextStyle(
                                                                          fontSize: screenwidth * 0.04,
                                                                        )),
                                                                        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                                                                        Container(
                                                                          width: MediaQuery.of(context).size.width,
                                                                          decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(21),
                                                                              color: Colors.orange.shade400,
                                                                            ),
                                                                          child: Padding(
                                                                            padding: const EdgeInsets.fromLTRB(21, 0, 21, 0),
                                                                            child: TextField(
                                                                              controller: textoruta,
                                                                              inputFormatters: [
                                                                                FilteringTextInputFormatter.digitsOnly,
                                                                                LengthLimitingTextInputFormatter(10),
                                                                              ],
                                                                              decoration: InputDecoration(
                                                                                border: InputBorder.none,
                                                                                labelText: "Numero de telefono (10 digitos)",
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                  ),
                                                                  actions: [
                                                                    TextButton(
                                                                      onPressed: () {
                                                                        textoruta.text = "";
                                                                        Navigator
                                                                            .pop(
                                                                            context);
                                                                      },
                                                                      child: Text(
                                                                          "Cancelar"),
                                                                    ),
                                                                    TextButton(
                                                                      onPressed: textoruta.text.isNotEmpty ? () async {
                                                                        // Actualizar la ruta en la base de datos
                                                                        if (textoruta.text != "") {
                                                                          var markerProvider = Provider.of<MarkerProvider>(context, listen: false);
                                                                          markerProvider.setDatosFirestore({
                                                                            "usuario": datos['usuario'],
                                                                            "telefono": textoruta.text,
                                                                            "tipo_user": datos['tipo_user'],
                                                                          });
                                                                          await FirebaseFirestore.instance.collection("users").doc(user!.uid).update({
                                                                            "telefono": textoruta.text,
                                                                          }).then((value) {
                                                                            setState(() {
                                                                              datos['telefono'] = textoruta.text;
                                                                            });
                                                                            textoruta.text = "";
                                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                                                  SnackBar(
                                                                                    content: Text(
                                                                                        "Numero de telefono actualizado", style: TextStyle(color: Colors.white)),
                                                                                    backgroundColor: Colors.lightGreen,
                                                                                  ),
                                                                            );
                                                                          }
                                                                        );
                                                                        Navigator.of(context).pop();
                                                                        }
                                                                      } : null,
                                                                      child: Text(
                                                                          "Guardar"),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                  cancelButton: CupertinoActionSheetAction(
                                                    child: Text("Cancelar"),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                );
                                              }
                                          );
                                        },
                                        child: Text("Editar datos de tu cuenta"),
                                      ),
                                    ],
                                  ),
                              ),
                            ],
                          ),
                        )
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

class CustomDropdownButton extends StatefulWidget {
  final String initialValue;
  final List<String> items;
  final ValueChanged<String> onValueChanged;

  CustomDropdownButton({required this.initialValue, required this.items, required this.onValueChanged});

  @override
  _CustomDropdownButtonState createState() => _CustomDropdownButtonState();
}

class _CustomDropdownButtonState extends State<CustomDropdownButton> {
  late String _opcionseleccionada;

  @override
  void initState() {
    super.initState();
    _opcionseleccionada = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: _opcionseleccionada,
      onChanged: (String? newValue) {
        setState(() {
          _opcionseleccionada = newValue!;
        });
        widget.onValueChanged(_opcionseleccionada);
      },
      items: widget.items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}