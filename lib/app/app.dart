import 'package:flutter/material.dart';
import '../features/home/home_screen.dart';

class BedrockToolsApp extends StatelessWidget {
  const BedrockToolsApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF56C271);
    return MaterialApp(
      title: 'Bedrock Tools',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
        scaffoldBackgroundColor: const Color(0xFF101510),
        cardTheme: CardThemeData(
          color: const Color(0xFF1A211B),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1B241D),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
