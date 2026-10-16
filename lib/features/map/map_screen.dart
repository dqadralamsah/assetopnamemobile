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

enum _MapFilter { all, pending, problem, ok }

/// Menu Peta.
///
/// Sementara memakai peta skematik (titik aset digambar dari lat/lng)
/// supaya bisa jalan tanpa akun/penyedia peta. Ganti [_SchematicMap]
/// dengan `flutter_map` + OpenStreetMap setelah dicek web app pakai peta apa.
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  _MapFilter _filter = _MapFilter.all;
  String _query = '';
  String? _selectedId;

  bool _matches(Asset a, OpnameResult? r) {
    final q = _query.trim().toLowerCase();
    final matchQuery = q.isEmpty ||
        a.name.toLowerCase().contains(q) ||
        a.eccNumber.contains(q) ||
        a.group.toLowerCase().contains(q);
    final matchFilter = switch (_filter) {
      _MapFilter.all => true,
      _MapFilter.pending => r == null,
      _MapFilter.problem => r != null && r.status.isProblem,
      _MapFilter.ok => r != null && !r.status.isProblem,
    };
    return matchQuery && matchFilter;
  }

  @override
  Widget build(BuildContext context) {
    final assets = ref.watch(assetsProvider);
    final results = ref.watch(opnameResultsProvider);
    final visible = assets.where((a) => _matches(a, results[a.id])).toList();
    final selected =
        _selectedId == null ? null : ref.watch(assetByIdProvider(_selectedId!));

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: _SchematicMap(
              assets: assets,
              visibleIds: visible.map((a) => a.id).toSet(),
              results: results,
              selectedId: _selectedId,
              onSelect: (id) => setState(() => _selectedId = id),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Cari aset atau lokasi',
                            prefixIcon: Icon(Icons.search, size: 20),
                          ),
                          onChanged: (v) => setState(() => _query = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      RoundIconButton(
                        icon: Icons.my_location,
                        background: AppColors.forest,
                        color: AppColors.lime,
                        onTap: () => setState(() => _selectedId = null),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final f in _MapFilter.values) ...[
                          PillChoice(
                            label: switch (f) {
                              _MapFilter.all => 'Semua',
                              _MapFilter.pending => 'Belum',
                              _MapFilter.problem => 'Bermasalah',
                              _MapFilter.ok => 'Sesuai',
                            },
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
          if (selected != null)
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: _SelectedCard(
                asset: selected,
                result: results[selected.id],
              ),
            ),
        ],
      ),
    );
  }
}

class _SelectedCard extends ConsumerWidget {
  const _SelectedCard({required this.asset, required this.result});

