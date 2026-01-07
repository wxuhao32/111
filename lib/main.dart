import 'package:flutter/material.dart';

import 'app.dart';
import 'db/app_db.dart';
import 'services/ledger_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDb();
  await db.init();

  final service = LedgerService(db);

  runApp(LimeApp(service: service));
}
