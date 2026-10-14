import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../shared/providers.dart';
import '../../shared/utils/format.dart';
import '../../shared/widgets/status_badge.dart';
import '../../shared/widgets/ui.dart';

/// Detail aset + hasil opname periode ini.
/// Isinya sama dengan dialog titik di peta website.
class AssetDetailScreen extends ConsumerWidget {
  const AssetDetailScreen({super.key, required this.assetId});

  final String assetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asset = ref.watch(assetByIdProvider(assetId));
    final result = ref.watch(opnameResultsProvider)[assetId];
    // Semua entri selain hasil periode ini (termasuk periode lalu).
    final olderResults = ref
        .watch(assetHistoryProvider(assetId))
        .where((r) => r.id != result?.id);
    final periodId = ref.watch(activePeriodProvider).id;
    final distance = ref.watch(distanceProvider(assetId));
    final pendingAdjustments = ref
        .watch(adjustmentsProvider)
        .where((a) => a.assetId == assetId)
        .length;

    if (asset == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Aset $assetId tidak ditemukan')),
      );
    }

    final rows = <(String, String)>[
      ('ID / Label', asset.id),
      ('Kelas aset', asset.assetClass),
      ('Nomor ECC', asset.eccNumber),
      ('Nomor Fiori', asset.fioriNumber),
      ('Tahun perolehan', '${asset.acquisitionYear}'),
      ('Nilai perolehan', formatRupiah(asset.acquisitionValue)),
      (
        'Kondisi tercatat',
        '${asset.condition.code} (${asset.condition.label})'
      ),
      ('Lokasi / Pad', asset.group),
      ('Bus area', asset.businessArea),
      (
        'Koordinat',
        '${asset.lat.toStringAsFixed(5)}, ${asset.lng.toStringAsFixed(5)}'
      ),
      ('Jarak dari Anda', formatDistance(distance)),
    ];

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          AssetHeader(
            asset: asset,
            subtitle: asset.assetClass,
            onBack: () => context.go('/aset'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionLabel('Hasil stock opname'),
                AppCard(
                  child: result == null
                      ? const Row(
                          children: [
                            Icon(Icons.pending_actions, color: AppColors.muted),
                            SizedBox(width: 10),
                            Text('Belum dicatat pada periode ini'),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                OpnameBadge(result: result),
                                StatusChip(
                                  label: result.method.label,
                                  color: AppColors.info,
                                ),
                                StatusChip(
                                  label: result.synced
                                      ? 'Terkirim'
                                      : 'Belum terkirim',
                                  color: result.synced
                                      ? AppColors.ok
                                      : AppColors.warn,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _line('Kondisi',
                                '${result.condition.code} (${result.condition.label})'),
                            _line('Waktu', formatDateTime(result.recordedAt)),
                            _line('Foto', '${result.photoCount} foto'),
                            _line('GPS',
                                '${formatDistance(result.gpsDistanceM)} dari titik aset'),
                            if (result.manualReason.isNotEmpty)
                              _line('Alasan manual', result.manualReason),
                            if (result.note.isNotEmpty)
                              _line('Catatan', result.note),
                            const SizedBox(height: 4),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                ),
                                // Form terisi hasil terakhir; simpan = entri
                                // baru, hasil lama tetap di riwayat.
                                onPressed: () => context.push(Uri(
                                  path: '/opname/$assetId',
                                  queryParameters: {
                                    'metode': result.method.name,
                                    if (result.manualReason.isNotEmpty)
                                      'alasan': result.manualReason,
                                  },
                                ).toString()),
                                icon: const Icon(Icons.edit_note, size: 18),
                                label: const Text('Koreksi hasil'),
                              ),
                            ),
                          ],
                        ),
                ),
                if (olderResults.isNotEmpty) ...[
                  const SectionLabel('Riwayat pencatatan'),
                  AppCard(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      children: [
                        for (final r in olderResults)
                          ListTile(
                            dense: true,
                            title: Text(
                              '${r.status.label} · ${r.condition.code}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            subtitle: Text(
                              '${formatDateTime(r.recordedAt)} · '
                              '${r.method.label}'
                              '${r.periodId == periodId ? '' : ' · periode ${r.periodId}'}'
                              '${r.note.isEmpty ? '' : ' · ${r.note}'}',
                            ),
                            trailing: StatusChip(
                              label: r.synced ? 'Terkirim' : 'Menunggu',
                              color: r.synced ? AppColors.ok : AppColors.warn,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                if (pendingAdjustments > 0) ...[
                  const SizedBox(height: 8),
                  InfoBox(
                    text: '$pendingAdjustments usulan stock adjustment '
                        'menunggu persetujuan admin.',
                    color: AppColors.info,
                    background: AppColors.infoSoft,
                  ),
                ],
                const SectionLabel('Data aset'),
                AppCard(
                  child: Column(
                    children: [for (final (k, v) in rows) _line(k, v)],
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => context.push('/scan'),
                  icon: const Icon(Icons.qr_code_scanner),
                  label: Text(
                      result == null ? 'Scan & catat' : 'Scan & catat ulang'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => context.push('/manual?aset=${asset.id}'),
                  child: const Text('Input manual (tanpa scan)'),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => context.push('/adjust/${asset.id}'),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Data aset tidak sesuai? Stock adjustment'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
