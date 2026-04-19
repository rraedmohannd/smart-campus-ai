import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'screens/bus_screen.dart';
import 'screens/chatbot_screen.dart';
import 'screens/library_screen.dart';
import 'screens/rules_screen.dart';

class HomeScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    const Color primary = Color(0xFF0F172A);
    const Color accent = Color(0xFF06B6D4);
    const Color textSecondary = Color(0xFF64748B);

    final width = MediaQuery.of(context).size.width;

    final int crossAxisCount;
    final double childAspectRatio;

    if (width >= 1200) {
      crossAxisCount = 4;
      childAspectRatio = 1.22;
    } else if (width >= 850) {
      crossAxisCount = 2;
      childAspectRatio = 1.28;
    } else {
      crossAxisCount = 1;
      childAspectRatio = 1.75;
    }

    final features = [
      _HomeFeature(
        title: 'AI Chatbot',
        subtitle: 'Ask questions and get instant campus support.',
        icon: Icons.chat_bubble_outline_rounded,
        accentColor: accent,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatbotScreen(studentId: studentId),
          ),
        ),
      ),
      _HomeFeature(
        title: 'Library',
        subtitle: 'Browse books, featured titles, and categories.',
        icon: Icons.local_library_outlined,
        accentColor: const Color(0xFF8B5CF6),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const LibraryScreen(),
          ),
        ),
      ),
      _HomeFeature(
        title: 'Rules',
        subtitle: 'View categorized academic and campus policies.',
        icon: Icons.rule_folder_outlined,
        accentColor: const Color(0xFFF59E0B),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const RulesScreen(),
          ),
        ),
      ),
      _HomeFeature(
        title: 'Bus System',
        subtitle: 'Track routes, ETA, and transport status.',
        icon: Icons.directions_bus_outlined,
        accentColor: const Color(0xFF10B981),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const BusScreen(),
          ),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Smart Campus ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              'AI',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: accent,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: PopupMenuButton<String>(
              tooltip: 'Account',
              offset: const Offset(0, 45),
              onSelected: (value) {
                if (value == 'logout') {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout_rounded, size: 18),
                      SizedBox(width: 10),
                      Text('Logout'),
                    ],
                  ),
                ),
              ],
              child: CircleAvatar(
                radius: 18,
                backgroundColor: primary.withOpacity(0.08),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'S',
                  style: const TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          Container(
            padding: EdgeInsets.all(width < 700 ? 18 : 22),
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
                Text(
                  'Welcome back, $name',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: width < 700 ? 24 : 28,
                    fontWeight: FontWeight.bold,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Manage your campus services through one smart and modern experience.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _StatChip(
                      label: 'Student ID',
                      value: studentId,
                    ),
                    const _StatChip(
                      label: 'Status',
                      value: 'Active',
                    ),
                    const _StatChip(
                      label: 'Services',
                      value: '4',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Services',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: primary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Choose a service to continue.',
            style: TextStyle(
              fontSize: 14,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            itemCount: features.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: childAspectRatio,
            ),
            itemBuilder: (context, index) {
              final item = features[index];
              return _FeatureCard(feature: item);
            },
          ),
        ],
      ),
    );
  }
}

class _HomeFeature {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  _HomeFeature({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });
}

class _FeatureCard extends StatelessWidget {
  final _HomeFeature feature;

  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: feature.onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.black.withOpacity(0.04)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: feature.accentColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      feature.icon,
                      color: feature.accentColor,
                      size: 23,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: Color(0xFF94A3B8),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                feature.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                feature.subtitle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
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
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
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