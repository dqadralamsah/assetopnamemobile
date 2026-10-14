import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

class AssetOpnameApp extends StatelessWidget {
  const AssetOpnameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Opname Aset',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
