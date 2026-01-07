import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';

class MePage extends StatelessWidget {
  const MePage({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: HexColor('#fafafa'),
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));

    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('青柠记账（本地单机版）', style: TextStyle(fontSize: 16, color: HexColor('#333333'))),
                    const SizedBox(height: 8),
                    Text(
                      '第一版只做：记账 / 分类 / 明细 / 报表。\n\n后续可扩展（但第一版禁止做）：\n- 多账本\n- 预算\n- 导出\n- 云同步\n- 登录',
                      style: TextStyle(fontSize: 12, color: HexColor('#666666'), height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('关于'),
            subtitle: const Text('本项目用于学习与二次开发。'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Lime MVP',
                applicationVersion: '1.0.0',
                children: const [
                  Text('本地 SQLite 保存，不联网，不登录。'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
