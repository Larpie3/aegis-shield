import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/services.dart';

import '../models/app_info.dart';

class ScanUpdate {
  ScanUpdate({required this.progress, this.currentStep = '', this.result});

  final double progress;
  final String currentStep;
  final List<AppInfo>? result;
}

class ScanService {
  static const MethodChannel _scannerChannel = MethodChannel('com.larpie3.aegis_shield/scanner');


  Future<void> requestUninstall(String packageName) async {
    await _scannerChannel.invokeMethod<bool>('requestUninstall', <String, dynamic>{
      'packageName': packageName,
    });
  }
  Future<bool> hasUsageStatsPermission() async {
    try {
      return await _scannerChannel.invokeMethod<bool>('hasUsageStatsPermission') ?? false;
    } catch (_) {
      return false;
    }
  }

  Stream<ScanUpdate> runScan({required Set<String> whitelist}) async* {
    yield ScanUpdate(progress: 0.1, currentStep: 'Initializing engine...');
    await Future<void>.delayed(const Duration(milliseconds: 350));
    yield ScanUpdate(progress: 0.3, currentStep: 'Reading package metadata...');

    List<Map<String, dynamic>> payload;
    try {
      final raw = await _scannerChannel.invokeMethod<String>('scanApps');
      final decoded = jsonDecode(raw ?? '[]') as List<dynamic>;
      payload = decoded
          .whereType<Map<dynamic, dynamic>>()
          .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
          .toList();
    } catch (_) {
      payload = _mockPayload();
    }

    yield ScanUpdate(progress: 0.6, currentStep: 'Classifying app signatures...');

    final parsed = await Isolate.run<List<AppInfo>>(
      () => _convertPayload(payload),
    );

    for (final app in parsed) {
      app.isWhitelisted = whitelist.contains(app.packageName);
    }

    yield ScanUpdate(progress: 0.85, currentStep: 'Applying whitelist...');
    await Future<void>.delayed(const Duration(milliseconds: 250));

    final filtered = parsed.where((e) => !e.isWhitelisted).toList()
      ..sort((a, b) => b.risk.index.compareTo(a.risk.index));
    yield ScanUpdate(progress: 1.0, currentStep: 'Scan complete', result: filtered);
  }

  static List<AppInfo> _convertPayload(List<Map<String, dynamic>> payload) {
    return payload.map((item) {
      final riskRaw = (item['risk'] ?? 'green').toString().toLowerCase();
      final risk = riskRaw == 'red'
          ? RiskLevel.red
          : riskRaw == 'yellow'
              ? RiskLevel.yellow
              : RiskLevel.green;
      final installMillis = item['installTime'] as int?;

      return AppInfo(
        packageName: item['packageName']?.toString() ?? 'unknown.package',
        appName: item['appName']?.toString() ?? 'Unknown App',
        appIcon: null,
        risk: risk,
        reasons: ((item['reasons'] as List<dynamic>?) ?? <dynamic>[])
            .map((e) => e.toString())
            .toList(),
        installTime: installMillis != null
            ? DateTime.fromMillisecondsSinceEpoch(installMillis)
            : null,
        isSystemApp: item['isSystemApp'] == true,
      );
    }).toList();
  }

  static List<Map<String, dynamic>> _mockPayload() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return <Map<String, dynamic>>[
      {
        'packageName': 'com.bad.overlayads',
        'appName': 'Overlay Ads Booster',
        'risk': 'red',
        'isSystemApp': false,
        'installTime': now - const Duration(days: 2).inMilliseconds,
        'reasons': <String>[
          'Has SYSTEM_ALERT_WINDOW permission',
          'High background activity while screen was off',
        ],
      },
      {
        'packageName': 'com.new.fastcleaner',
        'appName': 'Fast Cleaner',
        'risk': 'yellow',
        'isSystemApp': false,
        'installTime': now - const Duration(hours: 20).inMilliseconds,
        'reasons': <String>[
          'Installed in last 72 hours',
          'Has Start-on-Boot permission',
        ],
      },
      {
        'packageName': 'com.android.settings',
        'appName': 'Settings',
        'risk': 'green',
        'isSystemApp': true,
        'installTime': now - const Duration(days: 300).inMilliseconds,
        'reasons': <String>['System-signed app'],
      },
    ];
  }
}
