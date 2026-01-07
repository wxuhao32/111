import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

import 'pages/tabs.dart';
import 'services/ledger_service.dart';
import 'scope/app_scope.dart';

class LimeApp extends StatelessWidget {
  final LedgerService service;

  const LimeApp({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final primary = HexColor('#54C395');

    return AppScope(
      service: service,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: false,
          scaffoldBackgroundColor: HexColor('#fafafa'),
          colorScheme: ColorScheme.fromSeed(seedColor: primary),
          appBarTheme: AppBarTheme(
            backgroundColor: HexColor('#fafafa'),
            foregroundColor: HexColor('#333333'),
            elevation: 1,
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: HexColor('#333333'),
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
            iconTheme: IconThemeData(color: HexColor('#333333')),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedItemColor: primary,
            unselectedItemColor: HexColor('#999999'),
            type: BottomNavigationBarType.fixed,
          ),
        ),
        home: const Tabs(),
      ),
    );
  }
}
