import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_colors.dart';
import 'features/admin/admin_dashboard.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/splash_screen.dart';
import 'features/librarian/librarian_dashboard.dart';
import 'features/student/bus_screen.dart';
import 'features/student/chatbot_screen.dart';
import 'features/student/library_screen.dart';
import 'features/student/notifications_screen.dart';
import 'features/student/profile_screen.dart';
import 'features/student/rules_screen.dart';
import 'features/student/student_dashboard.dart';
import 'features/transport/transport_dashboard.dart';

void main() {
  runApp(const SmartCampusApp());
}

class SmartCampusApp extends StatefulWidget {
  const SmartCampusApp({super.key});

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
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bgDark1,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.cyan,
          secondary: AppColors.purple3,
          surface: AppColors.glass,
          tertiary: AppColors.cyanDeep,
          onPrimary: Colors.black,
          onSecondary: Colors.white,
          onSurface: AppColors.textPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: false,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: 0,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: AppColors.textMuted,
            height: 1.4,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.glass.withValues(alpha: 0.75),
          hintStyle: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 14,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: AppColors.cyan.withValues(alpha: 0.18),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: AppColors.cyan.withValues(alpha: 0.18),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: AppColors.cyan,
              width: 1.4,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.purple3,
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
            foregroundColor: AppColors.textPrimary,
            side: BorderSide(
              color: AppColors.purpleAccent.withValues(alpha: 0.35),
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
          color: AppColors.glass.withValues(alpha: 0.26),
          elevation: 0,
          shadowColor: Colors.black.withValues(alpha: 0.40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: AppColors.cyan.withValues(alpha: 0.08),
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
                  AppColors.bgDark1,
                  AppColors.bgDark3,
                ],
              ),
            ),
            child: child,
          ),
        );
      },
      onGenerateRoute: _generateRoute,
      home: const SplashScreen(),
    );
  }
}

Route<dynamic> _generateRoute(RouteSettings settings) {
  final args = _routeArgs(settings.arguments);

  Widget page;
  switch (settings.name) {
    case '/login':
      page = const LoginScreen();
      break;
    case '/student-dashboard':
      page = StudentDashboard(user: args);
      break;
    case '/student-chat':
      page = ChatbotScreen(user: args);
      break;
    case '/student-bus':
      page = BusScreen(user: args);
      break;
    case '/student-library':
      page = LibraryScreen(user: args);
      break;
    case '/student-rules':
      page = RulesScreen(user: args);
      break;
    case '/student-profile':
      page = ProfileScreen(user: args);
      break;
    case '/student-notifications':
      page = NotificationsScreen(user: args);
      break;
    case '/admin-dashboard':
      page = AdminDashboard(user: args);
      break;
    case '/librarian-dashboard':
      page = LibrarianDashboard(user: args);
      break;
    case '/transport-dashboard':
      page = TransportDashboard(user: args);
      break;
    default:
      page = const SplashScreen();
  }

  return MaterialPageRoute(builder: (_) => page, settings: settings);
}

Map<String, dynamic> _routeArgs(Object? arguments) {
  if (arguments is Map<String, dynamic>) return arguments;
  if (arguments is Map) {
    return arguments.map((key, value) => MapEntry(key.toString(), value));
  }
  return const <String, dynamic>{};
}
