import 'package:flutter/material.dart';
import '../doctor_shell.dart';

/// Standard RTL-appropriate back button for all Doctor subscreens pushed above DoctorShell.
/// On tap, safely pops the current route or navigates back to DoctorShell if cannot pop.
class DoctorBackButton extends StatelessWidget {
  final Color? color;
  final VoidCallback? onCustomPop;

  const DoctorBackButton({super.key, this.color, this.onCustomPop});

  static void safePop(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).maybePop();
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const DoctorShell()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
      color: color ?? const Color(0xFF073B4C),
      tooltip: 'رجوع',
      onPressed: onCustomPop ?? () => safePop(context),
    );
  }
}

/// Convenience top-level function for safe Doctor popping in PopScope.
void safeDoctorPop(BuildContext context) => DoctorBackButton.safePop(context);

