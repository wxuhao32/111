import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';

import '../models/category.dart';
import '../models/entry_type.dart';
import '../models/ledger_entry.dart';
import '../scope/app_scope.dart';
import '../services/ledger_service.dart';
import '../utils/format.dart';
import '../widgets/category_grid.dart';

class AddEntryPage extends StatefulWidget {
  const AddEntryPage({super.key});

  @override
  State<AddEntryPage> createState() => _AddEntryPageState();
}

class _AddEntryPageState extends State<AddEntryPage> with TickerProviderStateMixin {
  late final TabController _tabController;

  EntryType _type = EntryType.expense;
  Category? _selectedCategory;
  DateTime _occurredAt = DateTime.now();

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _noteController.dispose();
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
        leadingWidth: 100,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Row(
            children: [
              const Text('日常账本'),
              Icon(Icons.expand_more, color: HexColor('#333333')),
            ],
          ),
        ),
        title: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorSize: TabBarIndicatorSize.label,
          indicatorColor: HexColor('#54C395'),
          onTap: (index) {
            setState(() {
              _type = index == 0 ? EntryType.expense : EntryType.income;
              _selectedCategory = null;
            });
          },
          tabs: const [
            Tab(text: '支出'),
            Tab(text: '收入'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Category>>(
              future: service.categoriesByType(_type),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final categories = snapshot.data!;
                return CategoryGrid(
                  categories: categories,
                  selectedCategoryId: _selectedCategory?.id,
                  onSelect: (c) => setState(() => _selectedCategory = c),
                );
              },
            ),
          ),
          _BottomForm(
            occurredAt: _occurredAt,
            amountController: _amountController,
            noteController: _noteController,
            onPickDate: _pickDate,
            onSave: () => _save(service),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _occurredAt,
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(2100, 12, 31),
    );
    if (picked == null) return;
    setState(() {
      _occurredAt = DateTime(picked.year, picked.month, picked.day);
    });
  }

  Future<void> _save(LedgerService service) async {
    final category = _selectedCategory;
    if (category == null) {
      _toast('请选择一个分类');
      return;
    }

    final cents = _parseAmountToCents(_amountController.text.trim());
    if (cents <= 0) {
      _toast('请输入正确金额，例如 12.34');
      return;
    }

    final entry = LedgerEntry(
      type: _type,
      categoryId: category.id,
      amountCents: cents,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      occurredAt: _occurredAt,
    );

    await service.addEntry(entry);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  int _parseAmountToCents(String input) {
    final normalized = input.replaceAll('￥', '').replaceAll(',', '');
    final value = double.tryParse(normalized);
    if (value == null) return 0;
    return (value * 100).round();
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}

class _BottomForm extends StatelessWidget {
  final DateTime occurredAt;
  final TextEditingController amountController;
  final TextEditingController noteController;
  final VoidCallback onPickDate;
  final VoidCallback onSave;

  const _BottomForm({
    required this.occurredAt,
    required this.amountController,
    required this.noteController,
    required this.onPickDate,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: HexColor('#E6E6E6'))),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      prefixText: '￥',
                      labelText: '金额',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: onPickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: HexColor('#E6E6E6')),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.event, size: 18, color: HexColor('#666666')),
                        const SizedBox(width: 8),
                        Text(
                          Format.dateTitle(occurredAt),
                          style: TextStyle(color: HexColor('#666666')),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: '备注（可选）',
                border: OutlineInputBorder(),
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: HexColor('#54C395'),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
