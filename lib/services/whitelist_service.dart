import 'package:shared_preferences/shared_preferences.dart';

class WhitelistService {
  static const _key = 'whitelist_packages';

  Future<Set<String>> loadWhitelist() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key) ?? <String>[]).toSet();
  }

  Future<void> setWhitelisted(String packageName, bool whitelisted) async {
    final prefs = await SharedPreferences.getInstance();
    final items = (prefs.getStringList(_key) ?? <String>[]).toSet();
    if (whitelisted) {
      items.add(packageName);
    } else {
      items.remove(packageName);
    }
    await prefs.setStringList(_key, items.toList());
  }
}
