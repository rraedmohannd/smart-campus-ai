import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../main.dart';

class RulesScreen extends StatefulWidget {
  const RulesScreen({super.key});

  @override
  State<RulesScreen> createState() => _RulesScreenState();
}

class _RulesScreenState extends State<RulesScreen> {
  final String _baseUrl = 'http://localhost:8000';

  bool _loading = true;
  String? _error;
  List<dynamic> _categories = [];
  final Set<int> _expandedCategories = {};

  static const Color bgPrimary = Color(0xFF0A0E27);
  static const Color bgSecondary = Color(0xFF1E0A3C);
  static const Color neonCyan = Color(0xFF00F0FF);
  static const Color electricBlue = Color(0xFF0080FF);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFE0E0E0);
  static const Color mutedText = Color(0xFFB8C1D9);

  bool get _isArabic =>
      SmartCampusApp.of(context).locale.languageCode == 'ar';

  String get _appBarTitle =>
      _isArabic ? 'القوانين والسياسات' : 'Rules & Policies';

  String get _headerTitle =>
      _isArabic ? 'القوانين الجامعية' : 'University Rules';

  String get _headerSubtitle => _isArabic
      ? 'تصفح الأقسام أولًا، ثم افتح أي قسم لعرض القوانين الخاصة به.'
      : 'Browse categories first, then open any category to view its rules.';

  String get _categoriesLabel => _isArabic ? 'الأقسام' : 'Categories';
  String get _rulesLabel => _isArabic ? 'القوانين' : 'Rules';
  String get _statusLabel => _isArabic ? 'الحالة' : 'Status';
  String get _activeLabel => _isArabic ? 'نشط' : 'Active';

  String get _categoryFallback => _isArabic ? 'قسم' : 'Category';
  String get _ruleFallback => _isArabic ? 'قانون' : 'Rule';

  String _rulesInCategoryText(int count) => _isArabic
      ? '$count قوانين في هذا القسم'
      : '$count rules in this category';

  String get _highPriorityText =>
      _isArabic ? 'أولوية عالية' : 'High Priority';
  String get _attentionText => _isArabic ? 'تنبيه' : 'Attention';
  String get _infoText => _isArabic ? 'معلومة' : 'Info';

  String _serverErrorText(int code) =>
      _isArabic ? 'خطأ من الخادم: $code' : 'Server error: $code';

  String get _connectionErrorText =>
      _isArabic ? 'خطأ في الاتصال' : 'Connection error';

  @override
  void initState() {
    super.initState();
    _loadRules();
  }

  Future<void> _loadRules() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/rules/info'),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        setState(() {
          _categories = (data['categories'] as List?) ?? [];
          _loading = false;
          _error = null;
        });
      } else {
        setState(() {
          _loading = false;
          _error = _serverErrorText(response.statusCode);
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _connectionErrorText;
      });
    }
  }

  void _toggleCategory(int index) {
    setState(() {
      if (_expandedCategories.contains(index)) {
        _expandedCategories.remove(index);
      } else {
        _expandedCategories.add(index);
      }
    });
  }

  Color _severityBackground(String severity) {
    switch (severity.toLowerCase()) {
      case 'danger':
        return const Color(0xFF2A1115);
      case 'warning':
        return const Color(0xFF2A1C10);
      default:
        return const Color(0xFF0F2035);
    }
  }

  Color _severityBorder(String severity) {
    switch (severity.toLowerCase()) {
      case 'danger':
        return const Color(0xFFDC2626);
      case 'warning':
        return const Color(0xFFF97316);
      default:
        return const Color(0xFF38BDF8);
    }
  }

  Color _severityForeground(String severity) {
    switch (severity.toLowerCase()) {
      case 'danger':
        return const Color(0xFFFF6B6B);
      case 'warning':
        return const Color(0xFFFFA24C);
      default:
        return const Color(0xFF67E8F9);
    }
  }

  IconData _severityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'danger':
        return Icons.gpp_bad_outlined;
      case 'warning':
        return Icons.warning_amber_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  String _severityLabel(String severity) {
    switch (severity.toLowerCase()) {
      case 'danger':
        return _highPriorityText;
      case 'warning':
        return _attentionText;
      default:
        return _infoText;
    }
  }

  IconData _categoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();

    if (name.contains('academic')) return Icons.school_outlined;
    if (name.contains('attendance')) return Icons.fact_check_outlined;
    if (name.contains('exam')) return Icons.assignment_outlined;
    if (name.contains('library')) return Icons.local_library_outlined;
    if (name.contains('behavior')) return Icons.groups_2_outlined;
    if (name.contains('safety')) return Icons.health_and_safety_outlined;
    if (name.contains('parking') || name.contains('transport')) {
      return Icons.directions_bus_outlined;
    }
    return Icons.rule_folder_outlined;
  }

  Widget _buildHeaderCard() {
    final totalRules = _categories.fold<int>(0, (sum, category) {
      final rules = (category['rules'] as List?) ?? [];
      return sum + rules.length;
    });

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 18),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF10204F).withOpacity(0.95),
            const Color(0xFF1A0F49).withOpacity(0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: neonCyan.withOpacity(0.16),
        ),
        boxShadow: [
          BoxShadow(
            color: neonCyan.withOpacity(0.08),
            blurRadius: 24,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            _isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: neonCyan.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: neonCyan.withOpacity(0.18),
                  ),
                ),
                child: const Icon(
                  Icons.rule_folder_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      _isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      _headerTitle,
                      textAlign: _isArabic ? TextAlign.right : TextAlign.left,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _headerSubtitle,
                      textAlign: _isArabic ? TextAlign.right : TextAlign.left,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeaderStatChip(
                label: _categoriesLabel,
                value: _categories.length.toString(),
              ),
              _HeaderStatChip(
                label: _rulesLabel,
                value: totalRules.toString(),
              ),
              _HeaderStatChip(
                label: _statusLabel,
                value: _activeLabel,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRuleCard(Map<String, dynamic> ruleMap) {
    final severity = ruleMap['severity']?.toString() ?? 'info';
    final bg = _severityBackground(severity);
    final border = _severityBorder(severity);
    final fg = _severityForeground(severity);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: border.withOpacity(0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: border.withOpacity(0.08),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: fg.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _severityIcon(severity),
              size: 21,
              color: fg,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  _isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      ruleMap['title']?.toString() ?? _ruleFallback,
                      textAlign: _isArabic ? TextAlign.right : TextAlign.left,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.5,
                        color: textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: fg.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _severityLabel(severity),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: fg,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  ruleMap['text']?.toString() ?? '',
                  textAlign: _isArabic ? TextAlign.right : TextAlign.left,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.55,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category, int index) {
    final rules = (category['rules'] as List?) ?? [];
    final categoryName = category['category_name']?.toString() ?? _categoryFallback;
    final isExpanded = _expandedCategories.contains(index);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: neonCyan.withOpacity(0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: neonCyan.withOpacity(0.04),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => _toggleCategory(index),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: neonCyan.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: neonCyan.withOpacity(0.16),
                      ),
                    ),
                    child: Icon(
                      _categoryIcon(categoryName),
                      color: neonCyan,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: _isArabic
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          categoryName,
                          textAlign: _isArabic ? TextAlign.right : TextAlign.left,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _rulesInCategoryText(rules.length),
                          textAlign: _isArabic ? TextAlign.right : TextAlign.left,
                          style: const TextStyle(
                            fontSize: 13,
                            color: mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 220),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white70,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Column(
                children: rules.map((rule) {
                  return _buildRuleCard(rule as Map<String, dynamic>);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: neonCyan,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.redAccent.withOpacity(0.12),
            ),
          ),
          child: Text(
            _error!,
            textAlign: _isArabic ? TextAlign.right : TextAlign.left,
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 20),
      children: [
        _buildHeaderCard(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: List.generate(_categories.length, (index) {
              return _buildCategoryCard(
                _categories[index] as Map<String, dynamic>,
                index,
              );
            }),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPrimary,
      appBar: AppBar(
        title: Text(
          _appBarTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              bgPrimary,
              bgSecondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _buildBody(),
      ),
    );
  }
}

class _HeaderStatChip extends StatelessWidget {
  final String label;
  final String value;

  const _HeaderStatChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12.5,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}