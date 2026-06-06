import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/section_title.dart';
import '../../core/widgets/smart_ai_background.dart';
import '../../core/widgets/smart_cards.dart';
import '../../core/widgets/status_badge.dart';
import 'bus_screen.dart';
import 'chatbot_screen.dart';
import 'library_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'rules_screen.dart';

class StudentDashboard extends StatelessWidget {
  final Map<String, dynamic> user;

  const StudentDashboard({
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
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(26, 22, 26, 24),
                children: [
                  _Header(name: _name, user: user),
                  const SizedBox(height: 20),
                  _SummaryCard(studentId: _studentId, user: user),
                  const SizedBox(height: 22),
                  const Center(
                    child: SectionTitle(title: 'Campus Services'),
                  ),
                  const SizedBox(height: 14),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 18,
                    childAspectRatio: 1.12,
                    children: [
                      ServiceCard(
                        title: 'AI Assistant',
                        subtitle: 'Instant answers',
                        icon: Icons.auto_awesome_rounded,
                        accent: AppColors.purple3,
                        onTap: () => _open(
                          context,
                          ChatbotScreen(user: user),
                        ),
                      ),
                      ServiceCard(
                        title: 'Smart Bus',
                        subtitle: 'Track live routes',
                        icon: Icons.directions_bus_rounded,
                        accent: AppColors.cyan,
                        onTap: () => _open(context, BusScreen(user: user)),
                      ),
                      ServiceCard(
                        title: 'Library',
                        subtitle: 'Reserve books',
                        icon: Icons.menu_book_rounded,
                        accent: AppColors.purple3,
                        onTap: () => _open(context, LibraryScreen(user: user)),
                      ),
                      ServiceCard(
                        title: 'Rules',
                        subtitle: 'Campus policies',
                        icon: Icons.verified_user_rounded,
                        accent: AppColors.purpleAccent,
                        onTap: () => _open(context, RulesScreen(user: user)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  GlassCard(
                    radius: 20,
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.purpleAccent.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.notifications_active_rounded,
                            color: AppColors.cyan,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Campus updates',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Open notifications for bus, library, and academic alerts.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Notifications',
                          onPressed: () =>
                              _open(context, NotificationsScreen(user: user)),
                          icon: const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            AppBottomNav(
              currentIndex: 0,
              onTap: (index) => _handleNav(context, index),
              items: const [
                AppBottomNavItem(label: 'Home', icon: Icons.home_rounded),
                AppBottomNavItem(label: 'Chat', icon: Icons.chat_bubble_rounded),
                AppBottomNavItem(label: 'Bus', icon: Icons.directions_bus_rounded),
                AppBottomNavItem(label: 'Library', icon: Icons.local_library_rounded),
                AppBottomNavItem(label: 'Profile', icon: Icons.person_rounded),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _handleNav(BuildContext context, int index) {
    if (index == 0) return;
    final screens = [
      this,
      ChatbotScreen(user: user),
      BusScreen(user: user),
      LibraryScreen(user: user),
      ProfileScreen(user: user),
    ];
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => screens[index]),
    );
  }
}

class _Header extends StatelessWidget {
  final String name;
  final Map<String, dynamic> user;

  const _Header({required this.name, required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome back,',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ProfileScreen(user: user)),
          ),
          borderRadius: BorderRadius.circular(22),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
            ),
            child: const Icon(Icons.account_circle_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String studentId;
  final Map<String, dynamic> user;

  const _SummaryCard({
    required this.studentId,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 26,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Student ID',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      studentId,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const StatusBadge(label: 'ACTIVE', tone: StatusBadgeTone.success),
            ],
          ),
          const SizedBox(height: 18),
          Divider(color: Colors.white.withValues(alpha: 0.10), height: 1),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _StudentMetric(
                  label: 'Current GPA',
                  value: _metricValue(user, const ['gpa'], 'N/A'),
                  color: AppColors.cyan,
                ),
              ),
              Expanded(
                child: _StudentMetric(
                  label: 'Credits',
                  value: _creditsValue(user),
                  color: AppColors.purple3,
                ),
              ),
              Expanded(
                child: _StudentMetric(
                  label: 'Class Rank',
                  value: _metricValue(user, const ['class_rank'], 'N/A'),
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _metricValue(
  Map<String, dynamic> user,
  List<String> keys,
  String fallback,
) {
  for (final key in keys) {
    final value = user[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString();
    }
  }
  return fallback;
}

String _creditsValue(Map<String, dynamic> user) {
  final completed = user['credits_completed'];
  final total = user['total_credits'];
  if (completed != null && total != null) return '$completed/$total';
  if (completed != null) return completed.toString();
  return 'N/A';
}

class _StudentMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StudentMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
