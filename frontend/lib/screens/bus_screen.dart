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
  final TextEditingController _searchController = TextEditingController();

  bool _loading = true;
  String? _error;
  List<dynamic> _buses = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadBuses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Connection error';
        _loading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredBuses {
    final query = _searchQuery.trim().toLowerCase();

    final buses = _buses.cast<Map<String, dynamic>>();

    if (query.isEmpty) return buses;

    return buses.where((bus) {
      final busNumber = bus['bus_number']?.toString().toLowerCase() ?? '';
      final routeName = bus['route_name']?.toString().toLowerCase() ?? '';
      final pickupArea = bus['pickup_area']?.toString().toLowerCase() ?? '';
      final destination = bus['destination']?.toString().toLowerCase() ?? '';
      final driver = bus['driver_name']?.toString().toLowerCase() ?? '';

      return busNumber.contains(query) ||
          routeName.contains(query) ||
          pickupArea.contains(query) ||
          destination.contains(query) ||
          driver.contains(query);
    }).toList();
  }

  Color _getStatusColor(int seatsLeft, String status) {
    final normalizedStatus = status.toLowerCase();

    if (normalizedStatus == 'maintenance') return const Color(0xFF6B7280);
    if (normalizedStatus == 'inactive') return const Color(0xFF475569);
    if (seatsLeft == 0 || normalizedStatus == 'full') {
      return const Color(0xFFDC2626);
    }
    if (seatsLeft < 5) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  String _getStatusLabel(int seatsLeft, String status) {
    final normalizedStatus = status.toLowerCase();

    if (normalizedStatus == 'maintenance') return 'Maintenance';
    if (normalizedStatus == 'inactive') return 'Inactive';
    if (seatsLeft == 0 || normalizedStatus == 'full') return 'Full';
    if (seatsLeft < 5) return 'Almost Full';
    return 'Available';
  }

  Widget _buildHeaderCard() {
    final activeCount = _buses.where((bus) {
      final busMap = bus as Map<String, dynamic>;
      final status = busMap['status']?.toString().toLowerCase() ?? '';
      return status == 'active';
    }).length;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 18),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E293B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFF06B6D4).withOpacity(0.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.directions_bus_outlined,
                  color: Colors.white,
                  size: 29,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Smart Bus System',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Search routes, check ETA, and open each bus for full transport details.',
                      style: TextStyle(
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
                label: 'Routes',
                value: _buses.length.toString(),
              ),
              _HeaderStatChip(
                label: 'Active',
                value: activeCount.toString(),
              ),
              const _HeaderStatChip(
                label: 'Mode',
                value: 'Live Demo',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search by area, route, bus number, or driver...',
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF64748B),
          ),
          suffixIcon: _searchQuery.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  void _showBusDetails(Map<String, dynamic> bus) {
    final int seatsLeft = int.tryParse(bus['available_seats'].toString()) ?? 0;
    final String rawStatus = bus['status']?.toString() ?? 'Unknown';
    final Color statusColor = _getStatusColor(seatsLeft, rawStatus);
    final String statusLabel = _getStatusLabel(seatsLeft, rawStatus);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 720),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          Icons.directions_bus_filled_outlined,
                          color: statusColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bus ${bus['bus_number']}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              bus['route_name']?.toString() ?? 'Route',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isSmall = constraints.maxWidth < 560;

                      return GridView.count(
                        crossAxisCount: isSmall ? 1 : 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: isSmall ? 4.2 : 3.0,
                        children: [
                          _buildDetailTile(
                            icon: Icons.person_outline,
                            label: 'Driver',
                            value: bus['driver_name']?.toString() ?? '-',
                          ),
                          _buildDetailTile(
                            icon: Icons.place_outlined,
                            label: 'From',
                            value: bus['pickup_area']?.toString() ?? '-',
                          ),
                          _buildDetailTile(
                            icon: Icons.flag_outlined,
                            label: 'To',
                            value: bus['destination']?.toString() ?? '-',
                          ),
                          _buildDetailTile(
                            icon: Icons.schedule_outlined,
                            label: 'ETA',
                            value: '${bus['estimated_time_minutes']} min',
                          ),
                          _buildDetailTile(
                            icon: Icons.groups_outlined,
                            label: 'Passengers',
                            value:
                                '${bus['current_passengers']} / ${bus['capacity']}',
                          ),
                          _buildDetailTile(
                            icon: Icons.event_seat_outlined,
                            label: 'Seats Left',
                            value: bus['available_seats']?.toString() ?? '0',
                            valueColor: statusColor,
                          ),
                          _buildDetailTile(
                            icon: Icons.info_outline_rounded,
                            label: 'Status',
                            value: rawStatus,
                            valueColor: statusColor,
                          ),
                          _buildDetailTile(
                            icon: Icons.route_outlined,
                            label: 'Route Name',
                            value: bus['route_name']?.toString() ?? '-',
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 22),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF06B6D4).withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 19,
              color: const Color(0xFF06B6D4),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF475569),
                ),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      color: valueColor ?? const Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactBusCard(Map<String, dynamic> bus) {
    final int seatsLeft = int.tryParse(bus['available_seats'].toString()) ?? 0;
    final String rawStatus = bus['status']?.toString() ?? 'Unknown';
    final Color statusColor = _getStatusColor(seatsLeft, rawStatus);
    final String statusLabel = _getStatusLabel(seatsLeft, rawStatus);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _showBusDetails(bus),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black.withOpacity(0.04)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    Icons.directions_bus_filled_outlined,
                    color: statusColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bus ${bus['bus_number']}',
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${bus['pickup_area']} → ${bus['destination']}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _MiniInfoChip(
                            icon: Icons.schedule_outlined,
                            text: '${bus['estimated_time_minutes']} min',
                          ),
                          _MiniInfoChip(
                            icon: Icons.event_seat_outlined,
                            text: '${bus['available_seats']} seats',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Color(0xFF94A3B8),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySearchState() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 40,
            color: Color(0xFF94A3B8),
          ),
          SizedBox(height: 12),
          Text(
            'No matching buses found',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Try searching by route, area, driver, or bus number.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF64748B),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _error!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    final buses = _filteredBuses;

    return RefreshIndicator(
      onRefresh: _loadBuses,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 20),
        children: [
          _buildHeaderCard(),
          _buildSearchBar(),
          if (buses.isEmpty)
            _buildEmptySearchState()
          else
            ...buses.map(_buildCompactBusCard),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Bus & Transport',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF8FAFC),
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: _buildBody(),
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

class _MiniInfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniInfoChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: const Color(0xFF64748B),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF475569),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}