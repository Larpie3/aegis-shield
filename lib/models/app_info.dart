enum RiskLevel { green, yellow, red }

class AppInfo {
  AppInfo({
    required this.packageName,
    required this.appName,
    this.appIcon,
    required this.risk,
    required this.reasons,
    this.installTime,
    required this.isSystemApp,
    this.isWhitelisted = false,
  });

  final String packageName;
  final String appName;
  final String? appIcon;
  final RiskLevel risk;
  final List<String> reasons;
  final DateTime? installTime;
  final bool isSystemApp;
  bool isWhitelisted;
}
