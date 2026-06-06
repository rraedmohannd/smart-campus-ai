import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/search_field.dart';
import '../../core/widgets/section_title.dart';
import '../../core/widgets/smart_ai_background.dart';
import '../../core/widgets/smart_cards.dart';
import '../../services/transporter_service.dart';

class TransportDashboard extends StatefulWidget {
  final Map<String, dynamic> user;

  const TransportDashboard({
    super.key,
    this.user = const <String, dynamic>{},
  });

  @override
  State<TransportDashboard> createState() => _TransportDashboardState();
}

class _TransportDashboardState extends State<TransportDashboard> {
  final _service = const TransporterService();
  final _search = TextEditingController();

  Map<String, dynamic> _dashboard = const {};
  List<Map<String, dynamic>> _buses = const [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        _service.dashboard(),
        _service.buses(),
      ]);
      if (!mounted) return;
      final buses = results[1] as List<Map<String, dynamic>>;
      setState(() {
        _dashboard = results[0] as Map<String, dynamic>;
        _buses = buses;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _dashboard = const {};
        _buses = const [];
      });
    }
  }

  List<Map<String, dynamic>> get _visibleBuses {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _buses;
    return _buses.where((bus) {
      return '${_busName(bus)} ${_route(bus)} ${_driver(bus)}'
          .toLowerCase()
          .contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final active = _dashboard['active'] ??
        _dashboard['active_buses'] ??
        _buses.where((bus) => _status(bus) == 'active').length;
    final full = _dashboard['full'] ??
        _dashboard['full_buses'] ??
        _buses.where((bus) => _status(bus) == 'full').length;

    return SmartAiScaffold(
      dense: false,
      child: SafeArea(
        child: RefreshIndicator(
          color: AppColors.cyan,
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transport Control',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Live Fleet Management',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Fleet settings',
                    onPressed: _openSettings,
                    icon: const Icon(Icons.tune_rounded, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: DashboardStat(
                      label: 'Active',
                      value: '$active',
                      accent: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: DashboardStat(
                      label: 'Full',
                      value: '$full',
                      accent: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Center(child: SectionTitle(title: 'Fleet Tracking')),
              const SizedBox(height: 14),
              _FleetMap(buses: _buses),
              const SizedBox(height: 22),
              const Row(
                children: [
                  Icon(Icons.help_rounded, color: AppColors.cyan, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'AI Fleet Insights',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const AiInsightCard(
                title: 'Capacity Alert',
                message:
                    'Review buses above 90% occupancy and dispatch standby capacity when available.',
              ),
              const SizedBox(height: 14),
              const AiInsightCard(
                title: 'Schedule Optimization',
                message:
                    'Evening usage on Route Y has dropped. Suggesting 15m interval increase.',
              ),
              const SizedBox(height: 24),
              GradientButton(
                label: 'Generate Fleet Report',
                onPressed: _showFleetReport,
              ),
              const SizedBox(height: 28),
              SectionTitle(
                title: 'Fleet Buses',
                action: 'Add Bus',
                onAction: () => _openBusEditor(),
              ),
              const SizedBox(height: 12),
              SearchField(
                controller: _search,
                hint: 'Search buses',
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: 14),
              if (_visibleBuses.isEmpty)
                const GlassCard(
                  radius: 18,
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No buses match the current search.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ..._visibleBuses.map(
                (bus) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _FleetBusCard(
                    bus: bus,
                    onEdit: () => _openBusEditor(bus: bus),
                    onDelete: () => _deleteBus(bus),
                    onLogs: () => _openLogs(bus),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteBus(Map<String, dynamic> bus) async {
    final id = bus['id'] ?? bus['bus_id'];
    setState(() => _buses.remove(bus));
    if (id == null) return;
    try {
      await _service.deleteBus(id);
    } catch (_) {}
  }

  Future<void> _openLogs(Map<String, dynamic> bus) async {
    final id = bus['id'] ?? bus['bus_id'] ?? bus['bus_number'];
    var logs = <Map<String, dynamic>>[];
    if (id != null) {
      try {
        logs = await _service.busLogs(id);
      } catch (_) {}
    }
    if (!mounted) return;

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
                  '${_busName(bus)} Logs',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                if (logs.isEmpty)
                  const Text(
                    'No logs are available for this bus yet.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ...logs.take(5).map(
                      (log) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.history_rounded, color: AppColors.cyan),
                        title: Text(
                          (log['event'] ?? log['message'] ?? 'Bus update').toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          (log['time'] ?? log['created_at'] ?? 'Now').toString(),
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openBusEditor({Map<String, dynamic>? bus}) {
    final name = TextEditingController(text: bus == null ? '' : _busName(bus));
    final route = TextEditingController(text: bus == null ? '' : _route(bus));
    final driver = TextEditingController(text: bus == null ? '' : _driver(bus));
    final capacity = TextEditingController(
      text: (bus?['capacity'] ?? 22).toString(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            18,
            18,
            18,
            18 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: GlassCard(
            radius: 26,
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  bus == null ? 'Add Bus' : 'Edit Bus',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                _FleetField(controller: name, hint: 'Bus name or number'),
                const SizedBox(height: 10),
                _FleetField(controller: route, hint: 'Route'),
                const SizedBox(height: 10),
                _FleetField(controller: driver, hint: 'Driver'),
                const SizedBox(height: 10),
                _FleetField(controller: capacity, hint: 'Capacity'),
                const SizedBox(height: 18),
                GradientButton(
                  label: bus == null ? 'Create Bus' : 'Save Bus',
                  onPressed: () async {
                    final body = {
                      'bus_number': name.text.trim(),
                      'route_name': route.text.trim(),
                      'driver_name': driver.text.trim(),
                      'capacity': int.tryParse(capacity.text.trim()) ?? 22,
                      'status': 'active',
                    };
                    if (bus == null) {
                      final created = await _service.createBus(body);
                      setState(() => _buses.insert(0, {...body, ...created}));
                    } else {
                      final id = bus['id'] ?? bus['bus_id'];
                      if (id != null) await _service.updateBus(id, body);
                      setState(() => bus.addAll(body));
                    }
                    if (context.mounted) Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openSettings() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.glass,
          title: const Text('Fleet Settings'),
          content: const Text(
            'Fleet settings are connected to the transport dashboard. Add, edit, delete, and inspect buses from the Fleet Buses section.',
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

  void _showFleetReport() {
    final active = _buses.where((bus) => _status(bus) == 'active').length;
    final full = _buses.where((bus) => _status(bus) == 'full').length;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.glass,
          title: const Text('Fleet Report'),
          content: Text(
            'Total buses: ${_buses.length}\nActive buses: $active\nFull buses: $full',
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

class _FleetMap extends StatelessWidget {
  final List<Map<String, dynamic>> buses;

  const _FleetMap({required this.buses});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 212,
        child: CustomPaint(
          painter: _FleetMapPainter(buses: buses),
          child: Align(
            alignment: Alignment.topLeft,
            child: Container(
              margin: const EdgeInsets.all(14),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.glass.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sensors_rounded, color: AppColors.success, size: 14),
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
        ),
      ),
    );
  }
}

class _FleetMapPainter extends CustomPainter {
  final List<Map<String, dynamic>> buses;

  const _FleetMapPainter({required this.buses});

  @override
  void paint(Canvas canvas, Size size) {
    final base = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF31394A), Color(0xFF1D153A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, base);

    final road = Paint()
      ..color = Colors.white.withValues(alpha: 0.20)
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 4; i++) {
      final y = size.height * (0.20 + i * 0.22);
      canvas.drawLine(Offset(-20, y), Offset(size.width + 20, y + 30), road);
    }

    final route = Paint()
      ..color = AppColors.cyan.withValues(alpha: 0.42)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(size.width * 0.10, size.height * 0.82)
      ..cubicTo(
        size.width * 0.28,
        size.height * 0.32,
        size.width * 0.62,
        size.height * 0.58,
        size.width * 0.88,
        size.height * 0.18,
      );
    canvas.drawPath(path, route);

    for (final point in _markerPoints(size)) {
      canvas.drawCircle(point, 12, Paint()..color = AppColors.danger);
    }
  }

  List<Offset> _markerPoints(Size size) {
    final coordinates = buses
        .map((bus) => _coordinate(bus))
        .whereType<Offset>()
        .toList(growable: false);

    if (coordinates.isEmpty) {
      final count = buses.length > 5 ? 5 : buses.length;
      return List.generate(count, (i) {
        return Offset(
          size.width * (0.18 + i * 0.16),
          size.height * (0.72 - (i % 2) * 0.24),
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

    return coordinates.take(5).map((point) {
      final x = ((point.dx - minLng) / lngSpan).clamp(0.0, 1.0);
      final y = ((point.dy - minLat) / latSpan).clamp(0.0, 1.0);
      return Offset(
        size.width * (0.18 + x * 0.64),
        size.height * (0.78 - y * 0.56),
      );
    }).toList();
  }

  @override
  bool shouldRepaint(covariant _FleetMapPainter oldDelegate) {
    return oldDelegate.buses.length != buses.length;
  }
}

class _FleetBusCard extends StatelessWidget {
  final Map<String, dynamic> bus;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onLogs;

  const _FleetBusCard({
    required this.bus,
    required this.onEdit,
    required this.onDelete,
    required this.onLogs,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.cyan.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.directions_bus_rounded, color: AppColors.cyan),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _busName(bus),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_route(bus)} - ${_driver(bus)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Logs',
            onPressed: onLogs,
            icon: const Icon(Icons.article_outlined, color: AppColors.textSecondary),
          ),
          IconButton(
            tooltip: 'Edit',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_rounded, color: AppColors.textSecondary),
          ),
          IconButton(
            tooltip: 'Delete',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
          ),
        ],
      ),
    );
  }
}

class _FleetField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _FleetField({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.bgDark2.withValues(alpha: 0.76),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

String _busName(Map<String, dynamic> bus) {
  final raw = bus['bus_number'] ?? bus['name'] ?? bus['number'] ?? 'N/A';
  final text = raw.toString();
  return text.toLowerCase().startsWith('bus') ? text : 'Bus $text';
}

String _route(Map<String, dynamic> bus) {
  final from = bus['pickup_area'];
  final to = bus['destination'];
  if (from != null && to != null) return '$from -> $to';
  return (bus['route_name'] ?? bus['route'] ?? 'N/A').toString();
}

String _driver(Map<String, dynamic> bus) {
  return (bus['driver_name'] ?? bus['driver'] ?? 'Assigned Driver').toString();
}

String _status(Map<String, dynamic> bus) {
  return (bus['status'] ?? 'active').toString().toLowerCase();
}

Offset? _coordinate(Map<String, dynamic> bus) {
  final lat = double.tryParse((bus['latitude'] ?? '').toString());
  final lng = double.tryParse((bus['longitude'] ?? '').toString());
  if (lat == null || lng == null) return null;
  return Offset(lng, lat);
}
