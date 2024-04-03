import 'package:apprastreoadministracionproyectorealizado/bienvenida_page.dart';
import 'package:apprastreoadministracionproyectorealizado/Firebase/firebase_options.dart';
import 'package:apprastreoadministracionproyectorealizado/llenardatosuser.dart';
import 'package:apprastreoadministracionproyectorealizado/main_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'Navegacion/navegacion.dart';
import 'location_screen.dart';
import 'marker_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  LocationPermission permission = await Geolocator.requestPermission();
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
  } else {
    Position position = await Geolocator.getCurrentPosition();
  }
  runApp(ChangeNotifierProvider(
      create: (context) => MarkerProvider(), child: MyApp()));
}

class MyApp extends StatelessWidget {

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? user;
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rastreo de transporte publico',
      home: FutureBuilder(
        future: _checarSiEstaLogin(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(color: Colors.white, child: Center(child: CircularProgressIndicator()));
          } else {
            if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            } else {
              if (snapshot.data == null) {
                return BienvenidaPage();
              } else {
                return FutureBuilder(
                    future: _checarsitienedatos(),
                    builder: (BuildContext context,
                        AsyncSnapshot<Map<String, dynamic>> snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Container(color: Colors.white, child: Center(child: CircularProgressIndicator()));
                      } else {
                        if (snapshot.hasError) {
                          return Text("Error: ${snapshot.error}");
                        } else {
                          if (snapshot.data == null || snapshot.data!["tipo_user"] == null || snapshot.data!["tipo_user"].isEmpty) {
                            return Llenardatos();
                          } else {
                            Provider.of<MarkerProvider>(context, listen: false).setDatosFirestore(snapshot.data!);
                            return MainScreen();
                          }
                        }
                      }
                    }
                );
              }
            }
          }
        },
      ),
      routes: Navegacion.routes,
    );
  }

  Future<User?> _checarSiEstaLogin() async {
    return user = FirebaseAuth.instance.currentUser;
  }

  Future<Map<String, dynamic>> _checarsitienedatos() async {
    if (user != null) {
      DocumentSnapshot documentSnapshot = await users.doc(user!.uid).get();
      if (!documentSnapshot.exists) {
        return {"": ""};
      } else {
        return documentSnapshot.data() as Map<String, dynamic>;
      }
    } else {
      return {"": ""};
    }
  }


}
