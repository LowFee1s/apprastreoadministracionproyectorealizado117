
import 'package:apprastreoadministracionproyectorealizado/llenardatosuser.dart';
import 'package:apprastreoadministracionproyectorealizado/perfil_page.dart';
import 'package:flutter/material.dart';

import '../location_screen.dart';
import '../main_screen.dart';

class Navegacion {

  static Map<String, Widget Function(BuildContext)> routes = {
    //'/': (context) => BienvenidaPage(),
    '/iniciar-sesion': (context) => LocationScreen(),
    '/home': (context) => MainScreen(),
    '/datos-usuario': (context) => Llenardatos(),
    '/configuracion': (context) => SettingPage(),
  };
}
