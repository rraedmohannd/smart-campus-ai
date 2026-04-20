import 'package:flutter/material.dart';
import 'main.dart';
import 'login_screen.dart';
import 'screens/bus_screen.dart';
import 'screens/chatbot_screen.dart';
import 'screens/library_screen.dart';
import 'screens/rules_screen.dart';

class HomeScreen extends StatefulWidget {
  final String studentId;
  final String name;
  final String token;

  const HomeScreen({
    super.key,
    required this.studentId,
    required this.name,
    required this.token,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color bgPrimary = Color(0xFF0A0E27);
  static const Color bgSecondary = Color(0xFF1E0A3C);
  static const Color neonCyan = Color(0xFF00F0FF);
  static const Color electricBlue = Color(0xFF0080FF);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFE0E0E0);
  static const Color mutedText = Color(0xFFB8C1D9);

  bool get _isArabic =>
      SmartCampusApp.of(context).locale.languageCode == 'ar';

  String get _titleMain => _isArabic ? 'سمارت كامبس' : 'Smart Campus';
  String get _titleAi => 'AI';

  String get _welcomeTitle =>
      _isArabic ? 'مرحبًا، ${widget.name}' : 'Welcome back, ${widget.name}';

  String get _welcomeSubtitle => _isArabic
      ? 'اختر الخدمة التي تريدها من لوحة التحكم الذكية.'
      : 'Choose the smart service you want from your dashboard.';

  String get _servicesTitle => _isArabic ? 'الخدمات' : 'Services';
  String get _studentIdLabel => _isArabic ? 'الرقم الجامعي' : 'Student ID';
  String get _statusLabel => _isArabic ? 'الحالة' : 'Status';
  String get _servicesCountLabel => _isArabic ? 'الخدمات' : 'Services';
  String get _activeValue => _isArabic ? 'نشط' : 'Active';

  void _showPrivateFilesMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isArabic
              ? 'Private Files موجودة كشكل فقط حاليًا.'
              : 'Private Files is currently a placeholder only.',
        ),
      ),
    );
  }

  void _switchLanguage(bool arabic) {
    SmartCampusApp.of(context).setLocale(
      arabic ? const Locale('ar') : const Locale('en'),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          arabic ? 'تم التحويل إلى العربية' : 'Language switched to English',
        ),
      ),
    );
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final bool isWide = width >= 1100;
    final bool isTablet = width >= 760 && width < 1100;
    final bool isMobile = width < 760;

    final int crossAxisCount = isWide ? 4 : (isTablet ? 2 : 1);
    final double childAspectRatio = isWide ? 1.42 : (isTablet ? 1.35 : 1.75);

    final features = [
      _HomeFeature(
        title: _isArabic ? 'Chatbot' : 'Chatbot',
        icon: Icons.chat_bubble_outline_rounded,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatbotScreen(studentId: widget.studentId),
          ),
        ),
      ),
      _HomeFeature(
        title: _isArabic ? 'Bus System' : 'Bus System',
        icon: Icons.directions_bus_outlined,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const BusScreen(),
          ),
        ),
      ),
      _HomeFeature(
        title: _isArabic ? 'Library' : 'Library',
        icon: Icons.local_library_outlined,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const LibraryScreen(),
          ),
        ),
      ),
      _HomeFeature(
        title: _isArabic ? 'University Rules' : 'University Rules',
        icon: Icons.rule_folder_outlined,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const RulesScreen(),
          ),
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: bgPrimary,
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
              top: -120,
              left: -90,
              child: _GlowCircle(color: neonCyan),
            ),
            Positioned(
              bottom: -140,
              right: -90,
              child: _GlowCircle(color: electricBlue),
            ),
            SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 18),
                  _buildHeroSection(isMobile: isMobile),
                  const SizedBox(height: 24),
                  _buildSectionHeader(),
                  const SizedBox(height: 16),
                  GridView.builder(
                    itemCount: features.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 18,
                      childAspectRatio: childAspectRatio,
                    ),
                    itemBuilder: (context, index) {
                      return _FeatureCard(feature: features[index]);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    colors: [
                      neonCyan.withOpacity(0.28),
                      electricBlue.withOpacity(0.18),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: neonCyan.withOpacity(0.16),
                  ),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: RichText(
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: _titleMain,
                        style: const TextStyle(
                          color: textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Pattanakarn',
                        ),
                      ),
                      TextSpan(
                        text: ' $_titleAi',
                        style: const TextStyle(
                          color: neonCyan,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Pattanakarn',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        PopupMenuButton<String>(
          tooltip: _isArabic ? 'الملف الشخصي' : 'Profile',
          color: const Color(0xFF171D36),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          onSelected: (value) {
            if (value == 'private_files') {
              _showPrivateFilesMessage();
            } else if (value == 'lang_en') {
              _switchLanguage(false);
            } else if (value == 'lang_ar') {
              _switchLanguage(true);
            } else if (value == 'logout') {
              _logout();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: 'private_files',
              child: Row(
                children: [
                  const Icon(Icons.folder_open_outlined, color: Colors.white70),
                  const SizedBox(width: 10),
                  Text(
                    'Private Files',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<String>(
              value: 'lang_en',
              child: Row(
                children: [
                  const Icon(Icons.language, color: Colors.white70),
                  const SizedBox(width: 10),
                  Text(
                    'English',
                    style: TextStyle(
                      color: !_isArabic ? neonCyan : Colors.white,
                      fontWeight:
                          !_isArabic ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'lang_ar',
              child: Row(
                children: [
                  const Icon(Icons.translate, color: Colors.white70),
                  const SizedBox(width: 10),
                  Text(
                    'العربية',
                    style: TextStyle(
                      color: _isArabic ? neonCyan : Colors.white,
                      fontWeight:
                          _isArabic ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  const Icon(Icons.logout_rounded, color: Colors.redAccent),
                  const SizedBox(width: 10),
                  Text(
                    _isArabic ? 'تسجيل الخروج' : 'Logout',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white.withOpacity(0.06),
              border: Border.all(
                color: neonCyan.withOpacity(0.14),
              ),
              boxShadow: [
                BoxShadow(
                  color: neonCyan.withOpacity(0.05),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.name.isNotEmpty ? widget.name[0].toUpperCase() : 'S',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection({required bool isMobile}) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF081A48).withOpacity(0.94),
            const Color(0xFF180B46).withOpacity(0.94),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: neonCyan.withOpacity(0.14),
        ),
        boxShadow: [
          BoxShadow(
            color: neonCyan.withOpacity(0.08),
            blurRadius: 28,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            _isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 180, maxHeight: 260),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              image: const DecorationImage(
                image: AssetImage('assets/images/campus.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.15),
                    Colors.black.withOpacity(0.35),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              alignment:
                  _isArabic ? Alignment.bottomRight : Alignment.bottomLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: _isArabic
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    _welcomeTitle,
                    textAlign: _isArabic ? TextAlign.right : TextAlign.left,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: isMobile ? 24 : 30,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Pattanakarn',
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _welcomeSubtitle,
                    textAlign: _isArabic ? TextAlign.right : TextAlign.left,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _StatChip(
                label: _studentIdLabel,
                value: widget.studentId,
              ),
              _StatChip(
                label: _statusLabel,
                value: _activeValue,
              ),
              _StatChip(
                label: _servicesCountLabel,
                value: '4',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Text(
      _servicesTitle,
      style: const TextStyle(
        color: textPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        fontFamily: 'Pattanakarn',
      ),
    );
  }
}

class _HomeFeature {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  _HomeFeature({
    required this.title,
    required this.icon,
    required this.onTap,
  });
}

class _FeatureCard extends StatelessWidget {
  final _HomeFeature feature;

  const _FeatureCard({required this.feature});

  static const Color neonCyan = Color(0xFF00F0FF);
  static const Color textPrimary = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: feature.onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.045),
                Colors.white.withOpacity(0.025),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: neonCyan.withOpacity(0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: neonCyan.withOpacity(0.03),
                blurRadius: 18,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -18,
                right: -18,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xFF77E6FF),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(18),
                      topRight: Radius.circular(24),
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: neonCyan.withOpacity(0.10),
                      ),
                    ),
                    child: Icon(
                      feature.icon,
                      color: Colors.white70,
                      size: 28,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    feature.title,
                    style: const TextStyle(
                      color: textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({
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

class _GlowCircle extends StatelessWidget {
  final Color color;

  const _GlowCircle({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: 260,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.08),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.18),
            blurRadius: 120,
            spreadRadius: 30,
          ),
        ],
      ),
    );
  }
}