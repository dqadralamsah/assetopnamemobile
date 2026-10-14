import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../models/asset.dart';
import '../models/opname_result.dart';
import 'status_badge.dart';

/// Kartu putih membulat.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.color = AppColors.card,
    this.border,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final BoxBorder? border;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: color,
          borderRadius: radius,
          border: border,
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Judul kecil di atas bagian form/daftar.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.required = false});

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Text.rich(
        TextSpan(
          text: text,
          children: [
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: AppColors.danger),
              ),
          ],
        ),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
      ),
    );
  }
}

/// Ikon jenis aset dalam kotak berwarna.
class AssetIcon extends StatelessWidget {
  const AssetIcon({
    super.key,
    required this.kind,
    this.size = 40,
    this.dark = false,
  });

  final AssetKind kind;
  final double size;

  /// Versi untuk latar hijau tua (header).
  final bool dark;

  static IconData iconOf(AssetKind kind) => switch (kind) {
        AssetKind.power => Icons.bolt,
        AssetKind.water => Icons.water_drop_outlined,
        AssetKind.electrical => Icons.electrical_services,
        AssetKind.tank => Icons.propane_tank_outlined,
        AssetKind.container => Icons.inventory_2_outlined,
        AssetKind.vehicle => Icons.local_shipping_outlined,
        AssetKind.it => Icons.laptop_outlined,
      };

  static (Color, Color) _colors(AssetKind kind) => switch (kind) {
        AssetKind.power => (AppColors.warnSoft, AppColors.warn),
        AssetKind.water => (AppColors.infoSoft, AppColors.info),
        AssetKind.electrical => (
            const Color(0xFFEDE7FA),
            const Color(0xFF6E4BC4)
          ),
        AssetKind.tank => (AppColors.infoSoft, AppColors.info),
        AssetKind.container => (AppColors.okSoft, AppColors.ok),
        AssetKind.vehicle => (AppColors.dangerSoft, AppColors.danger),
        AssetKind.it => (const Color(0xFFE9ECEA), AppColors.ink),
      };

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = dark
        ? (AppColors.lime.withValues(alpha: 0.18), AppColors.lime)
        : _colors(kind);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(iconOf(kind), color: fg, size: size * 0.5),
    );
  }
}

/// Pilihan hasil pemeriksaan (grid 2x2).
class StatusOptionGrid extends StatelessWidget {
  const StatusOptionGrid({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final OpnameStatus value;
  final ValueChanged<OpnameStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget option(OpnameStatus s) {
      final selected = s == value;
      final color = statusColor(s);
      return Expanded(
        child: Material(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onChanged(s),
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? color : AppColors.line,
                ),
              ),
              child: Row(
                children: [
                  StatusDot(color: selected ? Colors.white : color),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      s.label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : AppColors.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    const values = OpnameStatus.values;
    return Column(
      children: [
        Row(children: [
          option(values[0]),
          const SizedBox(width: 8),
          option(values[1]),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          option(values[2]),
          const SizedBox(width: 8),
          option(values[3]),
        ]),
      ],
    );
  }
}

/// Pilihan kondisi B / RR / RB.
class ConditionSelector extends StatelessWidget {
  const ConditionSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final AssetCondition value;
  final ValueChanged<AssetCondition> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final c in AssetCondition.values) ...[
          if (c != AssetCondition.values.first) const SizedBox(width: 8),
          Expanded(
            child: Material(
              color: c == value ? AppColors.forest : Colors.white,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onChanged(c),
                child: Container(
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: c == value ? AppColors.forest : AppColors.line,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        c.code,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: c == value ? AppColors.lime : AppColors.ink,
                        ),
                      ),
                      Text(
                        c.label,
                        style: TextStyle(
                          fontSize: 10,
                          color: c == value ? Colors.white70 : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Chip pilihan tunggal (alasan manual, filter).
class PillChoice extends StatelessWidget {
  const PillChoice({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.forest : Colors.white,
      shape: StadiumBorder(
        side: BorderSide(color: selected ? AppColors.forest : AppColors.line),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.lime : AppColors.ink,
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.lime : AppColors.bg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: selected ? AppColors.forest : AppColors.muted,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Kotak info berwarna (ikon + teks).
class InfoBox extends StatelessWidget {
  const InfoBox({
    super.key,
    required this.text,
    this.icon = Icons.info_outline,
    this.color = AppColors.warn,
    this.background = AppColors.warnSoft,
  });

  final String text;
  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: AppColors.ink),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tombol bulat kecil (kembali, tutup).
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.background = Colors.white,
    this.color = AppColors.ink,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color background;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}

/// Kotak dengan garis putus-putus (tempat ambil foto).
class DashedBox extends StatelessWidget {
  const DashedBox({
    super.key,
    required this.child,
    this.color = AppColors.forest,
    this.background = Colors.white,
    this.onTap,
    this.height = 84,
  });

  final Widget child;
  final Color color;
  final Color background;
  final VoidCallback? onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedBorderPainter(color),
        child: Container(
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(12),
      ));
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 6), paint);
        distance += 11;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Header hijau tua untuk layar form (kembali + badge + info aset).
class AssetHeader extends StatelessWidget {
  const AssetHeader({
    super.key,
    required this.asset,
    required this.subtitle,
    required this.onBack,
    this.badge,
    this.badgeColor = AppColors.lime,
  });

  final Asset asset;
  final String subtitle;
  final VoidCallback onBack;
  final String? badge;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.forest,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.paddingOf(context).top + 12,
        16,
        20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RoundIconButton(
                icon: Icons.arrow_back,
                onTap: onBack,
                background: Colors.white.withValues(alpha: 0.12),
                color: Colors.white,
              ),
              const Spacer(),
              if (badge != null)
                StatusChip(
                  label: badge!,
                  color: AppColors.forest,
                  background: badgeColor,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              AssetIcon(kind: asset.kind, size: 44, dark: true),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ECC ${asset.eccNumber} · ${asset.location}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tombol utama yang menempel di bawah layar.
class BottomAction extends StatelessWidget {
  const BottomAction({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: child,
      ),
    );
  }
}
