import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../shared/models/asset.dart';
import '../../shared/models/opname_result.dart';
import '../../shared/providers.dart';
import '../../shared/utils/format.dart';
import '../../shared/widgets/ui.dart';

/// Input Manual langkah 1/2: pilih aset tanpa scan + alasan.
class ManualSelectScreen extends ConsumerStatefulWidget {
  const ManualSelectScreen({super.key, this.initialAssetId});

  /// Aset yang sudah dipilih dari peta/daftar (opsional).
  final String? initialAssetId;

  @override
  ConsumerState<ManualSelectScreen> createState() => _ManualSelectScreenState();
}

class _ManualSelectScreenState extends ConsumerState<ManualSelectScreen> {
  String _query = '';
  String? _selectedId;
  String? _reason;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.initialAssetId;
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/beranda');
    }
  }

  void _next() {
    final id = _selectedId;
    final reason = _reason;
    if (id == null || reason == null) return;
    context.push(
      '/opname/$id?metode=manual&alasan=${Uri.encodeQueryComponent(reason)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final assets = ref.watch(assetsProvider);
    final q = _query.trim().toLowerCase();

    // Urut dari yang terdekat. Kalau tidak mencari, tampilkan 6 terdekat.
    final candidates = assets
        .where((a) =>
            q.isEmpty ||
            a.name.toLowerCase().contains(q) ||
            a.eccNumber.contains(q) ||
            a.fioriNumber.toLowerCase().contains(q))
        .toList()
      ..sort((a, b) => (ref.watch(distanceProvider(a.id)) ?? double.infinity)
          .compareTo(ref.watch(distanceProvider(b.id)) ?? double.infinity));
    final shown = q.isEmpty ? candidates.take(6).toList() : candidates;

    // Pastikan aset yang sudah dipilih tetap terlihat.
    final selected =
        _selectedId == null ? null : ref.watch(assetByIdProvider(_selectedId!));
    if (selected != null && !shown.any((a) => a.id == selected.id)) {
      shown.insert(0, selected);
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Row(
              children: [
                RoundIconButton(icon: Icons.arrow_back, onTap: _close),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TANPA SCAN',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.warn,
                      ),
                    ),
                    Text(
                      'Input Manual',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            const _Steps(current: 1),
            const SizedBox(height: 14),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Cari nama, ECC, atau Fiori',
                prefixIcon: Icon(Icons.search, size: 20),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
            SectionLabel(
                q.isEmpty ? 'Aset terdekat dari Anda' : 'Hasil pencarian'),
            if (shown.isEmpty)
              const Text(
                'Tidak ada aset yang cocok.',
                style: TextStyle(color: AppColors.muted),
              ),
            for (final a in shown)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _AssetOption(
                  asset: a,
                  selected: a.id == _selectedId,
                  onTap: () => setState(() => _selectedId = a.id),
                ),
              ),
            const SectionLabel('Kenapa tidak scan?', required: true),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final r in manualReasons)
                  PillChoice(
                    label: r,
                    selected: _reason == r,
                    onTap: () => setState(() => _reason = r),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            const InfoBox(
              text: 'Input manual wajib foto aset + GPS dan akan '
                  'ditandai Manual di peta.',
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAction(
        child: FilledButton(
          onPressed: _selectedId != null && _reason != null ? _next : null,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Lanjut isi hasil'),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

/// Indikator langkah 1 (Pilih aset) → 2 (Isi hasil).
class _Steps extends StatelessWidget {
  const _Steps({required this.current});

  final int current;

  @override
  Widget build(BuildContext context) {
    Widget step(int n, String label) {
      final active = n <= current;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 11,
            backgroundColor: active ? AppColors.forest : AppColors.line,
            child: Text(
              '$n',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: active ? AppColors.lime : AppColors.muted,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: active ? AppColors.ink : AppColors.muted,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        step(1, 'Pilih aset'),
        const Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Divider(),
          ),
        ),
        step(2, 'Isi hasil'),
      ],
    );
  }
}

class _AssetOption extends ConsumerWidget {
  const _AssetOption({
    required this.asset,
    required this.selected,
    required this.onTap,
  });

  final Asset asset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final distance = ref.watch(distanceProvider(asset.id));
    final done = ref.watch(opnameResultsProvider).containsKey(asset.id);

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: Border.all(
        color: selected ? AppColors.forest : AppColors.line,
        width: selected ? 1.6 : 1,
      ),
      onTap: onTap,
      child: Row(
        children: [
          // Lingkaran pilihan (pengganti Radio).
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppColors.forest : AppColors.muted,
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: selected
                ? Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.forest,
                      shape: BoxShape.circle,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'ECC ${asset.eccNumber}${done ? ' · sudah dicatat' : ''}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.muted,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          Text(
            formatDistance(distance),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
