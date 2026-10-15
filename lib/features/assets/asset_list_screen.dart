import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../shared/models/asset.dart';
import '../../shared/models/opname_result.dart';
import '../../shared/providers.dart';
import '../../shared/utils/format.dart';
import '../../shared/widgets/status_badge.dart';
import '../../shared/widgets/ui.dart';

enum _Filter { all, pending, ok, problem }

/// Menu Aset: daftar aset per lokasi, pencarian, filter status.
class AssetListScreen extends ConsumerStatefulWidget {
  const AssetListScreen({super.key});

  @override
  ConsumerState<AssetListScreen> createState() => _AssetListScreenState();
}

class _AssetListScreenState extends ConsumerState<AssetListScreen> {
  String _query = '';
  _Filter _filter = _Filter.all;

  bool _matchFilter(_Filter f, OpnameResult? r) => switch (f) {
        _Filter.all => true,
        _Filter.pending => r == null,
        _Filter.ok => r != null && !r.status.isProblem,
        _Filter.problem => r != null && r.status.isProblem,
      };

  @override
  Widget build(BuildContext context) {
    final assets = ref.watch(assetsProvider);
    final results = ref.watch(opnameResultsProvider);

    final q = _query.trim().toLowerCase();
    final filtered = assets.where((a) {
      final matchQuery = q.isEmpty ||
          a.name.toLowerCase().contains(q) ||
          a.id.toLowerCase().contains(q) ||
          a.eccNumber.contains(q) ||
          a.fioriNumber.toLowerCase().contains(q) ||
          a.group.toLowerCase().contains(q);
      return matchQuery && _matchFilter(_filter, results[a.id]);
    }).toList();

    // Kelompokkan per lokasi, urut jarak terdekat di tiap grup.
    final groups = <String, List<Asset>>{};
    for (final a in filtered) {
      groups.putIfAbsent(a.group, () => []).add(a);
    }
    for (final list in groups.values) {
      list.sort((a, b) => (ref.read(distanceProvider(a.id)) ?? double.infinity)
          .compareTo(ref.read(distanceProvider(b.id)) ?? double.infinity));
    }

    int count(_Filter f) =>
        assets.where((a) => _matchFilter(f, results[a.id])).length;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SEMESTER II 2026',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ok,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              Text(
                                'Daftar Aset',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        RoundIconButton(
                          icon: Icons.map_outlined,
                          background: AppColors.forest,
                          color: AppColors.lime,
                          onTap: () => context.go('/peta'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Cari nama, ECC, atau Fiori',
                        prefixIcon: Icon(Icons.search, size: 20),
                      ),
                      onChanged: (v) => setState(() => _query = v),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final f in _Filter.values) ...[
                            PillChoice(
                              label: switch (f) {
                                _Filter.all => 'Semua',
                                _Filter.pending => 'Belum',
                                _Filter.ok => 'Sesuai',
                                _Filter.problem => 'Masalah',
                              },
                              count: count(f),
                              selected: _filter == f,
                              onTap: () => setState(() => _filter = f),
                            ),
                            const SizedBox(width: 6),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (filtered.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('Tidak ada aset yang cocok.')),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                sliver: SliverList.list(
                  children: [
                    for (final entry in groups.entries) ...[
                      _GroupHeader(
                        title: entry.key,
                        done: entry.value
                            .where((a) => results.containsKey(a.id))
                            .length,
                        total: entry.value.length,
                      ),
                      for (final a in entry.value)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _AssetTile(asset: a, result: results[a.id]),
                        ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    required this.title,
    required this.done,
    required this.total,
  });

  final String title;
  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 8),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : done / total,
              minHeight: 4,
              borderRadius: BorderRadius.circular(4),
              color: AppColors.ok,
              backgroundColor: AppColors.line,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$done/$total',
            style: const TextStyle(fontSize: 11, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _AssetTile extends ConsumerWidget {
  const _AssetTile({required this.asset, required this.result});

  final Asset asset;
  final OpnameResult? result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final distance = ref.watch(distanceProvider(asset.id));
    final r = result;
    final StatusChip chip;
    if (r == null) {
      chip = const StatusChip(label: 'Belum', color: AppColors.pending);
    } else if (r.status == OpnameStatus.sesuai) {
      chip = const StatusChip(label: 'Sesuai', color: AppColors.ok);
    } else {
      chip = StatusChip(label: r.status.label, color: statusColor(r.status));
    }

    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: () => context.go('/aset/${asset.id}'),
      child: Row(
        children: [
          AssetIcon(kind: asset.kind),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'ECC ${asset.eccNumber}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.muted,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              chip,
              const SizedBox(height: 6),
              Text(
                formatDistance(distance),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
