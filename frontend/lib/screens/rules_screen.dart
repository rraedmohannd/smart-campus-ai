import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String _baseUrl = 'http://localhost:8000';
const Color primaryRed = Color(0xFF9E1B22);

class RulesScreen extends StatefulWidget {
  const RulesScreen({super.key});

  @override
  RulesScreenState createState() => RulesScreenState();
}

class RulesScreenState extends State<RulesScreen> {
  List<dynamic> _rules = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRules();
  }

  Future<void> _loadRules() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await http.get(Uri.parse("$_baseUrl/rules"));
      if (!mounted) return;
      if (response.statusCode == 200) {
        setState(() {
          _rules = jsonDecode(response.body) as List<dynamic>;
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Server error: ${response.statusCode}';
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Network error';
        _loading = false;
      });
    }
  }

  Widget _buildRuleCard(dynamic rule) {
    final title = rule['title']?.toString() ?? 'Rule';
    final desc = rule['description']?.toString() ?? '';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: ListTile(
        leading: const Icon(Icons.rule, color: primaryRed),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rules"), backgroundColor: primaryRed, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: primaryRed))
            : _error != null
                ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                : _rules.isEmpty
                    ? const Center(child: Text('No rules available.', style: TextStyle(color: Colors.grey)))
                    : RefreshIndicator(
                        onRefresh: _loadRules,
                        child: ListView.builder(
                          itemCount: _rules.length,
                          itemBuilder: (_, i) => _buildRuleCard(_rules[i]),
                        ),
                      ),
      ),
    );
  }
}
