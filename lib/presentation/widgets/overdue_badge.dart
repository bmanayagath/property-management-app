import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class OverdueBadge extends StatefulWidget {
  final String label;

  const OverdueBadge({
    super.key,
    this.label = 'OVERDUE',
  });

  @override
  State<OverdueBadge> createState() => _OverdueBadgeState();
}

class _OverdueBadgeState extends State<OverdueBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _opacity = Tween<double>(begin: 0.62, end: 1).animate(curve);
    _scale = Tween<double>(begin: 0.97, end: 1).animate(curve);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AppColors.error.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.circle, size: 6, color: AppColors.error),
              const SizedBox(width: 4),
              Text(
                widget.label,
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VillaOverdueIndicator extends StatelessWidget {
  final int count;

  const VillaOverdueIndicator({
    super.key,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded,
              size: 14, color: AppColors.error),
          const SizedBox(width: 4),
          Text(
            '$count Overdue',
            style: const TextStyle(
              color: AppColors.error,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
