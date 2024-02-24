import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'main_screen.dart';

class LocationScreen extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  bool _isLoading = false;

  void _onButtonPressed() async {
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
  }
}
