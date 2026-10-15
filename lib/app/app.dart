import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../features/home/home_screen.dart';

class BedrockToolsApp extends StatefulWidget {
  const BedrockToolsApp({super.key});

  @override
  State<BedrockToolsApp> createState() => _BedrockToolsAppState();
}

class _BedrockToolsAppState extends State<BedrockToolsApp> {
  Locale _locale = const Locale('ar');

  void _toggleLanguage() {
    setState(() {
      _locale = _locale.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
    });
  }

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF64D987);
    return MaterialApp(
      title: 'Bedrock Tools',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
          surface: const Color(0xFF111813),
        ),
        scaffoldBackgroundColor: const Color(0xFF0B100D),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0B100D),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF151E18),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF151E18),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF2B3A2F)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF2B3A2F)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF64D987), width: 1.5),
          ),
        ),
      ),
      home: HomeScreen(onToggleLanguage: _toggleLanguage),
    );
  }
}
