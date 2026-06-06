import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/smart_ai_background.dart';
import '../../core/widgets/smart_cards.dart';
import '../../services/api_client.dart';
import '../../services/auth_service.dart';
import '../admin/admin_dashboard.dart';
import '../librarian/librarian_dashboard.dart';
import '../student/student_dashboard.dart';
import '../transport/transport_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = const AuthService();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRole = 'student';
  bool _loading = false;
  String? _error;

  static const _roles = [
    _LoginRole('student', 'Student', Icons.person_rounded),
    _LoginRole('admin', 'Admin', Icons.admin_panel_settings_rounded),
    _LoginRole('librarian', 'Librarian', Icons.local_library_rounded),
    _LoginRole('transport', 'Transport', Icons.directions_bus_rounded),
  ];

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      setState(() => _error = 'Enter your university ID and password.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _authService.login(
        identifier: identifier,
        password: password,
        role: _selectedRole,
      );

      if (!mounted) return;

      final role = _normalizeRole(_extractRole(data) ?? _selectedRole);
      final user = _extractUser(data, identifier, role);
      _openDashboard(role, user);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Cannot connect to the Smart Campus backend.');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String? _extractRole(Map<String, dynamic> data) {
    final user = ApiClient.asMap(data['user']);
    final possible = [
      data['role'],
      data['user_role'],
      data['account_type'],
      user['role'],
      user['user_role'],
      user['account_type'],
    ];

    for (final value in possible) {
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty) return text;
    }

    return null;
  }

  Map<String, dynamic> _extractUser(
    Map<String, dynamic> data,
    String identifier,
    String role,
  ) {
    final user = ApiClient.asMap(data['user']);
    final profile = ApiClient.asMap(user['profile']);
    final merged = <String, dynamic>{...data, ...user, ...profile};

    merged['role'] = role;
    merged['id'] ??= merged['user_id'] ?? identifier;
    merged['student_id'] ??= merged['university_id'] ?? identifier;
    merged['name'] ??= merged['full_name'] ?? merged['email'] ?? identifier;

    return merged;
  }

  String _normalizeRole(String role) {
    final lowered = role.toLowerCase();

    if (lowered.contains('admin')) return 'admin';
    if (lowered.contains('librarian') || lowered.contains('library')) {
      return 'librarian';
    }
    if (lowered.contains('transport') || lowered.contains('transporter')) {
      return 'transport';
    }

    return 'student';
  }

  void _openDashboard(String role, Map<String, dynamic> user) {
    Widget screen;

    switch (role) {
      case 'admin':
        screen = AdminDashboard(user: user);
        break;
      case 'librarian':
        screen = LibrarianDashboard(user: user);
        break;
      case 'transport':
        screen = TransportDashboard(user: user);
        break;
      case 'student':
      default:
        screen = StudentDashboard(user: user);
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => screen),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SmartAiScaffold(
      dense: true,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final minHeight = constraints.maxHeight > 68
                ? constraints.maxHeight - 68
                : constraints.maxHeight;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(32, 40, 32, 28),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: minHeight),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 14),
                    const Text(
                      'Smart Campus AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Sign in with your university account',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 36),
                    GlassCard(
                      radius: 24,
                      padding: const EdgeInsets.fromLTRB(28, 28, 28, 30),
                      borderColor:
                          AppColors.purpleAccent.withValues(alpha: 0.24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Select your role',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 18),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _roles.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 1.6,
                            ),
                            itemBuilder: (context, index) {
                              final role = _roles[index];

                              return RoleCard(
                                title: role.label,
                                icon: role.icon,
                                selected: _selectedRole == role.key,
                                onTap: () {
                                  setState(() {
                                    _selectedRole = role.key;
                                    _error = null;
                                  });
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          _FieldLabel(
                            _selectedRole == 'student'
                                ? 'University ID'
                                : 'Email',
                          ),
                          const SizedBox(height: 8),
                          _LoginField(
                            controller: _identifierController,
                            hint: _selectedRole == 'student'
                                ? 'University ID'
                                : 'name@campus.com',
                            icon: Icons.badge_rounded,
                          ),
                          const SizedBox(height: 18),
                          const _FieldLabel('Password'),
                          const SizedBox(height: 8),
                          _LoginField(
                            controller: _passwordController,
                            hint: 'Password',
                            icon: Icons.lock_rounded,
                            obscure: true,
                            onSubmitted: (_) => _login(),
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _showPasswordHelp,
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: AppColors.purple3,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.danger,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          GradientButton(
                            label: 'Sign In',
                            loading: _loading,
                            onPressed: _login,
                          ),
                        ],
                      ),
                    ),

                    // IMPORTANT:
                    // Do not use Spacer/Expanded/Flexible inside SingleChildScrollView.
                    // Spacer causes:
                    // RenderFlex children have non-zero flex but incoming height constraints are unbounded.
                    const SizedBox(height: 36),

                    const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Secure University Authentication',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _OnlineDot(),
                              SizedBox(width: 6),
                              Text(
                                'System Online',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showPasswordHelp() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.glass,
          title: const Text('Password Help'),
          content: const Text(
            'Please contact campus IT or your department administrator to reset your account password.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class _LoginRole {
  final String key;
  final String label;
  final IconData icon;

  const _LoginRole(this.key, this.label, this.icon);
}

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _LoginField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final ValueChanged<String>? onSubmitted;

  const _LoginField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      onSubmitted: onSubmitted,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.86),
        ),
        filled: true,
        fillColor: AppColors.bgDark2.withValues(alpha: 0.92),
        hintStyle: const TextStyle(color: AppColors.textMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.purpleAccent),
        ),
      ),
    );
  }
}

class _OnlineDot extends StatelessWidget {
  const _OnlineDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: const BoxDecoration(
        color: AppColors.success,
        shape: BoxShape.circle,
      ),
    );
  }
}
