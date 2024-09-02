import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const GeolocatorApp(),
    );
  }
}

class GeolocatorApp extends StatefulWidget {
  const GeolocatorApp({super.key});

  @override
  State<GeolocatorApp> createState() => _GeolocatorAppState();
}

class _GeolocatorAppState extends State<GeolocatorApp> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}