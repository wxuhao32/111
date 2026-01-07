import 'package:flutter/widgets.dart';

import '../services/ledger_service.dart';

class AppScope extends InheritedWidget {
  final LedgerService service;

  const AppScope({
    super.key,
    required this.service,
    required super.child,
  });

  static LedgerService of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    if (scope == null) {
      throw StateError('AppScope not found. Make sure LimeApp wraps your widget tree with AppScope.');
    }
    return scope.service;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) => service != oldWidget.service;
}
