import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_theme.dart';

class ScanButton extends StatelessWidget {
  const ScanButton({super.key, required this.onTap, this.isBusy = false});

  final VoidCallback onTap;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final core = Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFF10FF96), Color(0xFF00A85A)],
        ),
        boxShadow: [
          BoxShadow(
            color: kEmerald.withOpacity(0.55),
            blurRadius: 36,
            spreadRadius: 2,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: isBusy
          ? const CircularProgressIndicator(color: kBackground)
          : const Text(
              'SCAN',
              style: TextStyle(
                color: kBackground,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
    );

    final animatedCore = isBusy
        ? core.animate(onPlay: (controller) => controller.repeat()).rotate(duration: 1500.ms)
        : core
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scale(begin: const Offset(0.96, 0.96), end: const Offset(1.03, 1.03), duration: 1500.ms);

    return GestureDetector(
      onTap: isBusy ? null : onTap,
      child: animatedCore,
    );
  }
}
