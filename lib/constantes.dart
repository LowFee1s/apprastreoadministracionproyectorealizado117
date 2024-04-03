import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Constantes {
  //Colores (paleta de colores a utilizar)
  static const kcPrimaryColor = Color(0xFFFFFFFF);
  static const kcGreyColor = Color(0xFFEEEEEE);
  static const kcOrangelight = Color.fromRGBO(255, 207, 164, 1);
  static const kcOrangeUltralight = Color.fromRGBO(255, 226, 200, 1);
  static const kcBlackColor = Color(0xFFE65100);
  static const kcDarkGreyColor = Color(0xFF9E9E9E);
  static const kcDarkBlueColor = Color(0xFF000000);
  static const kcBordeColor = Color(0xFFEFEFEF);

  // Textos
  static const titulo = "Inicio de sesion con Google";
  static const textIntro = "Enterate de tus camiones \n con esta app ";
  static const textIntrosubira = "Selecciona tu archivo \n a subir, ";
  static const textIntroDesc1 = "facil \n ";
  static const textIntroDescsubira = "dando click aqui! \n ";
  static const textIntroDesc2 = "para ver distintas rutas!";
  static const textChicoRegistro = "Registrarte solo te toma 2 minutos!";
  static const textInicioSesion = "Inicia Sesion";
  static const textIniciar = "Comenzar";
  static const textInicioSesionTitulo = "Bienvenido de vuelta!";
  static const textInicioSesionTitulo1 = "Bienvenido de vuelta!,";
  static const textChicoInicioSesion = "Te hemos hechado de menos";
  static const textInicioSesionGoogle = "Iniciar Sesion con Google";
  static const textCuenta = "No tienes una cuenta?,  ";
  static const textRegistro = "Registrate aqui";
  static const textHome = "Inicio";

  // Navegacion
  static const InicioSesionNavegacion = '/iniciar-sesion';
  static const HomeNavegacion = '/home';
  static const Rellenardatos = '/datos-usuario';
  static const PerfilNavegacion = '/configuracion';


}