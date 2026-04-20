import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'splash_screen.dart';

void main() {
  runApp(const SmartCampusApp());
}

class SmartCampusApp extends StatefulWidget {
  const SmartCampusApp({super.key});

  static _SmartCampusAppState of(BuildContext context) {
    final state = context.findAncestorStateOfType<_SmartCampusAppState>();
    assert(state != null, 'No SmartCampusApp state found in context');
    return state!;
  }

  @override
  State<SmartCampusApp> createState() => _SmartCampusAppState();
}

class _SmartCampusAppState extends State<SmartCampusApp> {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  bool get isArabic => _locale.languageCode == 'ar';

  void setLocale(Locale newLocale) {
    if (_locale == newLocale) return;
    setState(() {
      _locale = newLocale;
    });
  }

  void toggleLocale() {
    setLocale(
      _locale.languageCode == 'ar'
          ? const Locale('en')
          : const Locale('ar'),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color bgPrimary = Color(0xFF0A0E27);
    const Color bgSecondary = Color(0xFF1E0A3C);

    const Color cardBase = Color(0xFF1A1F3A);

    const Color neonCyan = Color(0xFF00F0FF);
    const Color electricBlue = Color(0xFF0080FF);
    const Color brightCyan = Color(0xFF00FFFF);

    const Color textPrimary = Color(0xFFFFFFFF);
    const Color textSecondary = Color(0xFFE0E0E0);
    const Color mutedText = Color(0xFFB8C1D9);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Campus AI',
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      themeMode: ThemeMode.dark,
      theme: ThemeData.dark(useMaterial3: true),
      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bgPrimary,
        colorScheme: const ColorScheme.dark(
          primary: neonCyan,
          secondary: electricBlue,
          surface: cardBase,
          tertiary: brightCyan,
          onPrimary: Colors.black,
          onSecondary: Colors.white,
          onSurface: textPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: textPrimary,
          elevation: 0,
          centerTitle: false,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: textPrimary,
            letterSpacing: 0.2,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: textSecondary,
            height: 1.4,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: mutedText,
            height: 1.4,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            color: mutedText,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: cardBase.withValues(alpha: 0.75),
          hintStyle: const TextStyle(
            color: mutedText,
            fontSize: 14,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: neonCyan.withValues(alpha: 0.18),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: neonCyan.withValues(alpha: 0.18),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: neonCyan,
              width: 1.4,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: neonCyan,
            foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 56),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: textPrimary,
            side: BorderSide(
              color: neonCyan.withValues(alpha: 0.35),
              width: 1,
            ),
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        cardTheme: CardThemeData(
          color: cardBase.withValues(alpha: 0.26),
          elevation: 0,
          shadowColor: Colors.black.withValues(alpha: 0.40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: neonCyan.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          margin: EdgeInsets.zero,
        ),
        dividerColor: Colors.white.withValues(alpha: 0.08),
      ),
      builder: (context, child) {
        final isArabic = _locale.languageCode == 'ar';

        return Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  bgPrimary,
                  bgSecondary,
                ],
              ),
            ),
            child: child,
          ),
        );
      },
      home: const SplashScreen(),
    );
  }
}