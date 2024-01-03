import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smile/screens/splashscreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smile Application',
      theme: _buildTheme(Brightness.light),
      home: SplashScreen(),
    );
  }
}

ThemeData _buildTheme(brightness) {

  var baseTheme = ThemeData(brightness: brightness);

  return baseTheme.copyWith(
    // textTheme: GoogleFonts.robotoCondensedTextTheme(baseTheme.textTheme),
      appBarTheme:  AppBarTheme(
        surfaceTintColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        backgroundColor: Colors.transparent,
        elevation: 0,systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
      ),),focusColor: Colors.indigo,primaryColor: Colors.indigo
  );
}