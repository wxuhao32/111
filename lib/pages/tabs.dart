import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

import 'add_entry_page.dart';
import 'entries_page.dart';
import 'me_page.dart';
import 'stats_page.dart';

class Tabs extends StatefulWidget {
  const Tabs({super.key});

  @override
  State<Tabs> createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  int _currentIndex = 0;

  late final List<Widget> _pages = const [
    EntriesPage(),
    StatsPage(),
    MePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final primary = HexColor('#54C395');

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: primary,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: '明细',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.addchart),
            label: '报表',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddEntryPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
