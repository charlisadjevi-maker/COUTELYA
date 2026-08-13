import 'package:flutter/material.dart';

import 'core/app_theme.dart';

class CoutelyaBrand extends StatelessWidget {
  const CoutelyaBrand({super.key, this.compact = false, this.light = false});

  final bool compact;
  final bool light;

  @override
  Widget build(BuildContext context) {
    if (!light) {
      return Image.asset(
        'assets/brand/coutelya_logo.png',
        width: compact ? 205 : 330,
        fit: BoxFit.contain,
        alignment: Alignment.centerLeft,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/brand/coutelya_mark.png', width: compact ? 44 : 70, fit: BoxFit.contain),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'COUTELYA',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                fontSize: compact ? 20 : 30,
              ),
            ),
            if (!compact)
              const Text(
                'VOTRE ATELIER, SIMPLEMENT.',
                style: TextStyle(
                  color: Color(0xFFFFD166),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  fontSize: 10,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.background,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final white = background.computeLuminance() < 0.55;
    final fg = white ? Colors.white : CoutelyaColors.ink;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: background.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: fg.withValues(alpha: 0.9), size: 21),
              const Spacer(),
              Text(value, style: TextStyle(color: fg, fontSize: 24, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 12),
          Text(label, style: TextStyle(color: fg, height: 1.15, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900))),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class AppStatusChip extends StatelessWidget {
  const AppStatusChip({super.key, required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(30)),
      child: Text(statusLabel(status), style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12)),
    );
  }
}

Color statusColor(String status) {
  switch (status) {
    case 'cutting':
      return const Color(0xFF2C88C7);
    case 'sewing':
      return CoutelyaColors.purple;
    case 'fitting':
      return const Color(0xFFF39A08);
    case 'finishing':
      return const Color(0xFFEFB22B);
    case 'ready':
      return const Color(0xFF67B85D);
    case 'delivered':
      return const Color(0xFF318E9B);
    case 'cancelled':
      return CoutelyaColors.red;
    default:
      return CoutelyaColors.green;
  }
}

String statusLabel(String status) {
  switch (status) {
    case 'registered':
      return 'Enregistrée';
    case 'cutting':
      return 'Coupe';
    case 'sewing':
      return 'Couture';
    case 'fitting':
      return 'Essayage';
    case 'finishing':
      return 'Finition';
    case 'ready':
      return 'Prête';
    case 'delivered':
      return 'Livrée';
    case 'cancelled':
      return 'Annulée';
    default:
      return status;
  }
}

String formatMoney(num value) {
  final rounded = value.round().toString();
  final chars = rounded.split('').reversed.toList();
  final chunks = <String>[];
  for (var i = 0; i < chars.length; i += 3) {
    chunks.add(chars.skip(i).take(3).toList().reversed.join());
  }
  return '${chunks.reversed.join(' ')} FCFA';
}

String formatDate(DateTime? date) {
  if (date == null) return '—';
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(date.day)}/${two(date.month)}/${date.year}';
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(color: CoutelyaColors.purpleSoft, shape: BoxShape.circle),
              child: Icon(icon, size: 34, color: CoutelyaColors.purple),
            ),
            const SizedBox(height: 14),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
            const SizedBox(height: 5),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: CoutelyaColors.muted, height: 1.4)),
          ],
        ),
      ),
    );
  }
}
