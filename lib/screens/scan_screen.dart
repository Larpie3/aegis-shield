import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/app_info.dart';
import '../services/scan_service.dart';
import '../services/whitelist_service.dart';
import '../theme/app_theme.dart';
import '../widgets/shimmer_list.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _scanService = ScanService();
  final _whitelistService = WhitelistService();

  bool _loading = true;
  double _progress = 0;
  String _step = 'Preparing';
  List<AppInfo> _apps = <AppInfo>[];

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    final whitelist = await _whitelistService.loadWhitelist();
    await for (final update in _scanService.runScan(whitelist: whitelist)) {
      if (!mounted) return;
      setState(() {
        _progress = update.progress;
        _step = update.currentStep;
      });
      if (update.result != null) {
        final hasRed = update.result!.any((e) => e.risk == RiskLevel.red);
        if (hasRed) {
          await HapticFeedback.heavyImpact();
        } else {
          await HapticFeedback.lightImpact();
        }
        setState(() {
          _apps = update.result!;
          _loading = false;
        });
      }
    }
  }

  Future<void> _toggleWhitelist(AppInfo app, bool value) async {
    await _whitelistService.setWhitelisted(app.packageName, value);
    setState(() => app.isWhitelisted = value);
  }

  Future<void> _purgeApp(AppInfo app) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Purge'),
        content: Text(
          'Are you sure you want to purge ${app.appName}? This will open the system uninstall screen.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: kCrimson),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Purge'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _scanService.requestUninstall(app.packageName);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening uninstall screen...'), backgroundColor: kEmerald),
    );
  }

  Color _riskColor(RiskLevel risk) {
    switch (risk) {
      case RiskLevel.red:
        return kCrimson;
      case RiskLevel.yellow:
        return kAmber;
      case RiskLevel.green:
        return kEmerald;
    }
  }

  String _riskName(RiskLevel risk) => risk.name.toUpperCase();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Scan'),
        actions: [
          IconButton(
            onPressed: _loading
                ? null
                : () {
                    Navigator.of(context).pop(_apps);
                  },
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _LiquidProgress(progress: _progress, step: _step),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? const ShimmerList(count: 6)
                  : ListView.separated(
                      itemCount: _apps.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final app = _apps[i];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: kSurface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: kCardBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(app.appName, style: const TextStyle(fontWeight: FontWeight.w700)),
                                        Text(app.packageName, style: const TextStyle(color: kTextSecondary, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _riskColor(app.risk).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      _riskName(app.risk),
                                      style: TextStyle(color: _riskColor(app.risk), fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ...app.reasons.map((reason) => Text('• $reason', style: const TextStyle(fontSize: 12))),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  if (!app.isSystemApp)
                                    OutlinedButton(
                                      style: OutlinedButton.styleFrom(foregroundColor: kCrimson),
                                      onPressed: () => _purgeApp(app),
                                      child: const Text('Uninstall'),
                                    ),
                                  const Spacer(),
                                  const Text('Whitelist'),
                                  Switch(
                                    value: app.isWhitelisted,
                                    onChanged: (v) => _toggleWhitelist(app, v),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiquidProgress extends StatelessWidget {
  const _LiquidProgress({required this.progress, required this.step});

  final double progress;
  final String step;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kCardBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Scan Progress', style: TextStyle(fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('${(progress * 100).toStringAsFixed(0)}%'),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 18,
              child: Stack(
                children: [
                  Container(color: const Color(0xFF101010)),
                  FractionallySizedBox(
                    widthFactor: progress.clamp(0, 1),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [kEmerald, Color(0xFF00C96B)]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(step, style: const TextStyle(color: kTextSecondary)),
        ],
      ),
    );
  }
}