  final Asset asset;
  final OpnameResult? result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final distance = ref.watch(distanceProvider(asset.id));
    return Material(
      elevation: 6,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(18),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () => context.go('/aset/${asset.id}'),
              child: Row(
                children: [
                  AssetIcon(kind: asset.kind),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          asset.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          'ECC ${asset.eccNumber} · ${asset.location}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.muted,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatDistance(distance),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      OpnameBadge(result: result),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(46),
                    ),
                    onPressed: () => context.push('/manual?aset=${asset.id}'),
                    child: Text(
                      result == null ? 'Catat opname' : 'Catat ulang',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                RoundIconButton(
                  icon: Icons.qr_code_scanner,
                  background: AppColors.bg,
                  onTap: () => context.push('/scan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Peta skematik: jalan & area pad digambar sederhana, titik aset
/// diposisikan dari koordinat lat/lng.
class _SchematicMap extends ConsumerWidget {
  const _SchematicMap({
    required this.assets,
    required this.visibleIds,
    required this.results,
    required this.selectedId,
    required this.onSelect,
  });

  final List<Asset> assets;
  final Set<String> visibleIds;
  final Map<String, OpnameResult> results;
  final String? selectedId;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userPositionProvider);

    // Batas koordinat semua aset + sedikit margin. Posisi petugas tidak ikut,
    // supaya peta tidak mengecil saat petugas jauh dari aset.
    var minLat = assets.first.lat, maxLat = minLat;
    var minLng = assets.first.lng, maxLng = minLng;
    for (final a in assets) {
      if (a.lat < minLat) minLat = a.lat;
      if (a.lat > maxLat) maxLat = a.lat;
      if (a.lng < minLng) minLng = a.lng;
      if (a.lng > maxLng) maxLng = a.lng;
    }
    final latSpan = maxLat - minLat;
    final lngSpan = maxLng - minLng;
    final midLat = (minLat + maxLat) / 2;
    final midLng = (minLng + maxLng) / 2;

    // Kelompok per lokasi untuk menggambar area pad.
    final groups = <String, List<Asset>>{};
    for (final a in assets) {
      groups.putIfAbsent(a.location, () => []).add(a);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        // Sisakan ruang untuk pencarian (atas), kartu (bawah), dan area pad
        // di tepi kiri/kanan supaya tidak terpotong.
        const top = 150.0, side = 40.0;
        final h = constraints.maxHeight - top - 110;
        final mw = w - side * 2;

        Offset toPoint(double lat, double lng) => Offset(
              w / 2 + (lng - midLng) / lngSpan * mw,
              top + h / 2 - (lat - midLat) / latSpan * h,
            );

        final userPoint = user == null ? null : toPoint(user.lat, user.lng);

        // Cubit/geser untuk memperbesar peta.
        return InteractiveViewer(
          maxScale: 5,
          child: GestureDetector(
            onTap: () => onSelect(null),
            child: Container(
              color: const Color(0xFFE6E4DC),
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  // Jalan
                  Positioned(
                    left: w * 0.56,
                    top: 0,
                    bottom: 0,
                    child: Container(width: 16, color: Colors.white),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: top + h * 0.46,
                    child: Transform.rotate(
                      angle: -0.12,
                      child: Container(height: 16, color: Colors.white),
                    ),
                  ),
                  // Area pad
                  for (final entry in groups.entries)
                    _padArea(entry.key, entry.value, toPoint),
                  // Posisi petugas (di luar layar terpotong oleh Clip.hardEdge)
                  if (userPoint != null)
                    Positioned(
                      left: userPoint.dx - 32,
                      top: userPoint.dy - 32,
                      child: Container(
                        width: 64,
                        height: 64,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.info.withValues(alpha: 0.15),
                        ),
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.info,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                        ),
                      ),
                    ),
                  // Titik aset
                  for (final a in assets)
                    if (visibleIds.contains(a.id))
                      _marker(a, toPoint(a.lat, a.lng)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _padArea(
    String name,
    List<Asset> items,
    Offset Function(double, double) toPoint,
  ) {
    var left = double.infinity, top = double.infinity;
    var right = -double.infinity, bottom = -double.infinity;
    for (final a in items) {
      final p = toPoint(a.lat, a.lng);
      if (p.dx < left) left = p.dx;
      if (p.dx > right) right = p.dx;
      if (p.dy < top) top = p.dy;
      if (p.dy > bottom) bottom = p.dy;
    }
    const pad = 22.0;
    return Positioned(
      left: left - pad,
      top: top - pad,
      width: right - left + pad * 2,
      height: bottom - top + pad * 2,
      child: Container(
        padding: const EdgeInsets.all(6),
        alignment: Alignment.bottomLeft,
        decoration: BoxDecoration(
          color: AppColors.ok.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.ok.withValues(alpha: 0.35)),
        ),
        child: Text(
          name.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: AppColors.muted,
          ),
        ),
      ),
    );
  }

  Widget _marker(Asset a, Offset p) {
    final selected = a.id == selectedId;
    final size = selected ? 30.0 : 22.0;
    return Positioned(
      left: p.dx - size / 2,
      top: p.dy - size / 2,
      child: GestureDetector(
        onTap: () => onSelect(a.id),
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.forest : Colors.white,
            borderRadius: BorderRadius.circular(size * 0.32),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 4),
            ],
          ),
          child: StatusDot(
            color:
                selected ? AppColors.lime : statusColor(results[a.id]?.status),
            size: selected ? 12 : 10,
          ),
        ),
      ),
    );
  }
}
