import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/smart_ai_background.dart';
import '../../core/widgets/smart_cards.dart';
import '../../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const NotificationsScreen({
    super.key,
    this.user = const <String, dynamic>{},
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _notificationService = const NotificationService();

  List<Map<String, dynamic>> _notifications = const [];
  String _activeTab = 'All';

  String get _userId =>
      (widget.user['id'] ?? widget.user['user_id'] ?? widget.user['student_id'] ?? '20260001')
          .toString();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _notificationService.forUser(_userId);
      if (!mounted) return;
      setState(() => _notifications = data);
    } catch (_) {
      if (!mounted) return;
      setState(() => _notifications = const []);
    }
  }

  List<Map<String, dynamic>> get _visible {
    if (_activeTab == 'All') return _notifications;
    return _notifications.where((item) {
      final type = _type(item).toLowerCase();
      return type == _activeTab.toLowerCase();
    }).toList();
  }

  Future<void> _markRead(Map<String, dynamic> item) async {
    final id = item['id'] ?? item['notification_id'];
    setState(() => item['read'] = true);
    if (id == null) return;
    try {
      await _notificationService.markRead(id);
    } catch (_) {
      // Keep local state; backend may already mark read through another client.
    }
  }

  Future<void> _delete(Map<String, dynamic> item) async {
    final id = item['id'] ?? item['notification_id'];
    setState(() => _notifications.remove(item));
    if (id == null) return;
    try {
      await _notificationService.delete(id);
    } catch (_) {
      // Deletion remains frontend-local if the API is unavailable.
    }
  }

  Future<void> _markAllRead() async {
    final unread = _notifications.where((item) => !_isRead(item)).toList();
    setState(() {
      for (final item in unread) {
        item['read'] = true;
      }
    });
    for (final item in unread) {
      final id = item['id'] ?? item['notification_id'];
      if (id != null) {
        try {
          await _notificationService.markRead(id);
        } catch (_) {}
      }
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
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
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
                      'Notifications',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const Icon(Icons.notifications_rounded, color: AppColors.cyan),
                  TextButton(
                    onPressed: _markAllRead,
                    child: const Text('Mark all read'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _tabs.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final tab = _tabs[index];
                    final active = tab == _activeTab;
                    return ChoiceChip(
                      selected: active,
                      onSelected: (_) => setState(() => _activeTab = tab),
                      label: Text(tab),
                      labelStyle: TextStyle(
                        color: active ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.w800,
                      ),
                      selectedColor: AppColors.purple3,
                      backgroundColor: AppColors.glass.withValues(alpha: 0.82),
                      side: BorderSide(
                        color: AppColors.purpleAccent.withValues(alpha: 0.20),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              if (_visible.isEmpty)
                const GlassCard(
                  radius: 18,
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No notifications are available.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ..._visible.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: NotificationCard(
                    icon: _icon(_type(item)),
                    title: _title(item),
                    message: _message(item),
                    time: _time(item),
                    unread: !_isRead(item),
                    onRead: () => _markRead(item),
                    onDelete: () => _delete(item),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _tabs = ['All', 'Bus', 'Library', 'Academic', 'General'];

String _title(Map<String, dynamic> item) {
  return (item['title'] ?? item['subject'] ?? 'Campus Update').toString();
}

String _message(Map<String, dynamic> item) {
  return (item['message'] ?? item['body'] ?? item['content'] ?? '').toString();
}

String _type(Map<String, dynamic> item) {
  return (item['type'] ?? item['category'] ?? 'General').toString();
}

String _time(Map<String, dynamic> item) {
  return (item['time'] ?? item['created_at'] ?? 'Now').toString();
}

bool _isRead(Map<String, dynamic> item) {
  return item['read'] == true || item['is_read'] == true || item['status'] == 'read';
}

IconData _icon(String type) {
  final lower = type.toLowerCase();
  if (lower.contains('bus')) return Icons.directions_bus_rounded;
  if (lower.contains('library')) return Icons.local_library_rounded;
  if (lower.contains('academic')) return Icons.school_rounded;
  return Icons.notifications_rounded;
}
