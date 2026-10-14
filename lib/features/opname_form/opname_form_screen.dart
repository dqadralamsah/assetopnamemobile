import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../shared/models/asset.dart';
import '../../shared/models/opname_result.dart';
import '../../shared/providers.dart';
import '../../shared/utils/format.dart';
import '../../shared/widgets/ui.dart';

/// Form Hasil Opname — dipakai untuk alur Scan dan Manual (langkah 2/2).
class OpnameFormScreen extends ConsumerStatefulWidget {
  const OpnameFormScreen({
    super.key,
    required this.assetId,
    required this.method,
    this.manualReason = '',
  });

  final String assetId;
  final OpnameMethod method;
  final String manualReason;

  @override
  ConsumerState<OpnameFormScreen> createState() => _OpnameFormScreenState();
}

class _OpnameFormScreenState extends ConsumerState<OpnameFormScreen> {
  final _note = TextEditingController();

  OpnameStatus _status = OpnameStatus.sesuai;
  AssetCondition _condition = AssetCondition.baik;
  int _photos = 0;
  bool _labelPhoto = false;
  bool _showErrors = false;
  bool _saving = false;

  bool get _isManual => widget.method == OpnameMethod.manual;

  @override
  void initState() {
    super.initState();
    // Isi awal: hasil sebelumnya (kalau ada), kalau tidak pakai kondisi master.
    final existing = ref.read(opnameResultsProvider)[widget.assetId];
    final asset = ref.read(assetByIdProvider(widget.assetId));
    if (existing != null) {
      _status = existing.status;
      _condition = existing.condition;
      _note.text = existing.note;
      // Koreksi dengan metode yang sama: foto sebelumnya dianggap masih ada.
      if (existing.method == widget.method) _photos = existing.photoCount;
    } else if (asset != null) {
      _condition = asset.condition;
    }
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/beranda');
    }
  }

  /// Simulasi ambil foto. Nanti: image_picker + kompres.
  void _takePhoto() {
    setState(() => _photos++);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Foto ditambahkan (simulasi, kamera menyusul)'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _save() async {
    if (_isManual && _photos == 0) {
      setState(() => _showErrors = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Input manual wajib foto aset')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(opnameHistoryProvider.notifier).save(
            OpnameResult(
              periodId: ref.read(activePeriodProvider).id,
              assetId: widget.assetId,
              method: widget.method,
              status: _status,
              condition: _condition,
              recordedAt: DateTime.now(),
              note: _note.text.trim(),
              manualReason: _isManual ? widget.manualReason : '',
              photoCount: _photos + (_labelPhoto ? 1 : 0),
              gpsDistanceM: ref.read(distanceProvider(widget.assetId)),
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
      const SnackBar(content: Text('Hasil tersimpan · menunggu dikirim')),
    );
    context.go('/aset/${widget.assetId}');
  }

  @override
  Widget build(BuildContext context) {
    final asset = ref.watch(assetByIdProvider(widget.assetId));
    if (asset == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Aset ${widget.assetId} tidak ditemukan')),
      );
    }
    final distance = ref.watch(distanceProvider(asset.id));
    final needsReprint = labelReprintReasons.contains(widget.manualReason);

    final subtitle = _isManual
        ? 'Alasan: ${widget.manualReason} · tercatat: ${asset.condition.code}'
        : 'Kondisi tercatat: ${asset.condition.code} (${asset.condition.label})';

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          AssetHeader(
            asset: asset,
            subtitle: subtitle,
            onBack: _back,
            badge: widget.method.badge,
            badgeColor: _isManual ? AppColors.warn : AppColors.lime,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_isManual) ..._manualPhotoSection(),
                const SectionLabel('Hasil pemeriksaan'),
                StatusOptionGrid(
                  value: _status,
                  onChanged: (v) => setState(() => _status = v),
                ),
                const SectionLabel('Kondisi saat ini'),
                ConditionSelector(
                  value: _condition,
                  onChanged: (v) => setState(() => _condition = v),
                ),
                if (!_isManual) ..._scanPhotoSection(),
                const SectionLabel('Catatan'),
                TextField(
                  controller: _note,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Opsional, mis. oli bocor sedikit',
                  ),
                ),
                const SizedBox(height: 14),
                InfoBox(
                  icon: Icons.location_on_outlined,
                  color: AppColors.ok,
                  background: AppColors.okSoft,
                  text: _isManual
                      ? 'GPS tercatat · ${formatDistance(distance)} dari titik aset'
                      : '${formatDistance(distance)} dari titik aset · '
                          'akurasi GPS 8 m (simulasi)',
                ),
                if (_isManual && needsReprint) ...[
                  const SizedBox(height: 8),
                  const InfoBox(
                    icon: Icons.print_outlined,
                    text: 'Permintaan cetak label baru dibuat otomatis.',
                  ),
                ],
                const SizedBox(height: 12),
                AppCard(
                  color: AppColors.lime,
                  onTap: () => context.push('/adjust/${asset.id}'),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.forest,
                        child: Icon(
                          Icons.edit_outlined,
                          size: 16,
                          color: AppColors.lime,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Data aset tidak sesuai?',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                            Text(
                              'Stock adjustment: koreksi lokasi, kondisi, data',
                              style: TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAction(
        child: FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon: const Icon(Icons.check, size: 18),
          label: Text(_isManual ? 'Simpan hasil manual' : 'Simpan hasil'),
        ),
      ),
    );
  }

  /// Manual: foto aset wajib + foto label (opsional).
  List<Widget> _manualPhotoSection() {
    final missing = _showErrors && _photos == 0;
    return [
      const SectionLabel('Foto aset', required: true),
      Row(
        children: [
          Expanded(
            flex: 2,
            child: DashedBox(
              color: missing ? AppColors.danger : AppColors.warn,
              background: _photos > 0 ? AppColors.okSoft : AppColors.warnSoft,
              onTap: _takePhoto,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _photos > 0
                        ? Icons.check_circle
                        : Icons.photo_camera_outlined,
                    color: _photos > 0 ? AppColors.ok : AppColors.warn,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _photos > 0 ? '$_photos foto · tambah' : 'Ambil foto aset',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _photos > 0 ? AppColors.ok : AppColors.warn,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _labelPhoto = !_labelPhoto),
              child: Container(
                height: 84,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _labelPhoto ? AppColors.okSoft : AppColors.line,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _labelPhoto ? 'Foto label ✓' : 'Foto label rusak\n(opsional)',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ),
            ),
          ),
        ],
      ),
      if (missing)
        const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Text(
            'Foto aset wajib untuk input manual',
            style: TextStyle(fontSize: 12, color: AppColors.danger),
          ),
        ),
    ];
  }

  /// Scan: foto bukti (opsional).
  List<Widget> _scanPhotoSection() {
    return [
      const SectionLabel('Foto bukti'),
      Row(
        children: [
          for (var i = 0; i < _photos; i++) ...[
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Foto ${i + 1}',
                style: const TextStyle(fontSize: 11, color: AppColors.muted),
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (_photos < 3)
            SizedBox(
              width: 72,
              child: DashedBox(
                height: 72,
                onTap: _takePhoto,
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.photo_camera_outlined,
                        size: 20, color: AppColors.forest),
                    Text(
                      'Ambil',
                      style: TextStyle(fontSize: 11, color: AppColors.forest),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ];
  }
}
