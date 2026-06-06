import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/widgets/glass_card.dart';
import '../core/widgets/smart_ai_background.dart';

class BusGpsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> buses;
  final String? focusedBusId;

  const BusGpsScreen({
    super.key,
    required this.buses,
    this.focusedBusId,
  });

  @override
  Widget build(BuildContext context) {
    return SmartAiScaffold(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Back',
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                ),
                const Expanded(
                  child: Text(
                    'GPS Bus View',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            GlassCard(
              radius: 24,
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  const Icon(
                    Icons.my_location_rounded,
                    color: AppColors.cyan,
                    size: 38,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Live map preview is available inside Smart Bus Tracking.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${buses.length} buses loaded${focusedBusId == null ? '' : ' • Focus $focusedBusId'}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
