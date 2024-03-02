import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<String>> getCamiones() async {
  // Your code here...

  final url = Uri.parse(
      "https://apiuanltracking-dev-sgeg.1.us-1.fl0.io/camiones");
  final headers = {
    "Authorization": "Basic " +
        base64Encode(utf8.encode(
            "apprastreoadministracionproyectorealizado:PASSCODEFIMERASTREO14")),
  };

  var response = await http.get(url, headers: headers);

  var camiones = jsonDecode(response.body).cast<String>();

  return camiones;

}

Future<List<Map<String, dynamic>>> cargarCamiones() async {
  String url = "https://apiuanltracking-dev-sgeg.1.us-1.fl0.io/obtener_ubicacion";
  var headers = {
    "Authorization": "Basic " +
        base64Encode(utf8.encode(
            "apprastreoadministracionproyectorealizado:PASSCODEFIMERASTREO14")),
  };

  var response = await http.get(Uri.parse(url), headers: headers);

  var responsebody = jsonDecode(response.body);

  var camiones = responsebody.entries.map((entry) {
    var id = entry.key;
    var camion = Map<String, dynamic>.from(entry.value);
    camion['id'] = id;
    return camion;
  }).toList().cast<Map<String, dynamic>>();
  return camiones;

}

