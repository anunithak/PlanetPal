import 'package:flutter/material.dart';
import 'dashboard.dart';

void main() {
  runApp(const PlanetPalApp());
}

class PlanetPalApp extends StatelessWidget {
  const PlanetPalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlanetPal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.all(Colors.green),
        ),
      ),
      home: const DashboardPage(),
    );
  }
}


