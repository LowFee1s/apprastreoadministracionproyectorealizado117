import 'package:apprastreoadministracionproyectorealizado/constantes.dart';
import 'package:apprastreoadministracionproyectorealizado/llenardatosuser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'Firebase/firebase_authuser.dart';
import 'main_screen.dart';
import 'marker_provider.dart';

class LocationScreen extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
 // bool _isLoading = false;

  /*void _onButtonPressed() async {
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
  }*/

  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    Size size = MediaQuery.of(context).size;
    OutlineInputBorder(
        borderSide: BorderSide(color: Constantes.kcBordeColor, width: 3.0)
    );
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Constantes.kcPrimaryColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("lib/img/logoinicio.png", height: 170),
              RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(children: <TextSpan>[
                    TextSpan(
                        text: Constantes.textInicioSesionTitulo,
                        style: TextStyle(
                          color: Constantes.kcBlackColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 30.0,
                        )),
                  ])),
              Text(
                Constantes.textChicoInicioSesion,
                style: TextStyle(color: Constantes.kcDarkGreyColor),
              ),
              SizedBox(height: size.height * 0.05),
              GoogleSignIn(),
            ],
          ),
        ),
      ),
    );
  }
}



Widget buildRowDivider({required Size size}) {
  return SizedBox(
    width: size.width * 0.8,
    child: Row(children: <Widget>[
      Expanded(child: Divider(color: Constantes.kcDarkGreyColor)),
      Padding(
          padding: EdgeInsets.only(left: 8.0, right: 8.0),
          child: Text(
            "O",
            style: TextStyle(color: Constantes.kcDarkGreyColor),
          )),
      Expanded(child: Divider(color: Constantes.kcDarkGreyColor)),
    ]),
  );
}

class GoogleSignIn extends StatefulWidget {
  GoogleSignIn({Key? key}) : super(key: key);

  @override
  _GoogleSignInState createState() => _GoogleSignInState();
}

class _GoogleSignInState extends State<GoogleSignIn> {

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  bool isLoading = false;
  var dato;
  Map<String, dynamic> dato11 = {};

  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    Size size = MediaQuery.of(context).size;
    return  !isLoading? SizedBox(
      width: size.width * 0.8,
      child: OutlinedButton.icon(
        icon: FaIcon(FontAwesomeIcons.google, color: Colors.black),
        onPressed: () async {
          setState(() {
            isLoading = true;
          });
          FirebaseAuthUsuario firebasedato = new FirebaseAuthUsuario();
          try {
            await firebasedato.signInWithGoogle();
            User? user = FirebaseAuth.instance.currentUser;
            dato = await users.doc(user!.uid).get();
            dato11 = dato.data() as Map<String, dynamic>;

          } catch(e){
            if(e is FirebaseAuthException){
              showMessage(e.message!);
            }
          }
          if(!dato.exists){
            Navigator.pushReplacementNamed(context, Constantes.Rellenardatos);
          } else {
            Provider.of<MarkerProvider>(context, listen: false).setDatosFirestore(dato11);
            Navigator.pushReplacementNamed(context, Constantes.HomeNavegacion);
          }
          setState(() {
            isLoading = false;
          });
        },
        label: Text(
          Constantes.textInicioSesionGoogle,
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold),
        ),
        style: ButtonStyle(
            backgroundColor:
            MaterialStateProperty.all<Color>(Constantes.kcGreyColor),
            side: MaterialStateProperty.all<BorderSide>(BorderSide.none)),
      ),
    ) : CircularProgressIndicator();
  }

  void showMessage(String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text(message),
            actions: [
              TextButton(
                child: Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
}
