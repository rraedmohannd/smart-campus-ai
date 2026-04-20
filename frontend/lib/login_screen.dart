import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'main.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController();
  final _pwController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  bool get _isArabic =>
      SmartCampusApp.of(context).locale.languageCode == 'ar';

  String get _title => _isArabic ? 'سمارت كامبس AI' : 'Smart Campus AI';
  String get _subtitle => _isArabic
      ? 'تسجيل الدخول إلى النظام الذكي'
      : 'Login to your smart campus system';

  String get _studentIdHint =>
      _isArabic ? 'الرقم الجامعي' : 'Student ID';
  String get _passwordHint =>
      _isArabic ? 'كلمة المرور' : 'Password';
  String get _loginButton => _isArabic ? 'تسجيل الدخول' : 'Sign In';

  String get _errorEmpty =>
      _isArabic ? 'يرجى إدخال الرقم الجامعي وكلمة المرور'
                : 'Please enter your student ID and password';

  String get _errorInvalid =>
      _isArabic ? 'بيانات الدخول غير صحيحة'
                : 'Invalid credentials';

  String get _errorConnection =>
      _isArabic ? 'خطأ في الاتصال'
                : 'Connection error. Please try again.';

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (_idController.text.trim().isEmpty ||
        _pwController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorEmpty)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'student_id': _idController.text.trim(),
          'password': _pwController.text.trim(),
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(
              studentId: data['student_id'],
              name: data['name'],
              token: data['token'],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorInvalid)),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorConnection)),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color neonCyan = Color(0xFF00F0FF);
    const Color electricBlue = Color(0xFF0080FF);
    const Color textPrimary = Colors.white;
    const Color textSecondary = Color(0xFFB8C1D9);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0E27),
              Color(0xFF1E0A3C),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -120,
              left: -80,
              child: _glowCircle(neonCyan),
            ),
            Positioned(
              bottom: -120,
              right: -80,
              child: _glowCircle(electricBlue),
            ),

            // 🌐 Language Switch Button
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.language, color: Colors.white),
                onPressed: () {
                  SmartCampusApp.of(context).toggleLocale();
                },
              ),
            ),

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF10204F).withOpacity(0.9),
                            const Color(0xFF1A0F49).withOpacity(0.9),
                          ],
                        ),
                        border: Border.all(
                          color: neonCyan.withOpacity(0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: neonCyan.withOpacity(0.25),
                            blurRadius: 40,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Image.asset(
                          'assets/images/logo.webp',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    Text(
                      _title,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                        fontFamily: 'Pattanakarn',
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      _subtitle,
                      style: TextStyle(
                        color: textSecondary.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 32),

                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: Colors.white.withOpacity(0.05),
                        border: Border.all(
                          color: neonCyan.withOpacity(0.15),
                        ),
                      ),
                      child: Column(
                        children: [
                          _neonField(
                            controller: _idController,
                            hint: _studentIdHint,
                            icon: Icons.badge_outlined,
                          ),
                          const SizedBox(height: 16),
                          _neonField(
                            controller: _pwController,
                            hint: _passwordHint,
                            icon: Icons.lock_outline,
                            isPassword: true,
                          ),
                          const SizedBox(height: 24),

                          ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black,
                                    ),
                                  )
                                : Text(_loginButton),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glowCircle(Color color) {
    return Container(
      width: 260,
      height: 260,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.08),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 120,
            spreadRadius: 30,
          ),
        ],
      ),
    );
  }

  Widget _neonField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
      ),
    );
  }
}