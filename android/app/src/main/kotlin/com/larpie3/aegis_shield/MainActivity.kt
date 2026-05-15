package com.larpie3.aegis_shield

import android.app.AppOpsManager
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject
import java.util.Calendar

class MainActivity : FlutterActivity() {
    private val channel = "com.larpie3.aegis_shield/scanner"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            when (call.method) {
                "scanApps" -> {
                    runCatching { scanInstalledApps() }
                        .onSuccess { result.success(it) }
                        .onFailure { result.error("SCAN_ERROR", it.message, null) }
                }

                "hasUsageStatsPermission" -> result.success(hasUsageStatsPermission())
                else -> result.notImplemented()
            }
        }
    }

    private fun hasUsageStatsPermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            android.os.Process.myUid(),
            packageName
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun scanInstalledApps(): String {
        val pm = packageManager
        val output = JSONArray()
        val usageMap = getUsageStats()

        val packages = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            pm.getInstalledPackages(PackageManager.PackageInfoFlags.of(PackageManager.GET_PERMISSIONS.toLong()))
        } else {
            @Suppress("DEPRECATION")
            pm.getInstalledPackages(PackageManager.GET_PERMISSIONS)
        }

        packages.forEach { pkgInfo ->
            if (pkgInfo.packageName == packageName) return@forEach

            val app = JSONObject()
            app.put("packageName", pkgInfo.packageName)
            app.put("appName", runCatching { pm.getApplicationLabel(pkgInfo.applicationInfo).toString() }.getOrDefault(pkgInfo.packageName))

            val isSystem = (pkgInfo.applicationInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0
            app.put("isSystemApp", isSystem)
            app.put("installTime", pkgInfo.firstInstallTime)

            val requested = pkgInfo.requestedPermissions ?: emptyArray()
            val hasSystemAlertWindow = requested.contains("android.permission.SYSTEM_ALERT_WINDOW")
            val hasBootReceiver = requested.contains("android.permission.RECEIVE_BOOT_COMPLETED")

            val usage = usageMap[pkgInfo.packageName]
            val totalForeground = usage?.totalTimeInForeground ?: 0L
            val installedRecently = (System.currentTimeMillis() - pkgInfo.firstInstallTime) < 72L * 60 * 60 * 1000

            val reasons = JSONArray()
            val risk = when {
                !isSystem && hasSystemAlertWindow && totalForeground < 60_000L -> {
                    reasons.put("Has SYSTEM_ALERT_WINDOW permission")
                    reasons.put("High background activity detected")
                    "red"
                }

                !isSystem && installedRecently && hasBootReceiver -> {
                    reasons.put("Installed within last 72 hours")
                    reasons.put("Has Start-on-Boot permission")
                    "yellow"
                }

                else -> {
                    if (isSystem) reasons.put("System application") else reasons.put("Low-risk profile")
                    "green"
                }
            }

            app.put("risk", risk)
            app.put("reasons", reasons)
            output.put(app)
        }

        return output.toString()
    }

    private fun getUsageStats(): Map<String, UsageStats> {
        if (!hasUsageStatsPermission()) return emptyMap()
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val cal = Calendar.getInstance().apply { add(Calendar.DAY_OF_YEAR, -7) }
        val stats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            cal.timeInMillis,
            System.currentTimeMillis()
        )
        return stats.associateBy { it.packageName }
    }
}
