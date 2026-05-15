import 'package:flutter/material.dart';

import '../models/app_info.dart';
import '../theme/app_theme.dart';
import '../widgets/risk_card.dart';
import '../widgets/scan_button.dart';
import 'scan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int total = 0;
  int red = 0;
  int yellow = 0;
  int green = 0;

  Future<void> _openScan() async {
    final result = await Navigator.of(context).push<List<AppInfo>>(
      MaterialPageRoute(builder: (_) => const ScanScreen()),
    );
    if (result == null) return;
    setState(() {
      total = result.length;
      red = result.where((e) => e.risk == RiskLevel.red).length;
      yellow = result.where((e) => e.risk == RiskLevel.yellow).length;
      green = result.where((e) => e.risk == RiskLevel.green).length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aegis Ad-Shield'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed('/about'),
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Center(child: ScanButton(onTap: _openScan)),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.45,
                children: [
                  RiskCard(title: 'Scanned', value: '$total', color: kTextPrimary),
                  RiskCard(title: 'Critical', value: '$red', color: kCrimson),
                  RiskCard(title: 'Caution', value: '$yellow', color: kAmber),
                  RiskCard(title: 'Trusted', value: '$green', color: kEmerald),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
