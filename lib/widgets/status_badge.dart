import 'package:flutter/material.dart';
import '../app_theme.dart';

class StatusBadge extends StatelessWidget {
  final bool active;

  const StatusBadge({super.key, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: active ? kGreen.withAlpha(40) : kGrey.withAlpha(60),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active ? kGreen : kGrey,
          width: 1,
        ),
      ),
      child: Text(
        active ? 'ACTIVE' : 'INACTIVE',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: active ? kGreen : kGrey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
