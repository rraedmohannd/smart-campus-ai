import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/search_field.dart';
import '../../core/widgets/smart_ai_background.dart';
import '../../core/widgets/smart_cards.dart';
import '../../services/rules_service.dart';
import 'chatbot_screen.dart';

class RulesScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const RulesScreen({
    super.key,
    this.user = const <String, dynamic>{},
  });

  @override
  State<RulesScreen> createState() => _RulesScreenState();
}

class _RulesScreenState extends State<RulesScreen> {
  final _rulesService = const RulesService();
  final _searchController = TextEditingController();

  List<String> _categories = const [
    'Academic',
    'Registration',
    'Exams',
    'Attendance',
    'Library',
    'Transportation',
  ];
  List<Map<String, dynamic>> _rules = _fallbackRules;
  String _activeCategory = 'Academic';
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        _rulesService.all(),
        _rulesService.categories(),
      ]);
      if (!mounted) return;
      final rules = results[0] as List<Map<String, dynamic>>;
      final categories = results[1]
          .map((item) => item.toString())
          .where((item) => item.trim().isNotEmpty)
          .toList();
      setState(() {
        _rules = rules.isEmpty ? _fallbackRules : rules;
        _categories = categories.isEmpty ? _categories : categories;
        _activeCategory = _categories.first;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _rules = _fallbackRules);
    }
  }

  Future<void> _selectCategory(String category) async {
    setState(() => _activeCategory = category);
    try {
      final rules = await _rulesService.byCategory(category);
      if (!mounted || rules.isEmpty) return;
      setState(() => _rules = rules);
    } catch (_) {
      // Keep the already loaded rules if the category endpoint is unavailable.
    }
  }

  List<Map<String, dynamic>> get _visibleRules {
    final query = _query.trim().toLowerCase();
    return _rules.where((rule) {
      final category = _category(rule).toLowerCase();
      final matchesCategory =
          category == _activeCategory.toLowerCase() || _rules.length <= 2;
      final haystack = '${_title(rule)} ${_summary(rule)} $category'.toLowerCase();
      return matchesCategory && (query.isEmpty || haystack.contains(query));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleRules.isEmpty ? _fallbackRules : _visibleRules;

    return SmartAiScaffold(
      dense: true,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(26, 18, 26, 28),
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
                    'University Rules',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Filters',
                  onPressed: _showFilterInfo,
                  icon: const Icon(Icons.tune_rounded, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SearchField(
              controller: _searchController,
              hint: 'Search policies...',
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final active = category == _activeCategory;
                  return InkWell(
                    onTap: () => _selectCategory(category),
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 104,
                      child: Column(
                        children: [
                          Text(
                            category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: active
                                  ? AppColors.textPrimary
                                  : AppColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Spacer(),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            height: 2,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: active
                                  ? AppColors.purple3
                                  : Colors.white.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 26),
            GlassCard(
              radius: 22,
              padding: const EdgeInsets.all(18),
              borderColor: AppColors.purpleAccent.withValues(alpha: 0.48),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: Colors.white),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Confused about a policy?',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12.5,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Ask our AI Assistant for instant clarification.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 82,
                    child: GradientButton(
                      label: 'Ask AI',
                      height: 42,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ChatbotScreen(user: widget.user),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            ...visible.map(
              (rule) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: RuleCard(
                  category: _category(rule),
                  title: _title(rule),
                  summary: _summary(rule),
                  icon: _iconForCategory(_category(rule)),
                  onRead: () => _showPolicy(rule),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPolicy(Map<String, dynamic> rule) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GlassCard(
            radius: 24,
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title(rule),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _summary(rule),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFilterInfo() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.glass,
          title: const Text('Filters'),
          content: const Text(
            'Use the category tabs and search field to filter university rules.',
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

String _title(Map<String, dynamic> rule) {
  return (rule['title'] ?? rule['name'] ?? 'Minimum GPA Requirements').toString();
}

String _summary(Map<String, dynamic> rule) {
  return (rule['summary'] ??
          rule['description'] ??
          rule['text'] ??
          rule['content'] ??
          'Students must maintain a cumulative GPA of 2.0 to remain in good academic standing. Falling below this threshold for two consecutive semesters may trigger academic probation.')
      .toString();
}

String _category(Map<String, dynamic> rule) {
  return (rule['category'] ?? rule['category_name'] ?? 'Academic').toString();
}

IconData _iconForCategory(String category) {
  final lower = category.toLowerCase();
  if (lower.contains('exam')) return Icons.assignment_rounded;
  if (lower.contains('library')) return Icons.local_library_rounded;
  if (lower.contains('transport')) return Icons.directions_bus_rounded;
  if (lower.contains('attendance')) return Icons.fact_check_rounded;
  return Icons.policy_rounded;
}

const _fallbackRules = [
  {
    'category': 'Academic',
    'title': 'Minimum GPA Requirements',
    'summary':
        'Students must maintain a cumulative GPA of 2.0 to remain in good academic standing. Falling below this threshold for two consecutive semesters may trigger academic probation.',
  },
  {
    'category': 'Exams',
    'title': 'Missed Examination Policy',
    'summary':
        'Medical certificates for missed exams must be submitted within 48 hours of the scheduled exam time. Makeup exams are at the discretion of the academic department.',
  },
];
