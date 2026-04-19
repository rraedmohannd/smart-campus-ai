import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BusScreen extends StatefulWidget {
  const BusScreen({super.key});

  @override
  State<BusScreen> createState() => _BusScreenState();
}

class _BusScreenState extends State<BusScreen> {
  final String _baseUrl = 'http://127.0.0.1:8000';

  bool _loading = true;
  String? _error;
  List<dynamic> _buses = [];

  @override
  void initState() {
    super.initState();
    _loadBuses();
  }

  Future<void> _loadBuses() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/buses/routes'));

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _buses = jsonDecode(response.body) as List<dynamic>;
          _loading = false;
          _error = null;
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
        _error = 'Connection error';
        _loading = false;
      });
    }
  }

  Color _getColor(int seatsLeft, String status) {
    final normalizedStatus = status.toLowerCase();

    if (normalizedStatus == 'maintenance') return Colors.grey;
    if (normalizedStatus == 'inactive') return Colors.blueGrey;
    if (seatsLeft == 0 || normalizedStatus == 'full') return Colors.red;
    if (seatsLeft < 5) return Colors.orange;
    return Colors.green;
  }

  String _getStatusLabel(int seatsLeft, String status) {
    final normalizedStatus = status.toLowerCase();

    if (normalizedStatus == 'maintenance') return 'Maintenance';
    if (normalizedStatus == 'inactive') return 'Inactive';
    if (seatsLeft == 0 || normalizedStatus == 'full') return 'Full';
    if (seatsLeft < 5) return 'Almost Full';
    return 'Available';
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFFB0121B)),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      height: 220,
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade200,
            Colors.grey.shade300,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.location_on,
            size: 46,
            color: Color(0xFFB0121B),
          ),
          const SizedBox(height: 10),
          const Text(
            'Live Tracking Map',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'GPS demo preview for smart bus monitoring',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusCard(Map<String, dynamic> bus) {
    final int seatsLeft =
        int.tryParse(bus['available_seats'].toString()) ?? 0;
    final String rawStatus = bus['status']?.toString() ?? 'Unknown';
    final Color statusColor = _getColor(seatsLeft, rawStatus);
    final String statusLabel = _getStatusLabel(seatsLeft, rawStatus);

    return Card(
      elevation: 6,
      shadowColor: Colors.black26,
      margin: const EdgeInsets.only(bottom: 18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.red.shade50,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 9,
                    backgroundColor: statusColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bus ${bus['bus_number']}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          bus['route_name']?.toString() ?? 'Route',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                Icons.person_outline,
                'Driver',
                bus['driver_name']?.toString() ?? '-',
              ),
              _buildInfoRow(
                Icons.place_outlined,
                'From',
                bus['pickup_area']?.toString() ?? '-',
              ),
              _buildInfoRow(
                Icons.flag_outlined,
                'To',
                bus['destination']?.toString() ?? '-',
              ),
              _buildInfoRow(
                Icons.schedule_outlined,
                'ETA',
                '${bus['estimated_time_minutes']} min',
              ),
              _buildInfoRow(
                Icons.groups_outlined,
                'Passengers',
                '${bus['current_passengers']} / ${bus['capacity']}',
              ),
              _buildInfoRow(
                Icons.event_seat_outlined,
                'Seats Left',
                bus['available_seats']?.toString() ?? '0',
              ),
              _buildInfoRow(
                Icons.info_outline,
                'Status',
                rawStatus,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: AppBar(
        title: const Text('Smart Bus System'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFFB0121B),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadBuses,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildMapPlaceholder(),
                      ..._buses.map(
                        (bus) => _buildBusCard(bus as Map<String, dynamic>),
                      ),
                    ],
                  ),
                ),
    );
  }
}