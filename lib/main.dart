import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/database/app_database.dart';
import 'shared/providers.dart';

Future<void> main() async {
  // Wajib sebelum memakai plugin (database) sebelum runApp.
  WidgetsFlutterBinding.ensureInitialized();
  final overrides = await loadLocalData(AppDatabase());
  runApp(ProviderScope(overrides: overrides, child: const AssetOpnameApp()));
}
