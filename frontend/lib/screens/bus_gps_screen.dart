import 'package:flutter/material.dart';

class BusGpsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> buses;
  final String? focusedBusId;

  const BusGpsScreen({
    super.key,
    required this.buses,
    this.focusedBusId,
  });

  static const Color bgPrimary = Color(0xFF0A0E27);
  static const Color bgSecondary = Color(0xFF1E0A3C);
  static const Color neonCyan = Color(0xFF00F0FF);
  static const Color electricBlue = Color(0xFF0080FF);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFE0E0E0);
  static const Color mutedText = Color(0xFFB8C1D9);

  double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'full':
        return const Color(0xFFDC2626);
      case 'offline':
        return const Color(0xFF64748B);
      case 'maintenance':
        return const Color(0xFFF59E0B);
      case 'active':
      default:
        return const Color(0xFF10B981);
    }
  }

  @override
  Widget build(BuildContext context) {
    final validBuses = buses.where((bus) {
      final lat = _toDouble(bus['latitude']);
      final lng = _toDouble(bus['longitude']);
      return lat != 0 || lng != 0;
    }).toList();

    double minLat = 0;
    double maxLat = 1;
    double minLng = 0;
    double maxLng = 1;

    if (validBuses.isNotEmpty) {
      minLat = validBuses
          .map((b) => _toDouble(b['latitude']))
          .reduce((a, b) => a < b ? a : b);
      maxLat = validBuses
          .map((b) => _toDouble(b['latitude']))
          .reduce((a, b) => a > b ? a : b);
      minLng = validBuses
          .map((b) => _toDouble(b['longitude']))
          .reduce((a, b) => a < b ? a : b);
      maxLng = validBuses
          .map((b) => _toDouble(b['longitude']))
          .reduce((a, b) => a > b ? a : b);

      if (minLat == maxLat) maxLat = minLat + 0.001;
      if (minLng == maxLng) maxLng = minLng + 0.001;
    }

    return Scaffold(
      backgroundColor: bgPrimary,
      appBar: AppBar(
        title: const Text(
          'GPS Bus View',
          style: TextStyle(
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
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF10204F).withOpacity(0.95),
                    const Color(0xFF1A0F49).withOpacity(0.95),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
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
              child: const Row(
                children: [
                  Icon(Icons.gps_fixed_rounded, color: neonCyan),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Demo GPS view for current bus positions based on latitude and longitude.',
                      style: TextStyle(
                        color: textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: neonCyan.withOpacity(0.12),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _GridPainter(),
                            ),
                          ),
                          if (validBuses.isEmpty)
                            const Center(
                              child: Text(
                                'No GPS coordinates available.',
                                style: TextStyle(
                                  color: mutedText,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          else
                            ...validBuses.map((bus) {
                              final lat = _toDouble(bus['latitude']);
                              final lng = _toDouble(bus['longitude']);

                              final dx = ((lng - minLng) / (maxLng - minLng))
                                  .clamp(0.05, 0.95);
                              final dy = (1 - ((lat - minLat) / (maxLat - minLat)))
                                  .clamp(0.08, 0.92);

                              final left = dx * constraints.maxWidth;
                              final top = dy * constraints.maxHeight;

                              final status =
                                  bus['status']?.toString() ?? 'active';
                              final color = _statusColor(status);
                              final isFocused = focusedBusId != null &&
                                  (
                                    bus['bus_number']?.toString() == focusedBusId ||
                                    bus['bus_id']?.toString() == focusedBusId ||
                                    bus['id']?.toString() == focusedBusId
                                  );

                              return Positioned(
                                left: left - 18,
                                top: top - 18,
                                child: Column(
                                  children: [
                                    Container(
                                      width: isFocused ? 42 : 34,
                                      height: isFocused ? 42 : 34,
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.18),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: color,
                                          width: isFocused ? 2.4 : 1.8,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: color.withOpacity(0.35),
                                            blurRadius: isFocused ? 22 : 14,
                                            spreadRadius: isFocused ? 2 : 1,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.directions_bus_filled_rounded,
                                        size: isFocused ? 22 : 18,
                                        color: color,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.45),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        'Bus ${bus['bus_number']}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Container(
              height: 170,
              margin: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: neonCyan.withOpacity(0.10),
                ),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.all(14),
                scrollDirection: Axis.horizontal,
                itemCount: buses.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final bus = buses[index];
                  final status = bus['status']?.toString() ?? 'active';
                  final color = _statusColor(status);

                  return Container(
                    width: 220,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: color.withOpacity(0.24),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bus ${bus['bus_number']}',
                          style: const TextStyle(
                            color: textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          bus['route_name']?.toString() ?? '-',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: mutedText,
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Lat: ${_toDouble(bus['latitude']).toStringAsFixed(6)}',
                          style: const TextStyle(
                            color: textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Lng: ${_toDouble(bus['longitude']).toStringAsFixed(6)}',
                          style: const TextStyle(
                            color: textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 1;

    const int divisions = 6;

    for (int i = 1; i < divisions; i++) {
      final dx = size.width * i / divisions;
      final dy = size.height * i / divisions;

      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), linePaint);
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}