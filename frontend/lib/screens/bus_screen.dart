import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../main.dart';
import 'bus_gps_screen.dart';

class BusScreen extends StatefulWidget {
  const BusScreen({super.key});

  @override
  State<BusScreen> createState() => _BusScreenState();
}

class _BusScreenState extends State<BusScreen> {
  final String _baseUrl = 'http://localhost:8000';
  final TextEditingController _searchController = TextEditingController();

  bool _loading = true;
  String? _error;
  List<dynamic> _buses = [];
  String _searchQuery = '';

  static const Color bgPrimary = Color(0xFF0A0E27);
  static const Color bgSecondary = Color(0xFF1E0A3C);
  static const Color neonCyan = Color(0xFF00F0FF);
  static const Color electricBlue = Color(0xFF0080FF);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFE0E0E0);
  static const Color mutedText = Color(0xFFB8C1D9);

  bool get _isArabic =>
      SmartCampusApp.of(context).locale.languageCode == 'ar';

  String get _screenTitle => _isArabic ? 'الباصات والنقل' : 'Bus & Transport';
  String get _headerTitle => _isArabic ? 'نظام الباصات الذكي' : 'Smart Bus System';
  String get _headerSubtitle => _isArabic
      ? 'تتبّع الباصات الحية، وراقب المقاعد، والحالة، وافتح شاشة الـ GPS.'
      : 'Track live buses, check seats, monitor status, and open GPS view.';
  String get _busesLabel => _isArabic ? 'الباصات' : 'Buses';
  String get _activeLabel => _isArabic ? 'النشطة' : 'Active';
  String get _fullLabel => _isArabic ? 'ممتلئة' : 'Full';
  String get _openGpsLabel => _isArabic ? 'فتح GPS' : 'Open GPS';
  String get _searchHint => _isArabic
      ? 'ابحث برقم الباص أو المسار أو السائق أو المنطقة أو الحالة...'
      : 'Search by bus number, route, driver, area, or status...';

  String get _driverLabel => _isArabic ? 'السائق' : 'Driver';
  String get _pickupAreaLabel => _isArabic ? 'منطقة الانطلاق' : 'Pickup Area';
  String get _destinationLabel => _isArabic ? 'الوجهة' : 'Destination';
  String get _routeNameLabel => _isArabic ? 'اسم المسار' : 'Route Name';
  String get _etaLabel => _isArabic ? 'وقت الوصول' : 'ETA';
  String get _passengersLabel => _isArabic ? 'الركاب' : 'Passengers';
  String get _availableSeatsLabel => _isArabic ? 'المقاعد المتاحة' : 'Available Seats';
  String get _statusLabel => _isArabic ? 'الحالة' : 'Status';
  String get _latitudeLabel => _isArabic ? 'خط العرض' : 'Latitude';
  String get _longitudeLabel => _isArabic ? 'خط الطول' : 'Longitude';
  String get _closeLabel => _isArabic ? 'إغلاق' : 'Close';
  String get _refreshTooltip => _isArabic ? 'تحديث' : 'Refresh';
  String get _gpsTooltip => 'GPS';

  String get _noMatchingBusesTitle =>
      _isArabic ? 'لا توجد باصات مطابقة' : 'No matching buses found';
  String get _noMatchingBusesSubtitle => _isArabic
      ? 'جرّب البحث بالمسار أو المنطقة أو السائق أو رقم الباص أو الحالة.'
      : 'Try searching by route, area, driver, bus number, or status.';

  String get _connectionErrorText =>
      _isArabic ? 'خطأ في الاتصال' : 'Connection error';

  String _serverErrorText(int code) =>
      _isArabic ? 'خطأ من الخادم: $code' : 'Server error: $code';

  String _busNumberText(dynamic number) =>
      _isArabic ? 'الباص $number' : 'Bus $number';

  String _etaText(dynamic minutes) =>
      _isArabic ? '$minutes دقيقة' : '$minutes min';

  String _seatsText(dynamic seats) =>
      _isArabic ? '$seats مقاعد' : '$seats seats';

  String _statusDisplay(String status) {
    switch (status.toLowerCase()) {
      case 'full':
        return _isArabic ? 'ممتلئ' : 'Full';
      case 'offline':
        return _isArabic ? 'متوقف' : 'Offline';
      case 'maintenance':
        return _isArabic ? 'صيانة' : 'Maintenance';
      case 'active':
      default:
        return _isArabic ? 'نشط' : 'Active';
    }
  }

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
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await http.get(Uri.parse('$_baseUrl/buses/live'));

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _buses = jsonDecode(response.body) as List<dynamic>;
          _loading = false;
          _error = null;
        });
      } else {
        setState(() {
          _error = _serverErrorText(response.statusCode);
          _loading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = _connectionErrorText;
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
      final status = bus['status']?.toString().toLowerCase() ?? '';

      return busNumber.contains(query) ||
          routeName.contains(query) ||
          pickupArea.contains(query) ||
          destination.contains(query) ||
          driver.contains(query) ||
          status.contains(query);
    }).toList();
  }

  Color _getStatusColor(Map<String, dynamic> bus) {
    final status = bus['status']?.toString().toLowerCase() ?? 'active';

    switch (status) {
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

  String _getStatusLabel(Map<String, dynamic> bus) {
    final status = bus['status']?.toString().toLowerCase() ?? 'active';
    return _statusDisplay(status);
  }

  double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  Widget _buildHeaderCard() {
    final activeCount = _buses.where((bus) {
      final busMap = bus as Map<String, dynamic>;
      final status = busMap['status']?.toString().toLowerCase() ?? '';
      return status == 'active';
    }).length;

    final fullCount = _buses.where((bus) {
      final busMap = bus as Map<String, dynamic>;
      final status = busMap['status']?.toString().toLowerCase() ?? '';
      return status == 'full';
    }).length;

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
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: neonCyan.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: neonCyan.withOpacity(0.16),
                  ),
                ),
                child: const Icon(
                  Icons.directions_bus_outlined,
                  color: Colors.white,
                  size: 29,
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
                label: _busesLabel,
                value: _buses.length.toString(),
              ),
              _HeaderStatChip(
                label: _activeLabel,
                value: activeCount.toString(),
              ),
              _HeaderStatChip(
                label: _fullLabel,
                value: fullCount.toString(),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BusGpsScreen(
                        buses: _buses.cast<Map<String, dynamic>>(),
                      ),
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: neonCyan.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: neonCyan.withOpacity(0.18),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.gps_fixed_rounded,
                        color: neonCyan,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _openGpsLabel,
                        style: const TextStyle(
                          color: neonCyan,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
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
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: neonCyan.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: neonCyan.withOpacity(0.03),
            blurRadius: 18,
            spreadRadius: 1,
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
        style: const TextStyle(color: textPrimary),
        decoration: InputDecoration(
          hintText: _searchHint,
          hintStyle: const TextStyle(color: mutedText),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: mutedText,
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
                  icon: const Icon(Icons.close_rounded, color: mutedText),
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
    final Color statusColor = _getStatusColor(bus);
    final String statusLabel = _getStatusLabel(bus);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.86,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF141A35).withOpacity(0.98),
                  const Color(0xFF1B1038).withOpacity(0.98),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              border: Border.all(
                color: neonCyan.withOpacity(0.14),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 56,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 62,
                              height: 62,
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.directions_bus_filled_outlined,
                                color: statusColor,
                                size: 30,
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
                                    _busNumberText(bus['bus_number']),
                                    textAlign: _isArabic ? TextAlign.right : TextAlign.left,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    bus['route_name']?.toString() ??
                                        (_isArabic ? 'مسار' : 'Route'),
                                    textAlign: _isArabic ? TextAlign.right : TextAlign.left,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: mutedText,
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
                                color: statusColor.withOpacity(0.14),
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
                        const SizedBox(height: 24),
                        _detailTile(
                          Icons.person_outline,
                          _driverLabel,
                          bus['driver_name']?.toString() ?? '-',
                        ),
                        _detailTile(
                          Icons.place_outlined,
                          _pickupAreaLabel,
                          bus['pickup_area']?.toString() ?? '-',
                        ),
                        _detailTile(
                          Icons.flag_outlined,
                          _destinationLabel,
                          bus['destination']?.toString() ?? '-',
                        ),
                        _detailTile(
                          Icons.route_outlined,
                          _routeNameLabel,
                          bus['route_name']?.toString() ?? '-',
                        ),
                        _detailTile(
                          Icons.schedule_outlined,
                          _etaLabel,
                          _etaText(bus['estimated_time_minutes']),
                        ),
                        _detailTile(
                          Icons.groups_outlined,
                          _passengersLabel,
                          '${bus['current_passengers']} / ${bus['capacity']}',
                        ),
                        _detailTile(
                          Icons.event_seat_outlined,
                          _availableSeatsLabel,
                          bus['available_seats']?.toString() ?? '0',
                          valueColor: statusColor,
                        ),
                        _detailTile(
                          Icons.info_outline_rounded,
                          _statusLabel,
                          _statusDisplay(bus['status']?.toString() ?? '-'),
                          valueColor: statusColor,
                        ),
                        _detailTile(
                          Icons.my_location_outlined,
                          _latitudeLabel,
                          _toDouble(bus['latitude']).toStringAsFixed(6),
                        ),
                        _detailTile(
                          Icons.location_searching_outlined,
                          _longitudeLabel,
                          _toDouble(bus['longitude']).toStringAsFixed(6),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: textPrimary,
                                  side: BorderSide(
                                    color: neonCyan.withOpacity(0.18),
                                  ),
                                  minimumSize: const Size.fromHeight(54),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(_closeLabel),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    this.context,
                                    MaterialPageRoute(
                                      builder: (_) => BusGpsScreen(
                                        buses: _buses.cast<Map<String, dynamic>>(),
                                        focusedBusId:
                                            bus['bus_number']?.toString(),
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: neonCyan,
                                  foregroundColor: Colors.black,
                                  minimumSize: const Size.fromHeight(54),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                icon: const Icon(Icons.gps_fixed_rounded),
                                label: Text(_openGpsLabel),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _detailTile(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: neonCyan.withOpacity(0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: neonCyan.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: neonCyan,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: valueColor ?? textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactBusCard(Map<String, dynamic> bus) {
    final Color statusColor = _getStatusColor(bus);
    final String statusLabel = _getStatusLabel(bus);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _showBusDetails(bus),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.05),
                  Colors.white.withOpacity(0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: neonCyan.withOpacity(0.08)),
              boxShadow: [
                BoxShadow(
                  color: neonCyan.withOpacity(0.03),
                  blurRadius: 18,
                  spreadRadius: 1,
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
                    crossAxisAlignment:
                        _isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Text(
                        _busNumberText(bus['bus_number']),
                        textAlign: _isArabic ? TextAlign.right : TextAlign.left,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${bus['pickup_area']} → ${bus['destination']}',
                        textAlign: _isArabic ? TextAlign.right : TextAlign.left,
                        style: const TextStyle(
                          fontSize: 14,
                          color: textSecondary,
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
                            text: _etaText(bus['estimated_time_minutes']),
                          ),
                          _MiniInfoChip(
                            icon: Icons.event_seat_outlined,
                            text: _seatsText(bus['available_seats']),
                          ),
                          _MiniInfoChip(
                            icon: Icons.person_outline_rounded,
                            text: bus['driver_name']?.toString() ?? '-',
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
                      color: mutedText,
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
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: neonCyan.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 40,
            color: mutedText,
          ),
          const SizedBox(height: 12),
          Text(
            _isArabic ? 'لا توجد باصات مطابقة' : 'No matching buses found',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _isArabic
                ? 'جرّب البحث بالمسار أو المنطقة أو السائق أو رقم الباص أو الحالة.'
                : 'Try searching by route, area, driver, bus number, or status.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: mutedText,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: neonCyan),
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
              color: Colors.redAccent.withOpacity(0.18),
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

    final buses = _filteredBuses;

    return RefreshIndicator(
      color: neonCyan,
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
      backgroundColor: bgPrimary,
      appBar: AppBar(
        title: Text(
          _screenTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: _refreshTooltip,
            onPressed: _loadBuses,
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: _gpsTooltip,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BusGpsScreen(
                    buses: _buses.cast<Map<String, dynamic>>(),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.gps_fixed_rounded),
          ),
        ],
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
        child: Stack(
          children: [
            Positioned(
              top: -100,
              left: -60,
              child: _GlowCircle(color: neonCyan),
            ),
            Positioned(
              bottom: -120,
              right: -70,
              child: _GlowCircle(color: electricBlue),
            ),
            _buildBody(),
          ],
        ),
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
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
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
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: _BusScreenState.neonCyan.withOpacity(0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: _BusScreenState.mutedText,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              color: _BusScreenState.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final Color color;

  const _GlowCircle({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: 240,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.08),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.18),
            blurRadius: 120,
            spreadRadius: 26,
          ),
        ],
      ),
    );
  }
}