import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../shared/providers.dart';
import '../../shared/widgets/ui.dart';

/// Menu Akun: profil, ringkasan, unduh ulang data, kunci aplikasi, keluar.
class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  bool _appLock = true;

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _logout() async {
    final unsynced = ref.read(unsyncedCountProvider);
    if (unsynced > 0) {
      final sendFirst = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('$unsynced data belum terkirim'),
          content: const Text(
            'Data yang belum terkirim tetap tersimpan di HP dan bisa dikirim '
            'setelah masuk lagi. Sebaiknya kirim dulu sekarang.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Tetap keluar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Kirim dulu'),
            ),
          ],
        ),
      );
      if (!mounted || sendFirst == null) return; // dialog ditutup
      if (sendFirst) {
        context.push('/sync');
        return;
      }
    }

    try {
      await ref.read(authProvider.notifier).logout();
    } catch (e) {
      if (mounted) _snack('Gagal keluar: $e');
      return;
    }
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final unsynced = ref.watch(unsyncedCountProvider);
    final total = ref.watch(opnameResultsProvider).length;
    final assetCount = ref.watch(assetsProvider).length;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            const Text(
              'Akun',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            AppCard(
              color: AppColors.forest,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.lime,
                    child: Text(
                      user?.initials ?? 'NP',
                      style: const TextStyle(
                        color: AppColors.forest,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Petugas',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          user?.email ?? '-',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          user?.role ?? '',
                          style: const TextStyle(
                            color: AppColors.lime,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: AppCard(
                    child: _Stat(
                      value: '$total',
                      label: 'Aset dicatat periode ini',
                      color: AppColors.ink,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppCard(
                    color:
                        unsynced == 0 ? AppColors.okSoft : AppColors.warnSoft,
                    onTap: () => context.push('/sync'),
                    child: _Stat(
                      value: '$unsynced',
                      label: unsynced == 0
                          ? 'Semua terkirim'
                          : 'Belum terkirim · kirim',
                      color: unsynced == 0 ? AppColors.ok : AppColors.warn,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  ListTile(
                    leading: const _TileIcon(Icons.download_outlined),
                    title: const Text('Unduh ulang data'),
                    subtitle: Text('Simulasi · $assetCount aset'),
                    onTap: () => _snack('Data diunduh ulang (simulasi)'),
                  ),
                  ListTile(
                    leading: const _TileIcon(Icons.sync),
                    title: const Text('Status sync'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/sync'),
                  ),
                  ListTile(
                    leading: const _TileIcon(Icons.wifi_off),
                    title: const Text('Simulasi offline'),
                    subtitle: const Text('Untuk mencoba gagal kirim'),
                    trailing: Switch(
                      value: ref.watch(simulateOfflineProvider),
                      onChanged: (v) =>
                          ref.read(simulateOfflineProvider.notifier).state = v,
                    ),
                  ),
                  ListTile(
                    leading: const _TileIcon(Icons.my_location),
                    title: const Text('Posisi dummy'),
                    subtitle: const Text('Pura-pura di dekat aset (tes)'),
                    trailing: Switch(
                      value: ref.watch(useDummyPositionProvider),
                      onChanged: (v) =>
                          ref.read(useDummyPositionProvider.notifier).state = v,
                    ),
                  ),
                  ListTile(
                    leading: const _TileIcon(Icons.lock_outline),
                    title: const Text('Kunci aplikasi'),
                    subtitle: const Text('PIN / sidik jari (menyusul)'),
                    trailing: Switch(
                      value: _appLock,
                      onChanged: (v) => setState(() => _appLock = v),
                    ),
                  ),
                  const ListTile(
                    leading: _TileIcon(Icons.info_outline),
                    title: Text('Versi aplikasi'),
                    trailing: Text(
                      '0.1.0 · dummy',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.dangerSoft,
                foregroundColor: AppColors.danger,
              ),
              onPressed: _logout,
              child: const Text('Keluar'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Data yang sudah terkirim dihapus dari HP saat keluar. '
              'Yang belum terkirim tetap disimpan.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.color});

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.muted),
        ),
      ],
    );
  }
}

class _TileIcon extends StatelessWidget {
  const _TileIcon(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 18, color: AppColors.ink),
    );
  }
}
