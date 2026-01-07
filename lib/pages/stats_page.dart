import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';

import '../models/category_total.dart';
import '../models/entry_type.dart';
import '../scope/app_scope.dart';
import '../utils/date_ranges.dart';
import '../utils/format.dart';
import '../widgets/empty_state.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> with TickerProviderStateMixin {
  late final TabController _tabController;

  EntryType _type = EntryType.expense;
  StatsPeriod _period = StatsPeriod.month;
  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: HexColor('#fafafa'),
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));

    final service = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorSize: TabBarIndicatorSize.label,
          indicatorColor: HexColor('#54C395'),
          onTap: (index) {
            setState(() {
              _type = index == 0 ? EntryType.expense : EntryType.income;
              touchedIndex = -1;
            });
          },
          tabs: const [
            Tab(text: '支出'),
            Tab(text: '收入'),
          ],
        ),
      ),
      body: SafeArea(
        child: ValueListenableBuilder<int>(
          valueListenable: service.revision,
          builder: (context, _, __) {
            final range = PeriodRange.forPeriod(_period, DateTime.now());
            return FutureBuilder<List<CategoryTotal>>(
              future: service.categoryTotals(
                type: _type,
                start: range.start,
                endExclusive: range.endExclusive,
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data!;
                if (data.isEmpty) {
                  return Column(
                    children: [
                      _PeriodTabs(
                        period: _period,
                        onChange: (p) => setState(() {
                          _period = p;
                          touchedIndex = -1;
                        }),
                      ),
                      const Expanded(
                        child: EmptyState(
                          title: '暂无统计数据',
                          subtitle: '先记几笔账，再来看报表',
                        ),
                      ),
                    ],
                  );
                }

                final total = data.fold<int>(0, (sum, item) => sum + item.totalCents);

                return Column(
                  children: [
                    _PeriodTabs(
                      period: _period,
                      onChange: (p) => setState(() {
                        _period = p;
                        touchedIndex = -1;
                      }),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_type.displayName}总计：${Format.moneyCents(total)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            _periodLabel(_period),
                            style: TextStyle(fontSize: 12, color: HexColor('#999999')),
                          ),
                        ],
                      ),
                    ),
                    AspectRatio(
                      aspectRatio: 1.3,
                      child: Card(
                        elevation: 0,
                        color: HexColor('#fafafa'),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: PieChart(
                            PieChartData(
                              pieTouchData: PieTouchData(
                                touchCallback: (event, response) {
                                  setState(() {
                                    if (!event.isInterestedForInteractions || response == null || response.touchedSection == null) {
                                      touchedIndex = -1;
                                      return;
                                    }
                                    touchedIndex = response.touchedSection!.touchedSectionIndex;
                                  });
                                },
                              ),
                              borderData: FlBorderData(show: false),
                              sectionsSpace: 2,
                              centerSpaceRadius: 0,
                              sections: _buildSections(data, total),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('${_type.displayName}排行榜', style: const TextStyle(fontSize: 12)),
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.separated(
                        itemCount: data.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final item = data[i];
                          final ratio = total == 0 ? 0.0 : item.totalCents / total;
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: HexColor('#F3F3F3'),
                              child: Icon(item.category.icon, color: HexColor('#54C395')),
                            ),
                            title: Text(item.category.name, style: TextStyle(fontSize: 14, color: HexColor('#666666'))),
                            subtitle: Text('${(ratio * 100).toStringAsFixed(1)}%', style: TextStyle(fontSize: 11, color: HexColor('#999999'))),
                            trailing: Text(
                              Format.moneyCents(item.totalCents),
                              style: TextStyle(fontSize: 14, color: HexColor('#333333')),
                            ),
                          );
                        },
                      ),
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

  List<PieChartSectionData> _buildSections(List<CategoryTotal> data, int totalCents) {
    final palette = <Color>[
      HexColor('#54C395'),
      HexColor('#5C7CFA'),
      HexColor('#F59F00'),
      HexColor('#FA5252'),
      HexColor('#12B886'),
      HexColor('#7950F2'),
      HexColor('#15AABF'),
      HexColor('#E64980'),
      HexColor('#868E96'),
    ];

    return List.generate(data.length, (i) {
      final item = data[i];
      final value = item.totalCents.toDouble();
      final isTouched = i == touchedIndex;
      final percent = totalCents == 0 ? 0.0 : (item.totalCents / totalCents * 100);

      return PieChartSectionData(
        color: palette[i % palette.length],
        value: value,
        radius: isTouched ? 70 : 60,
        title: percent < 5 ? '' : '${percent.toStringAsFixed(0)}%',
        titleStyle: TextStyle(
          fontSize: isTouched ? 14 : 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      );
    });
  }

  String _periodLabel(StatsPeriod p) {
    return switch (p) {
      StatsPeriod.week => '近7天',
      StatsPeriod.month => '本月',
      StatsPeriod.year => '今年',
    };
  }
}

class _PeriodTabs extends StatelessWidget {
  final StatsPeriod period;
  final ValueChanged<StatsPeriod> onChange;

  const _PeriodTabs({required this.period, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final primary = HexColor('#54C395');

    Widget chip(StatsPeriod p, String text) {
      final selected = p == period;
      return InkWell(
        onTap: () => onChange(p),
        borderRadius: BorderRadius.circular(45),
        child: Container(
          width: 90,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? primary : Colors.transparent,
            borderRadius: BorderRadius.circular(45),
            border: Border.all(color: HexColor('#A1A2A9')),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black,
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          chip(StatsPeriod.week, '周'),
          const SizedBox(width: 8),
          chip(StatsPeriod.month, '月'),
          const SizedBox(width: 8),
          chip(StatsPeriod.year, '年'),
        ],
      ),
    );
  }
}
