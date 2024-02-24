import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<String>> getCamiones() async {
  // Your code here...

  final url = Uri.parse(
      "https://appserverapirealizado15-dev-zsrt.1.us-1.fl0.io/camiones");
  final headers = {
    "Authorization": "Basic " +
        base64Encode(utf8.encode(
            "apprastreoadministracionproyectorealizado:PASSCODEFIMERASTREO14")),
  };

  var response = await http.get(url, headers: headers);

  var camiones = jsonDecode(response.body).cast<String>();

  return camiones;

}
