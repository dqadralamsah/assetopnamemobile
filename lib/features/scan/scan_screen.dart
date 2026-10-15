import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../app/theme.dart';
import '../../shared/models/asset.dart';
import '../../shared/providers.dart';
import '../../shared/widgets/ui.dart';

/// Layar Scan QR / Barcode (`mobile_scanner`, QR + Code 128).
///
/// Alur: kode → cari aset → Form Hasil (Scan). Di build debug, tap area
/// kamera = simulasi scan aset terdekat yang belum dicatat (label QR belum
/// dicetak).
class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _line = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  // Kedua format selalu dibaca; toggle QR/Barcode hanya mengubah bingkai.
  final _scanner = MobileScannerController(
    formats: const [BarcodeFormat.qrCode, BarcodeFormat.code128],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  bool _barcode = false;
  bool _flash = false;
  Asset? _detected;

  @override
  void dispose() {
    _line.dispose();
    _scanner.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code != null && code != _detected?.id) _onCodeDetected(code);
  }

  void _onCodeDetected(String code) {
    final asset = ref.read(assetByIdProvider(code));
    if (asset == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kode "$code" tidak terdaftar sebagai aset')),
      );
      return;
    }
    setState(() => _detected = asset);
  }

  void _simulateScan() {
    final asset =
        ref.read(nearestPendingAssetProvider) ?? ref.read(assetsProvider).first;
    _onCodeDetected(asset.id);
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/beranda');
    }
  }

  @override
  Widget build(BuildContext context) {
    final detected = _detected;

    return Scaffold(
      backgroundColor: const Color(0xFF16201B),
      body: Stack(
        children: [
          Positioned.fill(
            child: MobileScanner(
              controller: _scanner,
              onDetect: _onDetect,
              errorBuilder: (context, error) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'Kamera tidak bisa dipakai (${error.errorCode.name}).\n'
                    'Izinkan akses kamera di pengaturan HP, atau pakai '
                    'input manual.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Row(
                    children: [
                      RoundIconButton(
                        icon: Icons.close,
                        onTap: _close,
                        background: Colors.white.withValues(alpha: 0.12),
                        color: Colors.white,
                      ),
                      const Spacer(),
                      _ModeToggle(
                        barcode: _barcode,
                        onChanged: (v) => setState(() => _barcode = v),
                      ),
                      const Spacer(),
                      RoundIconButton(
                        icon: _flash ? Icons.flash_on : Icons.flash_off,
                        onTap: () {
                          _scanner.toggleTorch();
                          setState(() => _flash = !_flash);
                        },
                        background: Colors.white.withValues(alpha: 0.12),
                        color: _flash ? AppColors.lime : Colors.white,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: GestureDetector(
                      onTap: kDebugMode ? _simulateScan : null,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 240,
                            height: _barcode ? 150 : 240,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: _CornersPainter(AppColors.lime),
                                  ),
                                ),
                                AnimatedBuilder(
                                  animation: _line,
                                  builder: (context, _) => Align(
                                    alignment:
                                        Alignment(0, _line.value * 1.4 - 0.7),
                                    child: Container(
                                      height: 2,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 28,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.lime,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.lime
                                                .withValues(alpha: 0.6),
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            _barcode
                                ? 'Arahkan kamera ke barcode di label aset'
                                : 'Arahkan kamera ke QR code di label aset',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          if (kDebugMode) ...[
                            const SizedBox(height: 6),
                            const Text(
                              'Debug: tap bingkai = simulasi scan',
                              style: TextStyle(
                                  color: Colors.white38, fontSize: 11),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: detected == null
                      ? _NotDetected(
                          onManual: () => context.pushReplacement('/manual'),
                        )
                      : _Detected(
                          asset: detected,
                          onContinue: () => context.pushReplacement(
                            '/opname/${detected.id}?metode=scan',
                          ),
                          onManual: () => context.pushReplacement('/manual'),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.barcode, required this.onChanged});

  final bool barcode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget option(String label, bool value) {
      final selected = barcode == value;
      return GestureDetector(
        onTap: () => onChanged(value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? AppColors.lime : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.forest : Colors.white70,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [option('QR', false), option('Barcode', true)],
      ),
    );
  }
}

class _NotDetected extends StatelessWidget {
  const _NotDetected({required this.onManual});

  final VoidCallback onManual;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Mencari label…',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        const Text(
          'Pastikan label terlihat jelas dan cukup cahaya.',
          style: TextStyle(fontSize: 12, color: AppColors.muted),
        ),
        TextButton(
          onPressed: onManual,
          child: const Text('Label rusak / tidak ada? Input manual'),
        ),
      ],
    );
  }
}

class _Detected extends StatelessWidget {
  const _Detected({
    required this.asset,
    required this.onContinue,
    required this.onManual,
  });

  final Asset asset;
  final VoidCallback onContinue;
  final VoidCallback onManual;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.lime,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.check, color: AppColors.forest),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TERDETEKSI',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ok,
                    ),
                  ),
                  Text(
                    asset.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${asset.id} · ECC ${asset.eccNumber}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.muted,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: onContinue,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Lanjut isi hasil'),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward, size: 18),
            ],
          ),
        ),
        TextButton(
          onPressed: onManual,
          child: const Text('Label rusak / tidak ada? Input manual'),
        ),
      ],
    );
  }
}

/// Sudut-sudut bingkai kamera.
class _CornersPainter extends CustomPainter {
  _CornersPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    const len = 34.0;
    const r = 14.0;
    final w = size.width;
    final h = size.height;

    // kiri atas
    canvas.drawPath(
      Path()
        ..moveTo(0, len)
        ..lineTo(0, r)
        ..quadraticBezierTo(0, 0, r, 0)
        ..lineTo(len, 0),
      paint,
    );
    // kanan atas
    canvas.drawPath(
      Path()
        ..moveTo(w - len, 0)
        ..lineTo(w - r, 0)
        ..quadraticBezierTo(w, 0, w, r)
        ..lineTo(w, len),
      paint,
    );
    // kiri bawah
    canvas.drawPath(
      Path()
        ..moveTo(0, h - len)
        ..lineTo(0, h - r)
        ..quadraticBezierTo(0, h, r, h)
        ..lineTo(len, h),
      paint,
    );
    // kanan bawah
    canvas.drawPath(
      Path()
        ..moveTo(w - len, h)
        ..lineTo(w - r, h)
        ..quadraticBezierTo(w, h, w, h - r)
        ..lineTo(w, h - len),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CornersPainter oldDelegate) =>
      oldDelegate.color != color;
}
