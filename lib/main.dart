import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'location_screen.dart';
import 'marker_provider.dart';

void main() {
  runApp(ChangeNotifierProvider(
      create: (context) => MarkerProvider(), child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LocationScreen(),
    );
  }
}
