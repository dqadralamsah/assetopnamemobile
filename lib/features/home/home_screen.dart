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
    final ok = results.values.where((r) => !r.status.isProblem).length;
    final problem = done - ok;

    final recent = results.values.toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));

    return Scaffold(
      body: ListView(
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
                  _StatsCard(ok: ok, problem: problem, pending: total - done),
                  const SizedBox(height: 12),
                  const _NearestCard(),
                  const SizedBox(height: 20),
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
                    const AppCard(child: Text('Belum ada aset yang dicatat.'))
                  else
                    AppCard(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        children: [
                          for (final r in recent.take(5)) _RecentRow(result: r),
                        ],
                      ),
                    ),
                ],
              ),
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
        MediaQuery.paddingOf(context).top + 14,
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
                      'Batas 31 Des 2026 · $daysLeft hari lagi',
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

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.ok,
    required this.problem,
    required this.pending,
  });

  final int ok;
  final int problem;
  final int pending;

  @override
  Widget build(BuildContext context) {
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
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: AppColors.muted),
              ),
            ],
          ),
        );

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          stat(ok, 'Sesuai', AppColors.ok),
          stat(problem, 'Bermasalah', AppColors.warn),
          stat(pending, 'Belum', AppColors.ink),
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
              AssetIcon(kind: asset.kind, size: 40, dark: true),
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
