import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../models/opname_result.dart';

/// Label kecil berwarna dengan latar lembut.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    this.background,
  });

  final String label;
  final Color color;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background ?? color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Status opname satu aset ("Belum" kalau belum dicatat).
class OpnameBadge extends StatelessWidget {
  const OpnameBadge({super.key, required this.result});

  final OpnameResult? result;

  @override
  Widget build(BuildContext context) {
    final r = result;
    return StatusChip(
      label: r == null ? 'Belum' : r.status.label,
      color: statusColor(r?.status),
    );
  }
}

/// Titik kecil berwarna (dipakai di daftar & legenda).
class StatusDot extends StatelessWidget {
  const StatusDot({super.key, required this.color, this.size = 8});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
