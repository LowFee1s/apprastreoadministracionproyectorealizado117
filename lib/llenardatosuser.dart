import 'package:apprastreoadministracionproyectorealizado/constantes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:apprastreoadministracionproyectorealizado/marker_provider.dart';
import 'Firebase/firebase_authuser.dart';
import 'main_screen.dart';

class Llenardatos extends StatefulWidget {
  @override
  _LlenardatosState createState() => _LlenardatosState();
}

class _LlenardatosState extends State<Llenardatos> {
  bool _esConductor = false;
  String _opcionseleccionada = "MeMuevo";
  final _usuarioController = TextEditingController();
  final _usuarioController11 = TextEditingController();
  final _usuarioController2 = TextEditingController();
  final _usuarioController4 = TextEditingController();
  final _usuarioController5 = TextEditingController();
  final _usuarioController7 = TextEditingController();
  final _usuarioController9 = TextEditingController();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? currentUser = FirebaseAuth.instance.currentUser;

  void llenardatos(String dato) async {
  CollectionReference users = firestore.collection('users');
    if (currentUser != null) {
      if (dato == "users") {
         Map<String, dynamic> userData = {
          'usuario': _usuarioController4.text,
          'telefono': _usuarioController5.text,
          'tipo_user': 'user',
        };
        users.doc(currentUser!.uid).set(userData).then((_) {
          print("Usuario registrado");
          print(userData);
          Provider.of<MarkerProvider>(context, listen: false).setDatosFirestore(userData);
          Navigator.pushReplacementNamed(
            context,
            Constantes.HomeNavegacion,
          );
        });
      } else if (dato == "camiones") {
          Map<String, dynamic> userData = {
          'ruta': _usuarioController.text,
          'nombre_camion': _usuarioController2.text,
          'tipo_camion': _opcionseleccionada,
          'modelo_camion': _usuarioController11.text,
          'tipo_user': 'camion',
        };
        users.doc(currentUser!.uid).set(userData).then((value) {
          print("Camion registrado");
          print(userData);
          Provider.of<MarkerProvider>(context, listen: false).setDatosFirestore(userData);
          Navigator.pushReplacementNamed(
            context,
           Constantes.HomeNavegacion,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Constantes.kcPrimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.arrowLeft),
          onPressed: () async {
            FirebaseAuthUsuario firebase = FirebaseAuthUsuario();
            await firebase.signOutconGoogle();
            Navigator.pushReplacementNamed(context, Constantes.InicioSesionNavegacion);
          },
        ),
      ),
      backgroundColor: Constantes.kcPrimaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: size.height * 0.10),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(children: <TextSpan>[
                TextSpan(
                  text: "Rellena estos datos de tu cuenta",
                  style: TextStyle(
                    color: Constantes.kcBlackColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 30.0,
                  ),
                ),
              ]),
            ),
            Text(
              "Para completar el registro",
              style: TextStyle(color: Constantes.kcDarkGreyColor),
            ),
            SizedBox(height: size.height * 0.05),
            SwitchListTile(
              title: Text('¿Eres conductor?'),
              activeColor: Colors.orange,
              value: _esConductor,
              onChanged: (bool value) {
                setState(() {
                  _esConductor = value;
                });
              },
            ),
            _esConductor ?
            Expanded(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      width: size.width * 0.9,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(21, 0, 21, 0),
                        child: TextField(
                          controller: _usuarioController,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          decoration: InputDecoration(
                            hintText: 'Ruta del camion',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: size.width * 0.9,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(21, 0, 21, 0),
                        child: TextField(
                          controller: _usuarioController2,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(21),
                          ],
                          decoration: InputDecoration(
                            hintText: 'Nombre del camion',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: size.width * 0.9,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(21, 0, 21, 0),
                        child: TextField(
                          controller: _usuarioController11,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(21),
                          ],
                          decoration: InputDecoration(
                            hintText: 'Modelo del camion',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: size.width * 0.9,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(21, 0, 21, 0),
                        child: DropdownButton<String>(
                              value: _opcionseleccionada,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _opcionseleccionada = newValue!;
                                });
                              },
                              items: <String>["MeMuevo", "Ecovia", "Transmetro"].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                          ),
                      ),
                      ),
                    ElevatedButton(
                      child: Text('Continuar', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: _usuarioController.text.isNotEmpty && _usuarioController2.text.isNotEmpty && _usuarioController11.text.isNotEmpty ? () {
                        // Aquí puedes guardar los datos y navegar a la siguiente pantalla
                        llenardatos("camiones");
                      } : null,
                          ),
                  ],
                ),
            )
            : Expanded(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      width: size.width * 0.9,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(21, 0, 21, 0),
                        child: TextField(
                          controller: _usuarioController4,
                          decoration: InputDecoration(
                            hintText: 'Nombre de usuario',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: size.width * 0.9,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(21, 0, 21, 0),
                        child: TextField(
                          controller: _usuarioController5,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          decoration: InputDecoration(
                            hintText: 'Numero de telefono',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      child: Text('Continuar', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: _usuarioController4.text.isNotEmpty && _usuarioController5.text.isNotEmpty ? () {
                        // Aquí puedes guardar los datos y navegar a la siguiente pantalla
                        llenardatos("users");
                      } : null,
                    ),
                  ],
                ),
            ),
          ],
        ),
      ),
    );
  }
}
