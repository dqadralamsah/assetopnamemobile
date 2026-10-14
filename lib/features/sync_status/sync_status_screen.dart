import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../shared/providers.dart';
import '../../shared/utils/format.dart';
import '../../shared/widgets/status_badge.dart';
import '../../shared/widgets/ui.dart';

/// Status Sync: antrean hasil yang belum/sudah terkirim + usulan adjustment.
class SyncStatusScreen extends ConsumerStatefulWidget {
  const SyncStatusScreen({super.key});

  @override
  ConsumerState<SyncStatusScreen> createState() => _SyncStatusScreenState();
}

class _SyncStatusScreenState extends ConsumerState<SyncStatusScreen> {
  bool _sending = false;

  Future<void> _send() async {
    setState(() => _sending = true);
    String message;
    try {
      await ref.read(opnameHistoryProvider.notifier).sendPending();
      await ref.read(adjustmentsProvider.notifier).sendPending();
      message = 'Semua data terkirim';
    } catch (e) {
      final left = ref.read(unsyncedCountProvider);
      message = 'Gagal kirim: $e · $left data masih di antrean';
    }
    if (!mounted) return;
    setState(() => _sending = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final results = [...ref.watch(opnameHistoryProvider)]..sort((a, b) {
        // Belum terkirim di atas, lalu terbaru.
        if (a.synced != b.synced) return a.synced ? 1 : -1;
        return b.recordedAt.compareTo(a.recordedAt);
      });
    final unsynced = ref.watch(unsyncedCountProvider);
    final adjustments = ref.watch(adjustmentsProvider);

    void close() {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/akun');
      }
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Row(
              children: [
                RoundIconButton(icon: Icons.arrow_back, onTap: close),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status Sync',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Data tersimpan di HP sampai terkirim',
                      style: TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppCard(
              color: unsynced == 0 ? AppColors.okSoft : AppColors.warnSoft,
              child: Row(
                children: [
                  Icon(
                    unsynced == 0 ? Icons.cloud_done_outlined : Icons.cloud_off,
                    color: unsynced == 0 ? AppColors.ok : AppColors.warn,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          unsynced == 0
                              ? 'Semua hasil sudah terkirim'
                              : '$unsynced data belum terkirim',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          unsynced == 0
                              ? 'Tidak ada antrean.'
                              : 'Data aman tersimpan di HP dan akan dikirim '
                                  'saat ada sinyal.',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SectionLabel('Antrean hasil opname'),
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  for (final r in results)
                    ListTile(
                      dense: true,
                      title: Text(
                        ref.watch(assetByIdProvider(r.assetId))?.name ??
                            r.assetId,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        '${r.status.label} · ${r.method.label} · '
                        '${r.photoCount} foto · ${formatTime(r.recordedAt)}',
                      ),
                      trailing: StatusChip(
                        label: r.synced ? 'Terkirim' : 'Menunggu',
                        color: r.synced ? AppColors.ok : AppColors.warn,
                      ),
                    ),
                ],
              ),
            ),
            if (adjustments.isNotEmpty) ...[
              const SectionLabel('Usulan stock adjustment'),
              AppCard(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: [
                    for (final a in adjustments)
                      ListTile(
                        dense: true,
                        title: Text(
                          ref.watch(assetByIdProvider(a.assetId))?.name ??
                              a.assetId,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(a.changes.keys.join(', ')),
                        trailing: a.synced
                            ? const StatusChip(
                                label: 'Menunggu approval',
                                color: AppColors.info,
                              )
                            : const StatusChip(
                                label: 'Menunggu',
                                color: AppColors.warn,
                              ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: BottomAction(
        child: FilledButton.icon(
          onPressed: unsynced == 0 || _sending ? null : _send,
          icon: const Icon(Icons.sync, size: 18),
          label: Text(_sending ? 'Mengirim…' : 'Kirim sekarang'),
        ),
      ),
    );
  }
}
