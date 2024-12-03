import 'package:dnsconfigure/themecontroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

import 'dnsUpdateScreen.dart';

void main() {
  Get.put(ThemeController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'DNS Updater',
      // Set the initial themeMode to light or dark
      themeMode: ThemeMode.light, // Initial theme (you can set this to light or dark)
      theme: ThemeData.light(), // Light theme
      darkTheme: ThemeData.dark(), // Dark theme
      home: DNSUpdateScreen(),
    );
  }
}


