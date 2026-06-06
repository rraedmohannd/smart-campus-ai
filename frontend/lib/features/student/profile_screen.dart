import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/smart_ai_background.dart';
import '../../core/widgets/status_badge.dart';

class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  const ProfileScreen({
    super.key,
    this.user = const <String, dynamic>{},
  });

  String get _name =>
      (user['name'] ?? user['full_name'] ?? user['email'] ?? 'Student')
          .toString();

  String get _studentId =>
      (user['student_id'] ?? user['university_id'] ?? user['id'] ?? '20260001')
          .toString();

  @override
  Widget build(BuildContext context) {
    return SmartAiScaffold(
      dense: true,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(30, 18, 30, 28),
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Back',
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                ),
                const Expanded(
                  child: Text(
                    'Profile',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Edit',
                  onPressed: () => _showAccountDialog(context),
                  icon: const Icon(Icons.edit_rounded, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GlassCard(
              radius: 28,
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 94,
                        height: 94,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.purple3,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.purple3.withValues(alpha: 0.35),
                              blurRadius: 22,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/campus.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        right: -74,
                        top: 34,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_studentId - ${_roleLabel(user)}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _ProfileBadge(label: 'GPA', value: _value(user, 'gpa')),
                      _ProfileBadge(
                        label: 'Rank',
                        value: _value(user, 'class_rank'),
                      ),
                      _ProfileBadge(label: 'Credits', value: _credits(user)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 34),
            const Center(
              child: Text(
                'Academic Information',
                style: TextStyle(
                  color: AppColors.purple3,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 14),
            GlassCard(
              radius: 24,
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  _InfoRow(
                    label: 'Major',
                    value: _value(user, 'major'),
                  ),
                  const _Divider(),
                  _InfoRow(
                    label: 'Department',
                    value: _value(user, 'department'),
                  ),
                  const _Divider(),
                  _InfoRow(
                    label: 'Academic Status',
                    badge: StatusBadge(
                      label: _academicStatus(user),
                      tone: StatusBadgeTone.success,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _SettingsCard(
              icon: Icons.language_rounded,
              title: 'Language',
              subtitle: 'English (US)',
              onTap: () => _showLanguageDialog(context),
            ),
            _SettingsCard(
              icon: Icons.person_outline_rounded,
              title: 'Account',
              subtitle: 'University authentication',
              onTap: () => _showAccountDialog(context),
            ),
            _SettingsCard(
              icon: Icons.notifications_none_rounded,
              title: 'Notifications',
              subtitle: 'Bus, library, academic alerts',
              onTap: () => Navigator.of(context).pushNamed(
                '/student-notifications',
                arguments: user,
              ),
            ),
            _SettingsCard(
              icon: Icons.help_outline_rounded,
              title: 'Help',
              subtitle: 'Support and FAQ',
              onTap: () => _showHelpDialog(context),
            ),
            _SettingsCard(
              icon: Icons.logout_rounded,
              title: 'Logout',
              subtitle: 'End current session',
              destructive: true,
              onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.glass,
          title: const Text('Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.cyan,
                ),
                title: const Text('English'),
                onTap: () => Navigator.of(context).pop(),
              ),
              ListTile(
                leading: const Icon(
                  Icons.circle_outlined,
                  color: AppColors.textMuted,
                ),
                title: const Text('Arabic'),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.glass,
          title: const Text('Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DialogLine(label: 'Name', value: _name),
              _DialogLine(label: 'ID', value: _studentId),
              _DialogLine(label: 'Role', value: _roleLabel(user)),
              _DialogLine(label: 'Email', value: _value(user, 'email')),
            ],
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

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.glass,
          title: const Text('Help'),
          content: const Text(
            'For account, library, or transport support, contact the campus service desk or your department office.',
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

String _value(Map<String, dynamic> user, String key) {
  final value = user[key];
  if (value == null || value.toString().trim().isEmpty) return 'N/A';
  return value.toString();
}

String _credits(Map<String, dynamic> user) {
  final completed = user['credits_completed'];
  final total = user['total_credits'];
  if (completed != null && total != null) return '$completed/$total';
  if (completed != null) return completed.toString();
  return 'N/A';
}

String _academicStatus(Map<String, dynamic> user) {
  final status = _value(user, 'academic_status');
  return status == 'N/A' ? 'ACTIVE' : status;
}

String _roleLabel(Map<String, dynamic> user) {
  final role = (user['role'] ?? 'student').toString();
  if (role.isEmpty) return 'Student';
  return '${role[0].toUpperCase()}${role.substring(1)}';
}

class _DialogLine extends StatelessWidget {
  final String label;
  final String value;

  const _DialogLine({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '$label: $value',
        style: const TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}

class _ProfileBadge extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.glass.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? badge;

  const _InfoRow({
    required this.label,
    this.value,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        Flexible(
          child: badge ??
              Text(
                value ?? '',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Divider(color: Colors.white.withValues(alpha: 0.10), height: 1),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool destructive;
  final VoidCallback onTap;

  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.danger : AppColors.purple3;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        radius: 20,
        padding: const EdgeInsets.all(16),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: destructive ? AppColors.danger : Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
