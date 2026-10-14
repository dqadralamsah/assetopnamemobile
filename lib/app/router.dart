import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/account/account_screen.dart';
import '../features/adjustment/stock_adjustment_screen.dart';
import '../features/assets/asset_detail_screen.dart';
import '../features/assets/asset_list_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/home/home_screen.dart';
import '../features/manual_input/manual_select_screen.dart';
import '../features/map/map_screen.dart';
import '../features/opname_form/opname_form_screen.dart';
import '../features/scan/scan_screen.dart';
import '../features/sync_status/sync_status_screen.dart';
import '../shared/models/opname_result.dart';
import 'theme.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Rute aplikasi.
///
/// Menu bawah: Beranda · Peta · [Scan] · Aset · Akun.
/// Beranda/Peta/Aset/Akun memakai [StatefulShellRoute] supaya posisi
/// tiap menu tersimpan. Scan, Input Manual, Form Hasil, Stock Adjustment,
/// dan Status Sync dibuka layar penuh (tanpa menu bawah).
final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/beranda',
            builder: (context, state) => const HomeScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/peta',
            builder: (context, state) => const MapScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/aset',
            builder: (context, state) => const AssetListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) =>
                    AssetDetailScreen(assetId: state.pathParameters['id']!),
              ),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/akun',
            builder: (context, state) => const AccountScreen(),
          ),
        ]),
      ],
    ),
    GoRoute(
      path: '/scan',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ScanScreen(),
    ),
    // Contoh: /manual?aset=AST-0001 (aset sudah dipilih dari daftar/peta)
    GoRoute(
      path: '/manual',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => ManualSelectScreen(
        initialAssetId: state.uri.queryParameters['aset'],
      ),
    ),
    // Contoh: /opname/AST-0001?metode=manual&alasan=Label%20rusak
    GoRoute(
      path: '/opname/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => OpnameFormScreen(
        assetId: state.pathParameters['id']!,
        method: state.uri.queryParameters['metode'] == 'manual'
            ? OpnameMethod.manual
            : OpnameMethod.scan,
        manualReason: state.uri.queryParameters['alasan'] ?? '',
      ),
    ),
    GoRoute(
      path: '/adjust/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) =>
          StockAdjustmentScreen(assetId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/sync',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SyncStatusScreen(),
    ),
  ],
);

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomBar(
        currentIndex: navigationShell.currentIndex,
        onSelect: (index) => navigationShell.goBranch(
          index,
          // Tekan menu yang sedang aktif → kembali ke halaman awal menu itu.
          initialLocation: index == navigationShell.currentIndex,
        ),
        onScan: () => context.push('/scan'),
      ),
    );
  }
}

/// Menu bawah hijau tua dengan tombol Scan di tengah (sesuai mockup).
class AppBottomBar extends StatelessWidget {
  const AppBottomBar({
    super.key,
    required this.currentIndex,
    required this.onSelect,
    required this.onScan,
  });

  /// Index branch: 0 Beranda, 1 Peta, 2 Aset, 3 Akun.
  final int currentIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    Widget item(int index, IconData icon, String label) {
      final selected = index == currentIndex;
      final color = selected ? AppColors.lime : Colors.white60;
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => onSelect(index),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: AppColors.bg,
      child: SafeArea(
        top: false,
        child: Container(
          height: 64,
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          decoration: BoxDecoration(
            color: AppColors.forest,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              item(0, Icons.home_outlined, 'Beranda'),
              item(1, Icons.map_outlined, 'Peta'),
              Expanded(
                child: Center(
                  child: Material(
                    color: AppColors.lime,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: onScan,
                      child: const SizedBox(
                        width: 52,
                        height: 48,
                        child: Icon(
                          Icons.qr_code_scanner,
                          color: AppColors.forest,
                          semanticLabel: 'Scan',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              item(2, Icons.inventory_2_outlined, 'Aset'),
              item(3, Icons.person_outline, 'Akun'),
            ],
          ),
        ),
      ),
    );
  }
}
