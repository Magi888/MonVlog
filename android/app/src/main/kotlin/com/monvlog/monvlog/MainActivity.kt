package com.monvlog.monvlog

import android.app.UiModeManager
import android.content.res.Configuration
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/// [FlutterFragmentActivity] is required by local_auth for biometric prompts.
/// Exposes leanback / Android TV detection for Dart [FormFactor].
class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.monvlog.monvlog/tv",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "isTelevision" -> {
                    val uiModeManager =
                        getSystemService(UI_MODE_SERVICE) as UiModeManager
                    val isTv =
                        uiModeManager.currentModeType ==
                            Configuration.UI_MODE_TYPE_TELEVISION
                    result.success(isTv)
                }
                else -> result.notImplemented()
            }
        }
    }
}
