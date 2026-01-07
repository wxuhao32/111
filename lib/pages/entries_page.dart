import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';

import '../models/entry_type.dart';
import '../models/entry_with_category.dart';
import '../models/month_summary.dart';
import '../scope/app_scope.dart';
import '../services/ledger_service.dart';
import '../utils/format.dart';
import '../widgets/empty_state.dart';

class EntriesPage extends StatefulWidget {
  const EntriesPage({super.key});

  @override
  State<EntriesPage> createState() => _EntriesPageState();
}

class _EntriesPageState extends State<EntriesPage> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month, 1);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: HexColor('#fafafa'),
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));

    final service = AppScope.of(context);

    return Scaffold(
      body: SafeArea(
        child: ValueListenableBuilder<int>(
          valueListenable: service.revision,
          builder: (context, _, __) {
            return FutureBuilder<_EntriesData>(
              future: _load(service),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data!;

                return Column(
                  children: [
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _MonthCard(
                        month: _month,
                        summary: data.summary,
                        onPickMonth: _pickMonth,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: data.entries.isEmpty
                          ? const EmptyState(
                              title: '本月还没有账单',
                              subtitle: '点击底部 + 记一笔吧',
                            )
                          : _EntriesList(entries: data.entries),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<_EntriesData> _load(LedgerService service) async {
    final summary = await service.monthSummary(_month);
    final entries = await service.entriesForMonth(_month);
    return _EntriesData(summary: summary, entries: entries);
  }

  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _month,
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(2100, 12, 31),
      helpText: '选择任意日期（将按月份筛选）',
    );
    if (picked == null) return;

    setState(() {
      _month = DateTime(picked.year, picked.month, 1);
    });
  }
}

class _EntriesData {
  final MonthSummary summary;
  final List<EntryWithCategory> entries;

  const _EntriesData({required this.summary, required this.entries});
}

class _MonthCard extends StatelessWidget {
  final DateTime month;
  final MonthSummary summary;
  final VoidCallback onPickMonth;

  const _MonthCard({
    required this.month,
    required this.summary,
    required this.onPickMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: HexColor('#54C395'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.calendar_month, color: HexColor('#ffffff')),
                Text(
                  '日常账本',
                  style: TextStyle(fontSize: 22, color: HexColor('#ffffff')),
                ),
                Icon(Icons.more_horiz, color: HexColor('#ffffff')),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: onPickMonth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${month.year}年',
                        style: TextStyle(fontSize: 11, color: HexColor('#ffffff')),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                            '${month.month.toString().padLeft(2, '0')}月',
                            style: TextStyle(fontSize: 21, color: HexColor('#ffffff')),
                          ),
                          Icon(Icons.expand_more, color: HexColor('#ffffff')),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 1.5,
                  height: 20,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: HexColor('#ffffff'),
                      borderRadius: BorderRadius.circular(0.75),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('支出', style: TextStyle(fontSize: 11, color: HexColor('#ffffff'))),
                    const SizedBox(height: 5),
                    Text(
                      Format.moneyCents(summary.totalExpenseCents),
                      style: TextStyle(fontSize: 21, color: HexColor('#ffffff')),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('收入', style: TextStyle(fontSize: 11, color: HexColor('#ffffff'))),
                    const SizedBox(height: 5),
                    Text(
                      Format.moneyCents(summary.totalIncomeCents),
                      style: TextStyle(fontSize: 21, color: HexColor('#ffffff')),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EntriesList extends StatelessWidget {
  final List<EntryWithCategory> entries;

  const _EntriesList({required this.entries});

  @override
  Widget build(BuildContext context) {
    final service = AppScope.of(context);

    final grouped = <DateTime, List<EntryWithCategory>>{};
    for (final e in entries) {
      final d = DateTime(e.entry.occurredAt.year, e.entry.occurredAt.month, e.entry.occurredAt.day);
      grouped.putIfAbsent(d, () => []).add(e);
    }

    final days = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];
        final items = grouped[day]!;

        int dayExpense = 0;
        int dayIncome = 0;
        for (final it in items) {
          if (it.entry.type == EntryType.expense) {
            dayExpense += it.entry.amountCents;
          } else {
            dayIncome += it.entry.amountCents;
          }
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Format.dateTitle(day),
                    style: TextStyle(fontSize: 16, color: HexColor('#666666')),
                  ),
                  Row(
                    children: [
                      Text(
                        '收入：${Format.moneyCents(dayIncome)}',
                        style: TextStyle(fontSize: 11, color: HexColor('#999999')),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '支出：${Format.moneyCents(dayExpense)}',
                        style: TextStyle(fontSize: 11, color: HexColor('#999999')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: HexColor('#E6E6E6')),
            ...items.map((it) {
              final amountText = Format.moneyWithSign(it.entry.type, it.entry.amountCents);
              return Dismissible(
                key: ValueKey('entry_${it.entry.id}'),
                background: Container(
                  color: Colors.redAccent,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) async {
                  return await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('删除这笔账？'),
                          content: const Text('删除后无法恢复。'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('取消'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('删除'),
                            ),
                          ],
                        ),
                      ) ??
                      false;
                },
                onDismissed: (_) {
                  final id = it.entry.id;
                  if (id != null) {
                    service.deleteEntry(id);
                  }
                },
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: HexColor('#F3F3F3'),
                    child: Icon(it.category.icon, color: HexColor('#54C395')),
                  ),
                  title: Text(
                    it.category.name,
                    style: TextStyle(fontSize: 14, color: HexColor('#666666')),
                  ),
                  subtitle: (it.entry.note == null || it.entry.note!.trim().isEmpty)
                      ? null
                      : Text(
                          it.entry.note!,
                          style: TextStyle(fontSize: 11, color: HexColor('#999999')),
                        ),
                  trailing: Text(
                    amountText,
                    style: TextStyle(fontSize: 14, color: HexColor('#333333')),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
