import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

class KitchXApp extends StatelessWidget {
  const KitchXApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KitchX',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'SpaceMono', scaffoldBackgroundColor: Colors.white),
      home: const LoginScreen(),
    );
  }
}