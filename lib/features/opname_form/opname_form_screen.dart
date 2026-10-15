import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

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

  /// Path foto aset (dari kamera). Disalin ke folder aplikasi saat simpan.
  final List<String> _photos = [];

  /// Foto label rusak (opsional, input manual).
  String? _labelPhoto;
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
      if (existing.method == widget.method) _photos.addAll(existing.photoPaths);
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

  /// Ambil foto dari kamera (bukan galeri, supaya foto pasti diambil di
  /// lokasi). Dikecilkan ke 1600 px / kualitas 70 → kira-kira 200–400 KB.
  Future<void> _takePhoto({bool label = false}) async {
    final XFile? shot;
    try {
      shot = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 1600,
        imageQuality: 70,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kamera tidak bisa dibuka: $e')),
      );
      return;
    }
    if (shot == null || !mounted) return; // batal di kamera
    setState(() => label ? _labelPhoto = shot!.path : _photos.add(shot!.path));
  }

  /// Salin foto ke folder aplikasi (file kamera ada di cache, bisa dihapus
  /// sistem). Selalu salinan baru per entri, supaya hapus foto entri lama
  /// saat logout tidak ikut menghapus foto koreksi.
  Future<List<String>> _persistPhotos(List<String> paths) async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = await Directory('${docs.path}/photos').create(recursive: true);
    final stamp = DateTime.now().millisecondsSinceEpoch;
    return [
      for (final (i, path) in paths.indexed)
        (await File(path).copy('${dir.path}/${widget.assetId}_${stamp}_$i.jpg'))
            .path,
    ];
  }

  Future<void> _save() async {
    if (_isManual && _photos.isEmpty) {
      setState(() => _showErrors = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Input manual wajib foto aset')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final photos = await _persistPhotos(
          [..._photos, if (_labelPhoto != null) _labelPhoto!]);
      await ref.read(opnameHistoryProvider.notifier).save(
            OpnameResult(
              periodId: ref.read(activePeriodProvider).id,
              assetId: widget.assetId,
              method: widget.method,
              status: _status,
              condition: _condition,
              recordedAt: DateTime.now(),
              userId: ref.read(authProvider)?.email ?? '',
              note: _note.text.trim(),
              manualReason: _isManual ? widget.manualReason : '',
              photoCount: photos.length,
              photoPaths: photos,
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
                _gpsInfo(distance),
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

  /// Info jarak GPS. Di luar [gpsToleranceM] → peringatan (tetap boleh simpan).
  Widget _gpsInfo(double? distance) {
    if (distance == null) {
      final gps = ref.watch(gpsProvider);
      return InfoBox(
        icon: Icons.location_searching,
        color: AppColors.warn,
        background: AppColors.warnSoft,
        text: gps.hasError
            ? 'GPS tidak tersedia: ${gps.error} · hasil tersimpan tanpa jarak'
            : 'Mencari sinyal GPS… (lebih cepat di tempat terbuka)',
      );
    }
    final accuracy = ref.watch(userPositionProvider)?.accuracy;
    if (distance > gpsToleranceM) {
      return InfoBox(
        icon: Icons.wrong_location_outlined,
        color: AppColors.warn,
        background: AppColors.warnSoft,
        text: 'Anda ${formatDistance(distance)} dari titik aset '
            '(batas ${gpsToleranceM.round()} m). Pastikan asetnya benar; '
            'kalau aset sudah pindah, ajukan stock adjustment.',
      );
    }
    return InfoBox(
      icon: Icons.location_on_outlined,
      color: AppColors.ok,
      background: AppColors.okSoft,
      text: '${formatDistance(distance)} dari titik aset'
          '${accuracy == null ? '' : ' · akurasi GPS ${accuracy.round()} m'}',
    );
  }

  /// Manual: foto aset wajib + foto label rusak (opsional).
  List<Widget> _manualPhotoSection() {
    final missing = _showErrors && _photos.isEmpty;
    final label = _labelPhoto;
    return [
      const SectionLabel('Foto aset', required: true),
      _photoStrip(color: missing ? AppColors.danger : AppColors.warn),
      if (missing)
        const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Text(
            'Foto aset wajib untuk input manual',
            style: TextStyle(fontSize: 12, color: AppColors.danger),
          ),
        ),
      const SectionLabel('Foto label rusak (opsional)'),
      Row(
        children: [
          if (label == null)
            _addPhotoBox(onTap: () => _takePhoto(label: true))
          else
            _thumbnail(label,
                onRemove: () => setState(() => _labelPhoto = null)),
        ],
      ),
    ];
  }

  /// Scan: foto bukti (opsional).
  List<Widget> _scanPhotoSection() {
    return [
      const SectionLabel('Foto bukti'),
      _photoStrip(),
    ];
  }

  /// Deretan foto + kotak "Ambil" sampai [_maxPhotos].
  Widget _photoStrip({Color color = AppColors.forest}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final (i, path) in _photos.indexed)
            _thumbnail(path,
                onRemove: () => setState(() => _photos.removeAt(i))),
          if (_photos.length < _maxPhotos)
            _addPhotoBox(
              onTap: _takePhoto,
              color: color,
              label:
                  _photos.isEmpty ? 'Ambil' : '${_photos.length}/$_maxPhotos',
            ),
        ],
      ),
    );
  }

  Widget _addPhotoBox({
    required VoidCallback onTap,
    Color color = AppColors.forest,
    String label = 'Ambil',
  }) {
    return SizedBox(
      width: 72,
      child: DashedBox(
        height: 72,
        color: color,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.photo_camera_outlined, size: 20, color: color),
            Text(label, style: TextStyle(fontSize: 11, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _thumbnail(String path, {required VoidCallback onRemove}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(path),
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              cacheWidth: 216,
              errorBuilder: (_, __, ___) => Container(
                width: 72,
                height: 72,
                color: AppColors.line,
                child: const Icon(Icons.broken_image_outlined,
                    color: AppColors.muted),
              ),
            ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: onRemove,
              child: const CircleAvatar(
                radius: 11,
                backgroundColor: Colors.black54,
                child: Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Batas foto per pencatatan, supaya penyimpanan HP & kuota tidak membengkak.
const _maxPhotos = 5;
