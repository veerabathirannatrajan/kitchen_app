import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF080810),
  ));
  runApp(const MaximKitchenApp());
}

class MaximKitchenApp extends StatelessWidget {
  const MaximKitchenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MAXIM Kitchen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF080810),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF6B35),
          surface: Color(0xFF13131A),
        ),
        tabBarTheme: const TabBarThemeData(
          overlayColor: WidgetStatePropertyAll(Colors.transparent),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
