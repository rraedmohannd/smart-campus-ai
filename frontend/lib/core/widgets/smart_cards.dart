import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'glass_card.dart';
import 'gradient_button.dart';
import 'status_badge.dart';

class RoleCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: selected ? 1.03 : 1,
      duration: const Duration(milliseconds: 180),
      child: GlassCard(
        onTap: onTap,
        radius: 20,
        padding: const EdgeInsets.all(12),
        borderColor: selected
            ? AppColors.purpleAccent.withValues(alpha: 0.70)
            : AppColors.purpleAccent.withValues(alpha: 0.18),
        glowColor: selected ? AppColors.purpleAccent : AppColors.cyan,
        opacity: selected ? 0.92 : 0.58,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : AppColors.textSecondary,
              size: 25,
            ),
            const SizedBox(height: 8),
            FittedBox(
              child: Text(
                title,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      radius: 20,
      padding: const EdgeInsets.all(16),
      borderColor: accent.withValues(alpha: 0.14),
      glowColor: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const Spacer(),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardStat extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const DashboardStat({
    super.key,
    required this.label,
    required this.value,
    this.accent = AppColors.cyan,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 20,
      padding: const EdgeInsets.all(16),
      borderColor: accent.withValues(alpha: 0.16),
      glowColor: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: accent,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class BusCard extends StatelessWidget {
  final String busName;
  final String route;
  final String eta;
  final String passengers;
  final String driver;
  final String status;
  final String? availableSeats;
  final double occupancy;
  final VoidCallback? onTrack;

  const BusCard({
    super.key,
    required this.busName,
    required this.route,
    required this.eta,
    required this.passengers,
    required this.driver,
    this.status = 'active',
    this.availableSeats,
    required this.occupancy,
    this.onTrack,
  });

  @override
  Widget build(BuildContext context) {
    final displayOccupancy = occupancy.clamp(0, 100).round();

    return GlassCard(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.cyan.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.directions_bus_rounded,
                  color: AppColors.cyan,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  busName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              StatusBadge(
                label: status,
                tone: status.toLowerCase() == 'full'
                    ? StatusBadgeTone.danger
                    : StatusBadgeTone.success,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            route,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _BusMeta(label: 'ETA', value: eta)),
              Expanded(child: _BusMeta(label: 'Passengers', value: passengers)),
              Expanded(
                child: _BusMeta(
                  label: availableSeats == null ? 'Driver' : 'Seats',
                  value: availableSeats ?? driver,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (availableSeats != null) ...[
            Text(
              driver,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              const Text(
                'Occupancy',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const Spacer(),
              Text(
                '$displayOccupancy%',
                style: const TextStyle(
                  color: AppColors.purple3,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 5,
              value: displayOccupancy / 100,
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.purple3),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: onTrack,
              child: const Text(
                'Track Live Location',
                style: TextStyle(
                  color: AppColors.purple3,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BookCard extends StatelessWidget {
  final String title;
  final String author;
  final bool available;
  final String? coverUrl;
  final VoidCallback? onBookmark;

  const BookCard({
    super.key,
    required this.title,
    required this.author,
    required this.available,
    this.coverUrl,
    this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 144,
      child: GlassCard(
        radius: 20,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                height: 160,
                width: double.infinity,
                child: _BookCover(coverUrl: coverUrl),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                StatusBadge(
                  label: available ? 'available' : 'borrowed',
                  tone: available ? StatusBadgeTone.success : StatusBadgeTone.danger,
                  dot: false,
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Bookmark',
                  onPressed: onBookmark,
                  icon: const Icon(
                    Icons.bookmark_rounded,
                    color: AppColors.purple3,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RuleCard extends StatelessWidget {
  final String category;
  final String title;
  final String summary;
  final IconData icon;
  final VoidCallback? onRead;

  const RuleCard({
    super.key,
    required this.category,
    required this.title,
    required this.summary,
    this.icon = Icons.policy_rounded,
    this.onRead,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 22,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusBadge(
                label: category,
                tone: StatusBadgeTone.cyan,
                dot: false,
              ),
              const Spacer(),
              Icon(icon, color: AppColors.purple3, size: 20),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            summary,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.35,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onRead,
              child: const Text(
                'Read Full Policy',
                style: TextStyle(
                  color: AppColors.purple3,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String time;
  final bool unread;
  final VoidCallback? onRead;
  final VoidCallback? onDelete;

  const NotificationCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    this.unread = false,
    this.onRead,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: unread ? 1 : 0.72,
      child: GlassCard(
        radius: 20,
        padding: const EdgeInsets.all(16),
        borderColor: unread
            ? AppColors.cyan.withValues(alpha: 0.34)
            : AppColors.purpleAccent.withValues(alpha: 0.14),
        glowColor: unread ? AppColors.cyan : AppColors.purpleAccent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.purpleAccent.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.cyan, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (unread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.cyan,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    message,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.35,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        time,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11.5,
                        ),
                      ),
                      const Spacer(),
                      if (unread)
                        TextButton(
                          onPressed: onRead,
                          child: const Text('Read'),
                        ),
                      if (onDelete != null)
                        IconButton(
                          tooltip: 'Delete',
                          onPressed: onDelete,
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.textMuted,
                            size: 19,
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
    );
  }
}

class AdminHealthCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color statusColor;
  final IconData icon;

  const AdminHealthCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.statusColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, color: AppColors.textMuted, size: 18),
        ],
      ),
    );
  }
}

class AiInsightCard extends StatelessWidget {
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AiInsightCard({
    super.key,
    this.title = 'AI Insights',
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 22,
      padding: const EdgeInsets.all(22),
      borderColor: AppColors.purpleAccent.withValues(alpha: 0.36),
      glowColor: AppColors.purpleAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: AppColors.cyan),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.textPrimary,
              height: 1.35,
              fontSize: 13.5,
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 18),
            GradientButton(
              label: actionLabel!,
              height: 42,
              onPressed: onAction ?? () {},
            ),
          ],
        ],
      ),
    );
  }
}

class _BusMeta extends StatelessWidget {
  final String label;
  final String value;

  const _BusMeta({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _BookCover extends StatelessWidget {
  final String? coverUrl;

  const _BookCover({this.coverUrl});

  @override
  Widget build(BuildContext context) {
    final url = coverUrl ?? '';
    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _FallbackCover(),
      );
    }

    return const _FallbackCover();
  }
}

class _FallbackCover extends StatelessWidget {
  const _FallbackCover();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/images/campus.jpg', fit: BoxFit.cover),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withValues(alpha: 0.18),
                AppColors.purple1.withValues(alpha: 0.46),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        const Center(
          child: Icon(Icons.menu_book_rounded, color: Colors.white, size: 30),
        ),
      ],
    );
  }
}
