import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/section_title.dart';
import '../../core/widgets/smart_ai_background.dart';
import '../../core/widgets/smart_cards.dart';
import '../../services/admin_service.dart';

class AdminDashboard extends StatefulWidget {
  final Map<String, dynamic> user;

  const AdminDashboard({
    super.key,
    this.user = const <String, dynamic>{},
  });

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _adminService = const AdminService();

  Map<String, dynamic> _dashboard = const {};
  List<Map<String, dynamic>> _users = const [];
  List<Map<String, dynamic>> _students = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        _adminService.dashboard(),
        _adminService.users(),
        _adminService.students(),
      ]);
      if (!mounted) return;
      setState(() {
        _dashboard = results[0] as Map<String, dynamic>;
        _users = results[1] as List<Map<String, dynamic>>;
        _students = results[2] as List<Map<String, dynamic>>;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _dashboard = const {};
        _users = const [];
        _students = const [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SmartAiScaffold(
      dense: true,
      child: SafeArea(
        child: RefreshIndicator(
          color: AppColors.cyan,
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.cyan.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.grid_view_rounded, color: AppColors.cyan),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Admin Console',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: AppColors.purple3,
                    child: Text(
                      (widget.user['name'] ?? 'AD')
                          .toString()
                          .characters
                          .take(2)
                          .toString()
                          .toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.5,
                children: [
                  DashboardStat(
                    label: 'Users',
                    value: _value('active_users', _users.length),
                    accent: AppColors.cyan,
                  ),
                  DashboardStat(
                    label: 'Students',
                    value: _value('students', _students.length),
                    accent: AppColors.purple3,
                  ),
                  DashboardStat(
                    label: 'AI Requests',
                    value: _value('ai_requests', 0),
                    accent: AppColors.success,
                  ),
                  DashboardStat(
                    label: 'Alerts',
                    value: _value('alerts', 0),
                    accent: AppColors.warning,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const _ChartCard(),
              const SizedBox(height: 24),
              const SectionTitle(title: 'System Health'),
              const SizedBox(height: 12),
              const AdminHealthCard(
                title: 'AI Inference Engine',
                subtitle: 'Operational',
                statusColor: AppColors.success,
                icon: Icons.memory_rounded,
              ),
              const SizedBox(height: 14),
              const AdminHealthCard(
                title: 'IoT Bus Tracking',
                subtitle: 'High Latency',
                statusColor: AppColors.warning,
                icon: Icons.directions_bus_rounded,
              ),
              const SizedBox(height: 14),
              const AdminHealthCard(
                title: 'Database Cluster',
                subtitle: 'Operational',
                statusColor: AppColors.success,
                icon: Icons.storage_rounded,
              ),
              const SizedBox(height: 14),
              const AdminHealthCard(
                title: 'Auth Gateway',
                subtitle: 'Operational',
                statusColor: AppColors.success,
                icon: Icons.shield_rounded,
              ),
              const SizedBox(height: 22),
              AiInsightCard(
                message:
                    'Campus AI suggests deploying an extra bus on Route 3 due to a predicted 20% spike in student movement.',
                actionLabel: 'Apply Recommendation',
                onAction: _showRecommendationDialog,
              ),
              const SizedBox(height: 24),
              SectionTitle(
                title: 'Management',
                action: 'Notify',
                onAction: _openNotificationComposer,
              ),
              const SizedBox(height: 12),
              _ManagementList(
                title: 'Users',
                items: _users,
                empty: 'No users returned by backend.',
                onAdd: () => _openUserEditor(),
                onEdit: (user) => _openUserEditor(user: user),
                onDelete: _deleteUser,
              ),
              const SizedBox(height: 14),
              _ManagementList(
                title: 'Students',
                items: _students,
                empty: 'No students returned by backend.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteUser(Map<String, dynamic> user) async {
    final id = user['id'] ?? user['user_id'];
    setState(() => _users.remove(user));
    if (id == null) return;
    try {
      await _adminService.deleteUser(id);
    } catch (_) {}
  }

  void _openUserEditor({Map<String, dynamic>? user}) {
    final name = TextEditingController(
      text: user == null ? '' : _displayName(user),
    );
    final email = TextEditingController(
      text: user == null ? '' : (user['email'] ?? '').toString(),
    );
    final role = TextEditingController(
      text: user == null ? 'student' : (user['role'] ?? 'student').toString(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            18,
            18,
            18,
            18 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: GlassCard(
            radius: 26,
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user == null ? 'Add User' : 'Edit User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                _AdminTextField(controller: name, hint: 'Name'),
                const SizedBox(height: 10),
                _AdminTextField(controller: email, hint: 'Email'),
                const SizedBox(height: 10),
                _AdminTextField(controller: role, hint: 'Role'),
                const SizedBox(height: 18),
                GradientButton(
                  label: user == null ? 'Create User' : 'Save User',
                  onPressed: () async {
                    final body = {
                      'name': name.text.trim(),
                      'email': email.text.trim(),
                      'role': role.text.trim(),
                    };
                    if (user == null) {
                      final created = await _adminService.createUser(body);
                      setState(() => _users.insert(0, {...body, ...created}));
                    } else {
                      final id = user['id'] ?? user['user_id'];
                      if (id != null) {
                        await _adminService.updateUser(id, body);
                      }
                      setState(() => user.addAll(body));
                    }
                    if (context.mounted) Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _value(String key, Object fallback) {
    return (_dashboard[key] ?? _dashboard['total_$key'] ?? fallback).toString();
  }

  void _openNotificationComposer() {
    final title = TextEditingController();
    final message = TextEditingController();
    final type = TextEditingController(text: 'General');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            18,
            18,
            18,
            18 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: GlassCard(
            radius: 26,
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Create Notification',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                _AdminTextField(controller: title, hint: 'Title'),
                const SizedBox(height: 10),
                _AdminTextField(controller: type, hint: 'Type'),
                const SizedBox(height: 10),
                _AdminTextField(
                  controller: message,
                  hint: 'Message',
                  maxLines: 3,
                ),
                const SizedBox(height: 18),
                GradientButton(
                  label: 'Send Notification',
                  onPressed: () async {
                    await _adminService.createNotification({
                      'title': title.text.trim(),
                      'message': message.text.trim(),
                      'type': type.text.trim(),
                    });
                    if (context.mounted) Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRecommendationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.glass,
          title: const Text('Recommendation'),
          content: const Text(
            'Recommendation noted. Transport dispatch can adjust fleet capacity from the Transport Control dashboard.',
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

class _ChartCard extends StatelessWidget {
  const _ChartCard();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 24,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: SizedBox(
        height: 128,
        child: CustomPaint(
          painter: _ChartPainter(),
          child: const Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Campus Load Forecast',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final axis = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1;
    for (var i = 1; i < 4; i++) {
      final y = size.height * (0.28 + i * 0.16);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), axis);
    }

    final path = Path()
      ..moveTo(0, size.height * 0.70)
      ..cubicTo(
        size.width * 0.22,
        size.height * 0.58,
        size.width * 0.36,
        size.height * 0.15,
        size.width * 0.50,
        size.height * 0.42,
      )
      ..cubicTo(
        size.width * 0.64,
        size.height * 0.70,
        size.width * 0.76,
        size.height * 0.32,
        size.width,
        size.height * 0.20,
      );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        colors: [AppColors.cyan, AppColors.purple3],
      ).createShader(Offset.zero & size);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ManagementList extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final String empty;
  final VoidCallback? onAdd;
  final ValueChanged<Map<String, dynamic>>? onEdit;
  final ValueChanged<Map<String, dynamic>>? onDelete;

  const _ManagementList({
    required this.title,
    required this.items,
    required this.empty,
    this.onAdd,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (onAdd != null)
                TextButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Text(empty, style: const TextStyle(color: AppColors.textSecondary))
          else
            ...items.take(4).map((item) {
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: AppColors.purple3.withValues(alpha: 0.22),
                  child: Text(
                    _initials(item),
                    style: const TextStyle(
                      color: AppColors.cyan,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                title: Text(
                  _displayName(item),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                subtitle: Text(
                  (item['role'] ?? item['student_id'] ?? item['email'] ?? 'Active')
                      .toString(),
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                trailing: onEdit == null && onDelete == null
                    ? null
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (onEdit != null)
                            IconButton(
                              tooltip: 'Edit',
                              onPressed: () => onEdit!(item),
                              icon: const Icon(
                                Icons.edit_rounded,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          if (onDelete != null)
                            IconButton(
                              tooltip: 'Delete',
                              onPressed: () => onDelete!(item),
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: AppColors.danger,
                              ),
                            ),
                        ],
                      ),
              );
            }),
        ],
      ),
    );
  }
}

class _AdminTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  const _AdminTextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.bgDark2.withValues(alpha: 0.72),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.purpleAccent.withValues(alpha: 0.20),
          ),
        ),
      ),
    );
  }
}

String _displayName(Map<String, dynamic> item) {
  return (item['name'] ?? item['full_name'] ?? item['username'] ?? item['email'] ?? 'User')
      .toString();
}

String _initials(Map<String, dynamic> item) {
  final words = _displayName(item).trim().split(RegExp(r'\s+'));
  if (words.isEmpty) return 'U';
  return words.take(2).map((word) => word.characters.first).join().toUpperCase();
}
