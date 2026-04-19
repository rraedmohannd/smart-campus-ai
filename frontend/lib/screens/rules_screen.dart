import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RulesScreen extends StatefulWidget {
  const RulesScreen({super.key});

  @override
  State<RulesScreen> createState() => _RulesScreenState();
}

class _RulesScreenState extends State<RulesScreen> {
  final String _baseUrl = 'http://127.0.0.1:8000';

  bool _loading = true;
  String? _error;
  List<dynamic> _categories = [];

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
          _error = 'Server error: ${response.statusCode}';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Connection error';
      });
    }
  }

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'danger':
        return Colors.red.shade100;
      case 'warning':
        return Colors.orange.shade100;
      default:
        return Colors.blue.shade50;
    }
  }

  IconData _severityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'danger':
        return Icons.warning_amber_rounded;
      case 'warning':
        return Icons.info_outline;
      default:
        return Icons.rule_folder_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rules'),
        backgroundColor: const Color(0xFFB0121B),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index] as Map<String, dynamic>;
                    final rules = (category['rules'] as List?) ?? [];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category['category_name']?.toString() ?? 'Category',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 14),
                            ...rules.map((rule) {
                              final ruleMap = rule as Map<String, dynamic>;
                              final severity =
                                  ruleMap['severity']?.toString() ?? 'info';

                              return Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _severityColor(severity),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      _severityIcon(severity),
                                      size: 20,
                                      color: Colors.black87,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ruleMap['title']?.toString() ??
                                                'Rule',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            ruleMap['text']?.toString() ?? '',
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}