import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../shared/models/opname_result.dart';
import '../../shared/providers.dart';
import '../../shared/utils/format.dart';
import '../../shared/widgets/status_badge.dart';
import '../../shared/widgets/ui.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assets = ref.watch(assetsProvider);
    final results = ref.watch(opnameResultsProvider);

    final done = results.length;
    final total = assets.length;

    final recent = results.values.toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));

    // Strip hijau setinggi status bar tetap di atas, supaya konten yang
    // di-scroll tidak tembus ke bawah jam & baterai.
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: MediaQuery.paddingOf(context).top,
            color: AppColors.forest,
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _Header(done: done, total: total),
                Transform.translate(
                  offset: const Offset(0, -28),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _RecapCard(results: results.values, total: total),
                        const SizedBox(height: 12),
                        const _NearestCard(),
                        const SizedBox(height: 20),
                        const _SectionTitle('Progres per lokasi'),
                        const _LocationProgressCard(),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text(
                              'Terakhir dicatat',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () => context.go('/aset'),
                              child: const Text('Semua'),
                            ),
                          ],
                        ),
                        if (recent.isEmpty)
                          const AppCard(
                              child: Text('Belum ada aset yang dicatat.'))
                        else
                          AppCard(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Column(
                              children: [
                                for (final r in recent.take(5))
                                  _RecentRow(result: r),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final unsynced = ref.watch(unsyncedCountProvider);
    final progress = total == 0 ? 0.0 : done / total;
    final period = ref.watch(activePeriodProvider);
    final daysLeft = period.daysLeft(DateTime.now());
    final hour = DateTime.now().hour;
    final greeting = hour < 11
        ? 'Selamat pagi,'
        : hour < 15
            ? 'Selamat siang,'
            : hour < 18
                ? 'Selamat sore,'
                : 'Selamat malam,';

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        14, // status bar sudah ditangani strip di HomeScreen
        16,
        48,
      ),
      decoration: const BoxDecoration(
        color: AppColors.forest,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.lime,
                child: Text(
                  user?.initials ?? 'NP',
                  style: const TextStyle(
                    color: AppColors.forest,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      user?.name ?? 'Petugas',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              Badge(
                isLabelVisible: unsynced > 0,
                label: Text('$unsynced'),
                backgroundColor: AppColors.warn,
                child: RoundIconButton(
                  icon: Icons.sync,
                  onTap: () => context.push('/sync'),
                  background: Colors.white.withValues(alpha: 0.12),
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 92,
                height: 92,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 9,
                      strokeCap: StrokeCap.round,
                      color: AppColors.lime,
                      backgroundColor: Colors.white.withValues(alpha: 0.12),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${(progress * 100).round()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Text(
                            'selesai',
                            style:
                                TextStyle(color: Colors.white60, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      period.name.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.lime,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        text: '$done',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                        children: [
                          TextSpan(
                            text: ' dari $total aset',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Batas ${formatDate(period.end)} · $daysLeft hari lagi',
                      style:
                          const TextStyle(color: Colors.white60, fontSize: 11),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
      ),
    );
  }
}

/// Rekap periode: bar bertumpuk Sesuai / Bermasalah / Belum, rincian
/// masalah per status, lalu angka hari ini & label cetak ulang.
class _RecapCard extends ConsumerWidget {
  const _RecapCard({required this.results, required this.total});

  final Iterable<OpnameResult> results;
  final int total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int count(OpnameStatus s) => results.where((r) => r.status == s).length;
    final ok = count(OpnameStatus.sesuai);
    final problem = results.length - ok;
    final pending = total - results.length;
    final now = DateTime.now();
    final today =
        results.where((r) => DateUtils.isSameDay(r.recordedAt, now)).length;
    final reprint = ref.watch(labelReprintProvider).length;

    Widget stat(int value, String label, Color color) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$value',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Row(
                children: [
                  StatusDot(color: color, size: 8),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

    // Bar bertumpuk; segmen 0 tidak digambar (flex harus > 0).
    Widget segment(int value, Color color) => value == 0
        ? const SizedBox.shrink()
        : Expanded(flex: value, child: Container(color: color));

    Widget pill(IconData icon, String text, Color color, Color background) =>
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'REKAP PERIODE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.muted,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              stat(ok, 'Sesuai', AppColors.ok),
              stat(problem, 'Bermasalah', AppColors.warn),
              stat(pending, 'Belum', AppColors.pending),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  segment(ok, AppColors.ok),
                  segment(problem, AppColors.warn),
                  segment(pending, AppColors.line),
                ],
              ),
            ),
          ),
          if (problem > 0) ...[
            const SizedBox(height: 14),
            const Text(
              'Rincian bermasalah',
              style: TextStyle(fontSize: 12, color: AppColors.muted),
            ),
            const SizedBox(height: 6),
            for (final s in OpnameStatus.values)
              if (s.isProblem && count(s) > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      StatusDot(color: statusColor(s), size: 8),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          s.label,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      Text(
                        '${count(s)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              pill(Icons.today_outlined, '$today dicatat hari ini',
                  AppColors.info, AppColors.infoSoft),
              const SizedBox(width: 8),
              pill(
                Icons.print_outlined,
                '$reprint cetak label',
                reprint == 0 ? AppColors.muted : AppColors.warn,
                reprint == 0 ? AppColors.bg : AppColors.warnSoft,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Progres per lokasi/pad: berapa aset sudah dicatat dari total di lokasi
/// itu. Yang belum selesai di atas, supaya petugas tahu harus ke mana.
class _LocationProgressCard extends ConsumerWidget {
  const _LocationProgressCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(opnameResultsProvider);
    final byLocation = <String, ({int done, int total})>{};
    for (final a in ref.watch(assetsProvider)) {
      final p = byLocation[a.location] ?? (done: 0, total: 0);
      byLocation[a.location] = (
        done: p.done + (results.containsKey(a.id) ? 1 : 0),
        total: p.total + 1,
      );
    }
    final rows = byLocation.entries.toList()
      ..sort((a, b) => (a.value.done / a.value.total)
          .compareTo(b.value.done / b.value.total));

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          for (final e in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          e.key,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (e.value.done == e.value.total)
                        const Icon(Icons.check_circle,
                            size: 16, color: AppColors.ok)
                      else
                        Text(
                          '${e.value.done}/${e.value.total}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: e.value.done / e.value.total,
                      minHeight: 6,
                      color: e.value.done == e.value.total
                          ? AppColors.ok
                          : AppColors.forest,
                      backgroundColor: AppColors.line,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Kartu hijau muda: aset terdekat yang belum dicatat.
class _NearestCard extends ConsumerWidget {
  const _NearestCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asset = ref.watch(nearestPendingAssetProvider);
    if (asset == null) {
      return const AppCard(
        color: AppColors.limeSoft,
        child: Row(
          children: [
            Icon(Icons.celebration_outlined, color: AppColors.forest),
            SizedBox(width: 10),
            Expanded(child: Text('Semua aset periode ini sudah dicatat.')),
          ],
        ),
      );
    }
    final distance = ref.watch(distanceProvider(asset.id));

    return AppCard(
      color: AppColors.lime,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'LANJUTKAN · TERDEKAT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.forest,
                  letterSpacing: 0.4,
                ),
              ),
              const Spacer(),
              StatusChip(
                label: formatDistance(distance),
                color: AppColors.forest,
                background: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              AssetIcon(kind: asset.kind, size: 40),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.forest,
                      ),
                    ),
                    Text(
                      'ECC ${asset.eccNumber} · ${asset.location}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.forest,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                  ),
                  onPressed: () => context.push('/scan'),
                  child: const Text('Mulai opname'),
                ),
              ),
              const SizedBox(width: 8),
              RoundIconButton(
                icon: Icons.map_outlined,
                onTap: () => context.go('/peta'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentRow extends ConsumerWidget {
  const _RecentRow({required this.result});

  final OpnameResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asset = ref.watch(assetByIdProvider(result.assetId));
    return InkWell(
      onTap: () => context.go('/aset/${result.assetId}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            StatusDot(color: statusColor(result.status)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                asset?.name ?? result.assetId,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${result.method == OpnameMethod.scan ? 'Scan' : 'Manual'}'
              ' · ${formatTime(result.recordedAt)}',
              style: const TextStyle(fontSize: 11, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
