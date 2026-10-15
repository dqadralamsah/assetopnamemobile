import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../shared/models/asset.dart';
import '../../shared/models/opname_result.dart';
import '../../shared/providers.dart';
import '../../shared/widgets/ui.dart';

/// Stock Adjustment: usulan koreksi data master aset.
/// Data lama tetap tersimpan; perubahan berlaku setelah disetujui admin.
class StockAdjustmentScreen extends ConsumerStatefulWidget {
  const StockAdjustmentScreen({super.key, required this.assetId});

  final String assetId;

  @override
  ConsumerState<StockAdjustmentScreen> createState() =>
      _StockAdjustmentScreenState();
}

class _StockAdjustmentScreenState extends ConsumerState<StockAdjustmentScreen> {
  final _name = TextEditingController();
  final _reason = TextEditingController();

  bool _fixLocation = false;
  bool _fixPoint = false;
  bool _fixCondition = false;
  bool _fixName = false;
  bool _saving = false;

  String? _newLocation;
  AssetCondition _newCondition = AssetCondition.baik;

  @override
  void initState() {
    super.initState();
    final asset = ref.read(assetByIdProvider(widget.assetId));
    if (asset != null) {
      _name.text = asset.name;
      _newCondition = asset.condition;
    }
    _reason.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    _reason.dispose();
    super.dispose();
  }

  int get _count =>
      [_fixLocation, _fixPoint, _fixCondition, _fixName].where((v) => v).length;

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/aset/${widget.assetId}');
    }
  }

  static String _point(GeoPoint p) =>
      '${p.lat.toStringAsFixed(6)}, ${p.lng.toStringAsFixed(6)}';

  Future<void> _submit(Asset asset) async {
    final pos = ref.read(userPositionProvider);
    if (_fixPoint && pos == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Titik di peta butuh GPS — tunggu sinyal')),
      );
      return;
    }
    final changes = <String, String>{
      if (_fixLocation && _newLocation != null) 'Lokasi / Pad': _newLocation!,
      if (_fixPoint && pos != null) 'Titik di peta': _point(pos),
      if (_fixCondition) 'Kondisi': _newCondition.code,
      if (_fixName && _name.text.trim().isNotEmpty)
        'Nama / keterangan': _name.text.trim(),
    };
    if (changes.isEmpty) return;

    setState(() => _saving = true);
    try {
      await ref.read(adjustmentsProvider.notifier).submit(
            AdjustmentRequest(
              assetId: asset.id,
              changes: changes,
              reason: _reason.text.trim(),
              createdAt: DateTime.now(),
              userId: ref.read(authProvider)?.email ?? '',
            ),
          );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('${changes.length} usulan dikirim · menunggu persetujuan'),
      ),
    );
    _close();
  }

  @override
  Widget build(BuildContext context) {
    final asset = ref.watch(assetByIdProvider(widget.assetId));
    final pos = ref.watch(userPositionProvider);
    if (asset == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Aset ${widget.assetId} tidak ditemukan')),
      );
    }
    final locations = {
      for (final a in ref.watch(assetsProvider)) a.group,
    }.where((g) => g != asset.group).toList();

    final canSubmit = _count > 0 &&
        _reason.text.trim().isNotEmpty &&
        (!_fixLocation || _newLocation != null);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Row(
              children: [
                RoundIconButton(icon: Icons.arrow_back, onTap: _close),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${asset.name.toUpperCase()} · ECC ${asset.eccNumber}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ok,
                        ),
                      ),
                      const Text(
                        'Stock Adjustment',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Centang data yang ingin dikoreksi. Data lama tetap tersimpan '
              'di riwayat.',
              style: TextStyle(fontSize: 12, color: AppColors.muted),
            ),
            const SizedBox(height: 12),
            _FieldCard(
              title: 'Lokasi / Pad',
              current: 'Tercatat: ${asset.group}',
              checked: _fixLocation,
              onToggle: () => setState(() => _fixLocation = !_fixLocation),
              editor: _NewValueBox(
                child: DropdownButton<String>(
                  value: _newLocation,
                  isExpanded: true,
                  isDense: true,
                  underline: const SizedBox.shrink(),
                  hint: const Text('Pilih lokasi baru'),
                  items: [
                    for (final l in locations)
                      DropdownMenuItem(value: l, child: Text(l)),
                  ],
                  onChanged: (v) => setState(() => _newLocation = v),
                ),
              ),
            ),
            _FieldCard(
              title: 'Titik di peta',
              current: 'Tercatat: ${asset.lat.toStringAsFixed(5)}, '
                  '${asset.lng.toStringAsFixed(5)}',
              checked: _fixPoint,
              onToggle: () => setState(() => _fixPoint = !_fixPoint),
              editor: _NewValueBox(
                child: Text(
                  pos == null
                      ? 'Menunggu sinyal GPS…'
                      : 'Pakai posisi saya: ${_point(pos)} '
                          '(akurasi ${pos.accuracy.round()} m)',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.forest,
                  ),
                ),
              ),
            ),
            _FieldCard(
              title: 'Kondisi',
              current: 'Tercatat: ${asset.condition.code} '
                  '(${asset.condition.label})',
              checked: _fixCondition,
              onToggle: () => setState(() => _fixCondition = !_fixCondition),
              editor: ConditionSelector(
                value: _newCondition,
                onChanged: (v) => setState(() => _newCondition = v),
              ),
            ),
            _FieldCard(
              title: 'Nama / keterangan',
              current: 'Tercatat: ${asset.name}',
              checked: _fixName,
              onToggle: () => setState(() => _fixName = !_fixName),
              editor: TextField(controller: _name),
            ),
            const SectionLabel('Alasan penyesuaian', required: true),
            TextField(
              controller: _reason,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'mis. genset dipindah ke Pad B sejak Agustus',
              ),
            ),
            const SizedBox(height: 12),
            const InfoBox(
              color: AppColors.info,
              background: AppColors.infoSoft,
              text: 'Perubahan dikirim sebagai usulan dan berlaku di peta '
                  'setelah disetujui admin di website.',
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAction(
        child: FilledButton(
          onPressed: canSubmit && !_saving ? () => _submit(asset) : null,
          child: Text(
            _count == 0
                ? 'Pilih data yang dikoreksi'
                : 'Ajukan $_count penyesuaian',
          ),
        ),
      ),
    );
  }
}

class _FieldCard extends StatelessWidget {
  const _FieldCard({
    required this.title,
    required this.current,
    required this.checked,
    required this.onToggle,
    required this.editor,
  });

  final String title;
  final String current;
  final bool checked;
  final VoidCallback onToggle;
  final Widget editor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        padding: const EdgeInsets.all(12),
        border: Border.all(
          color: checked ? AppColors.forest : AppColors.line,
          width: checked ? 1.6 : 1,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: onToggle,
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: checked ? AppColors.forest : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: checked ? AppColors.forest : AppColors.line,
                        width: 1.5,
                      ),
                    ),
                    child: checked
                        ? const Icon(Icons.check,
                            size: 16, color: AppColors.lime)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          current,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (checked) ...[
              const SizedBox(height: 10),
              editor,
            ],
          ],
        ),
      ),
    );
  }
}

/// Kotak abu berisi nilai baru, diawali label "Baru".
class _NewValueBox extends StatelessWidget {
  const _NewValueBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Text(
            'Baru',
            style: TextStyle(fontSize: 11, color: AppColors.muted),
          ),
          const SizedBox(width: 10),
          Expanded(child: child),
        ],
      ),
    );
  }
}
