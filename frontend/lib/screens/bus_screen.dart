import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String _baseUrl = 'http://localhost:8000';
const Color primaryRed = Color(0xFF9E1B22);

class BusScreen extends StatefulWidget {
  const BusScreen({super.key});

  @override
  BusScreenState createState() => BusScreenState();
}

class BusScreenState extends State<BusScreen> {
  List<dynamic> _buses = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBuses();
  }

  Future<void> _loadBuses() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await http.get(Uri.parse("$_baseUrl/bus/routes"));
      if (!mounted) return;
      if (response.statusCode == 200) {
        setState(() {
          _buses = jsonDecode(response.body) as List<dynamic>;
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

  Widget _buildRouteCard(dynamic bus) {
    final routeName = bus['route_name']?.toString() ?? 'Unnamed Route';
    final stops = (bus['stops'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final nextArrival = bus['next_arrival']?.toString() ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: ListTile(
        leading: const Icon(Icons.directions_bus, color: primaryRed),
        title: Text(routeName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Next: $nextArrival\nStops: ${stops.join(', ')}', maxLines: 2, overflow: TextOverflow.ellipsis),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bus System"), backgroundColor: primaryRed, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: primaryRed))
            : _error != null
                ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                : _buses.isEmpty
                    ? const Center(child: Text('No bus routes available.', style: TextStyle(color: Colors.grey)))
                    : RefreshIndicator(
                        onRefresh: _loadBuses,
                        child: ListView.builder(
                          itemCount: _buses.length,
                          itemBuilder: (_, i) => _buildRouteCard(_buses[i]),
                        ),
                      ),
      ),
    );
  }
}
