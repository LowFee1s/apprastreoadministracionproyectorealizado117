import 'package:geolocator/geolocator.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';


void enviarLocalizacion(currentuser, datos, Position position, _direction) async {
  // Your code here...
  if (currentuser != null) {
    if (datos['tipo_user'] == 'camion') {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      String Iddevice = androidInfo.androidId;

      var url = Uri.parse(
          'https://apiuanltracking-dev-sgeg.1.us-1.fl0.io/update_ubicacion');
      var headers = {
        "Content-type": "application/json",
        "Authorization": "Basic " +
            base64Encode(utf8.encode(
                "apprastreoadministracionproyectorealizado:PASSCODEFIMERASTREO14")),
      };

      var body = jsonEncode({
        'id_usuario': Iddevice,
        'Camion': '${datos['ruta']} - ${datos['nombre_camion']}',
        'Ruta': [
          {"lat": 25.7969811, "lng": -100.25335319999999},
          {"lat": 25.796800899999997, "lng": -100.2530536},
          {"lat": 25.7969811, "lng": -100.25335319999999},
          {"lat": 25.784658399999998, "lng": -100.2540162},
          {"lat": 25.784972, "lng": -100.2664976},
          {"lat": 25.7710959, "lng": -100.2653776},
          {"lat": 25.7676545, "lng": -100.2919534},
          {"lat": 25.7238853, "lng": -100.31255279999999},
          {"lat": 25.757854899999998, "lng": -100.2960626},
          {"lat": 25.7615654, "lng": -100.28786579999999},
          {"lat": 25.783837, "lng": -100.2486119},
          {"lat": 25.796800899999997, "lng": -100.2530536},
        ],
        'Direccion': _direction,
        'Tipo': '${datos['tipo_camion']}',
        'localizacion': {'lat': position.latitude, 'lng': position.longitude}
      });

      var response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print("Ubicacion actualizada con exito!");
      } else {
        print("Error al actualizar la ubicacion: ${response.statusCode}");
      }
    } else {
      print("No se puede enviar la ubicacion, el usuario no es un camion");
    }
  } else {
    print("No se puede enviar la ubicacion, el usuario no esta logeado");
  }
}

void detenerLocalizacion(Timer? timer, StreamSubscription<Position>? positionStream) {
  // Your code here...

  positionStream?.cancel();

  timer?.cancel();

}

void borrarubicacion() async {
  // Your code here...

  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  String Iddevice = androidInfo.androidId;

  var url = Uri.parse(
      'https://apiuanltracking-dev-sgeg.1.us-1.fl0.io/quitar_ubicacion');
  var headers = {
    "Content-type": "application/json",
    "Authorization": "Basic " +
        base64Encode(utf8.encode(
            "apprastreoadministracionproyectorealizado:PASSCODEFIMERASTREO14")),
  };
  var body = jsonEncode({
    'id_usuario': Iddevice,
  });

  var response = await http.post(url, headers: headers, body: body);

  if (response.statusCode == 200) {
    print("Ubicacion quitada con exito!");
  } else {
    print("Error al quitar la ubicacion: ${response.statusCode}");
  }
}

void actualizarruta(datos) async {

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    String Iddevice = androidInfo.androidId;

    var url = Uri.parse(
        'https://apiuanltracking-dev-sgeg.1.us-1.fl0.io/actualizar_ruta');
    var headers = {
      "Content-type": "application/json",
      "Authorization": "Basic " +
          base64Encode(utf8.encode(
              "apprastreoadministracionproyectorealizado:PASSCODEFIMERASTREO14")),
    };

    var body = jsonEncode({
      'id_usuario': Iddevice,
      'Ruta': '${datos['ruta']} - ${datos['nombre_camion']}',
    });

    var response = await http.put(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      print("Ruta actualizada con exito!");
    } else {
      print("Error al actualizar la ruta: ${response.statusCode}");

     }

}

void actualizartipocamion(datos) async {

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    String Iddevice = androidInfo.androidId;

    var url = Uri.parse(
        'https://apiuanltracking-dev-sgeg.1.us-1.fl0.io/actualizar_tipo');
    var headers = {
      "Content-type": "application/json",
      "Authorization": "Basic " +
          base64Encode(utf8.encode(
              "apprastreoadministracionproyectorealizado:PASSCODEFIMERASTREO14")),
    };

    var body = jsonEncode({
      'id_usuario': Iddevice,
      'Tipo': '${datos['tipo_camion']}',
    });

    var response = await http.put(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      print("Tipo de camion actualizado con exito!");
    } else {
      print("Error al actualizar la ruta: ${response.statusCode}");

     }

}

void actualizarcamion(datos) async {

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    String Iddevice = androidInfo.androidId;

    var url = Uri.parse(
        'https://apiuanltracking-dev-sgeg.1.us-1.fl0.io/actualizar_camion');
    var headers = {
      "Content-type": "application/json",
      "Authorization": "Basic " +
          base64Encode(utf8.encode(
              "apprastreoadministracionproyectorealizado:PASSCODEFIMERASTREO14")),
    };

    var body = jsonEncode({
      'id_usuario': Iddevice,
      'Camion': '${datos['ruta']} - ${datos['nombre_camion']}',
    });

    var response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      print("Camion actualizado con exito!");
    } else {
      print("Error al actualizar la ruta: ${response.statusCode}");

     }

}





