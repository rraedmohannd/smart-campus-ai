import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/section_title.dart';
import '../../core/widgets/smart_ai_background.dart';
import '../../core/widgets/smart_cards.dart';
import '../../services/bus_service.dart';

class BusScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const BusScreen({
    super.key,
    this.user = const <String, dynamic>{},
  });

  @override
  State<BusScreen> createState() => _BusScreenState();
}

class _BusScreenState extends State<BusScreen> {
  final _busService = const BusService();
  List<Map<String, dynamic>> _buses = const [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final merged = await _busService.all();
      final deduped = <String, Map<String, dynamic>>{};
      for (final bus in merged) {
        deduped[_busId(bus)] = bus;
      }
      if (!mounted) return;
      setState(() {
        _buses = deduped.values.toList();
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _buses = const [];
        _error = 'Bus data is unavailable right now.';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String get _fleetSuggestion {
    if (_buses.isEmpty) {
      return 'AI Suggestion: live fleet recommendations will appear when bus data is available.';
    }

    Map<String, dynamic>? busiest;
    for (final bus in _buses) {
      if (busiest == null || _occupancy(bus) > _occupancy(busiest)) {
        busiest = bus;
      }
    }

    if (busiest == null) {
      return 'AI Suggestion: check available seats before leaving campus.';
    }

    return 'AI Suggestion: ${_busName(busiest)} is at ${_occupancy(busiest).round()}% occupancy with ${_availableSeats(busiest)} seats available.';
  }

  @override
  Widget build(BuildContext context) {
    return SmartAiScaffold(
      dense: true,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                color: AppColors.cyan,
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(30, 12, 30, 24),
                  children: [
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Back',
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Smart Bus Tracking',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.cyan.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.smart_toy_rounded,
                            color: AppColors.cyan,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _MapPlaceholder(buses: _buses),
                    const SizedBox(height: 18),
                    GlassCard(
                      radius: 20,
                      padding: const EdgeInsets.all(18),
                      borderColor: AppColors.cyan,
                      child: Row(
                        children: [
                          const Icon(Icons.lightbulb_rounded, color: AppColors.cyan),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _fleetSuggestion,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12.5,
                                height: 1.25,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SectionTitle(
                      title: 'Available Shuttles',
                      action: _loading ? 'Loading' : 'Refresh',
                      onAction: _loading ? null : _load,
                    ),
                    const SizedBox(height: 12),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GlassCard(
                          radius: 18,
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    if (!_loading && _buses.isEmpty && _error == null)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: GlassCard(
                          radius: 18,
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'No buses are available in the database yet.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ..._buses.map(
                      (bus) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: BusCard(
                          busName: _busName(bus),
                          route: _route(bus),
                          eta: _eta(bus),
                          passengers: _passengers(bus),
                          driver: _driver(bus),
                          status: _status(bus),
                          availableSeats: _availableSeats(bus),
                          occupancy: _occupancy(bus),
                          onTrack: () => _showLiveDetails(bus),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AppBottomNav(
              currentIndex: 1,
              onTap: _handleNav,
              items: const [
                AppBottomNavItem(label: 'Home', icon: Icons.home_rounded),
                AppBottomNavItem(label: 'Bus', icon: Icons.directions_bus_rounded),
                AppBottomNavItem(label: 'AI Chat', icon: Icons.chat_bubble_rounded),
                AppBottomNavItem(label: 'Library', icon: Icons.local_library_rounded),
                AppBottomNavItem(label: 'Profile', icon: Icons.person_rounded),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleNav(int index) {
    final routes = [
      '/student-dashboard',
      '/student-bus',
      '/student-chat',
      '/student-library',
      '/student-profile',
    ];
    if (index == 1) return;
    Navigator.of(context).pushReplacementNamed(
      routes[index],
      arguments: widget.user,
    );
  }

  void _showLiveDetails(Map<String, dynamic> bus) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(18),
          child: GlassCard(
            radius: 26,
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _busName(bus),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_route(bus)}\n${_passengers(bus)} passengers - ${_availableSeats(bus)} seats available',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 18),
                _MapPlaceholder(buses: [bus], compact: true),
                const SizedBox(height: 18),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  final List<Map<String, dynamic>> buses;
  final bool compact;

  const _MapPlaceholder({
    required this.buses,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: compact ? 170 : 118,
        decoration: BoxDecoration(
          color: AppColors.glassLight.withValues(alpha: 0.72),
          border: Border.all(color: AppColors.cyan.withValues(alpha: 0.18)),
        ),
        // TODO: Replace this preview with Google Maps when an API key is configured.
        child: CustomPaint(
          painter: _CampusMapPainter(buses: buses),
          child: Stack(
            children: [
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.glass.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sensors_rounded, size: 14, color: AppColors.success),
                      SizedBox(width: 6),
                      Text(
                        'System Live',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 14,
                bottom: 14,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.88),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.my_location_rounded, color: Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CampusMapPainter extends CustomPainter {
  final List<Map<String, dynamic>> buses;

  const _CampusMapPainter({required this.buses});

  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;
    final roadThin = Paint()
      ..color = AppColors.cyan.withValues(alpha: 0.18)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width * 0.08, size.height * 0.74)
      ..cubicTo(
        size.width * 0.30,
        size.height * 0.30,
        size.width * 0.58,
        size.height * 0.62,
        size.width * 0.92,
        size.height * 0.22,
      );
    canvas.drawPath(path, road);
    canvas.drawPath(path, roadThin);

    final building = Paint()
      ..color = AppColors.purpleAccent.withValues(alpha: 0.18);
    for (var i = 0; i < 5; i++) {
      final left = size.width * (0.12 + i * 0.17);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, size.height * 0.12, 44, 26 + i * 3),
          const Radius.circular(6),
        ),
        building,
      );
    }

    final points = _markerPoints(size);
    for (final point in points) {
      final dx = point.dx;
      final dy = point.dy;
      final marker = Paint()..color = AppColors.danger;
      canvas.drawCircle(Offset(dx, dy), 13, marker);
      final icon = TextPainter(
        text: const TextSpan(
          text: 'B',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      icon.paint(canvas, Offset(dx - 5, dy - 10));
    }
  }

  List<Offset> _markerPoints(Size size) {
    final coordinates = buses
        .map((bus) => _coordinate(bus))
        .whereType<Offset>()
        .toList(growable: false);

    if (coordinates.isEmpty) {
      return List.generate(buses.length, (i) {
        return Offset(
          size.width * (0.22 + (i % 3) * 0.26),
          size.height * (0.55 - (i % 2) * 0.22),
        );
      });
    }

    final lats = coordinates.map((point) => point.dy).toList();
    final lngs = coordinates.map((point) => point.dx).toList();
    final minLat = lats.reduce((a, b) => a < b ? a : b);
    final maxLat = lats.reduce((a, b) => a > b ? a : b);
    final minLng = lngs.reduce((a, b) => a < b ? a : b);
    final maxLng = lngs.reduce((a, b) => a > b ? a : b);
    final latSpan = (maxLat - minLat).abs() < 0.0001 ? 1.0 : maxLat - minLat;
    final lngSpan = (maxLng - minLng).abs() < 0.0001 ? 1.0 : maxLng - minLng;

    return coordinates.map((point) {
      final x = ((point.dx - minLng) / lngSpan).clamp(0.0, 1.0);
      final y = ((point.dy - minLat) / latSpan).clamp(0.0, 1.0);
      return Offset(
        size.width * (0.18 + x * 0.64),
        size.height * (0.78 - y * 0.56),
      );
    }).toList();
  }

  @override
  bool shouldRepaint(covariant _CampusMapPainter oldDelegate) {
    return oldDelegate.buses.length != buses.length;
  }
}

String _busId(Map<String, dynamic> bus) {
  return (bus['id'] ??
          bus['bus_id'] ??
          bus['bus_number'] ??
          bus['number'] ??
          bus.hashCode)
      .toString();
}

String _busName(Map<String, dynamic> bus) {
  final raw = bus['bus_number'] ?? bus['number'] ?? bus['name'] ?? '03';
  final text = raw.toString().padLeft(2, '0');
  return text.toLowerCase().startsWith('bus') ? text : 'Bus $text';
}

String _route(Map<String, dynamic> bus) {
  final from = bus['pickup_area'] ?? bus['from'] ?? bus['origin'];
  final to = bus['destination'] ?? bus['to'];
  if (from != null && to != null) return '$from -> $to';
  return (bus['route_name'] ?? bus['route'] ?? 'N/A').toString();
}

String _eta(Map<String, dynamic> bus) {
  final value = bus['estimated_time'] ??
      bus['eta'] ??
      bus['estimated_time_minutes'] ??
      bus['eta_minutes'];
  if (value == null || value.toString().trim().isEmpty) return 'N/A';
  final text = value.toString();
  return text.contains('min') ? text : '$text mins';
}

String _passengers(Map<String, dynamic> bus) {
  final current = bus['current_passengers'] ?? bus['passengers'] ?? 'N/A';
  final capacity = bus['capacity'] ?? 'N/A';
  return '$current / $capacity';
}

String _driver(Map<String, dynamic> bus) {
  return (bus['driver_name'] ?? bus['driver'] ?? 'N/A').toString();
}

String _availableSeats(Map<String, dynamic> bus) {
  final value = bus['available_seats'];
  if (value != null) return value.toString();
  final capacity = int.tryParse((bus['capacity'] ?? '').toString());
  final current = int.tryParse((bus['current_passengers'] ?? '').toString());
  if (capacity != null && current != null) return '${capacity - current}';
  return 'N/A';
}

String _status(Map<String, dynamic> bus) {
  return (bus['status'] ?? 'N/A').toString();
}

double _occupancy(Map<String, dynamic> bus) {
  final explicit = double.tryParse(
    (bus['occupancy'] ?? bus['occupancy_percent'] ?? '').toString(),
  );
  if (explicit != null) return explicit;
  final current = double.tryParse(
        (bus['current_passengers'] ?? bus['passengers'] ?? 0).toString(),
      ) ??
      0;
  final capacity =
      double.tryParse((bus['capacity'] ?? 1).toString())?.clamp(1, 999) ?? 1;
  return current / capacity * 100;
}

Offset? _coordinate(Map<String, dynamic> bus) {
  final lat = double.tryParse((bus['latitude'] ?? '').toString());
  final lng = double.tryParse((bus['longitude'] ?? '').toString());
  if (lat == null || lng == null) return null;
  return Offset(lng, lat);
}
