package com.example.qr_app_devels

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.devels.qrlibrary.NativeQrScanner

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.devels.qr/scanner_bridge"
    private var qrScanner: NativeQrScanner? = null
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        qrScanner = NativeQrScanner(this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "triggerNativeScan") {
                pendingResult = result
                
                qrScanner?.startScan(object : NativeQrScanner.ScannerCallback {
                    override fun onSuccess(qrCode: String) {
                        pendingResult?.success(qrCode)
                    }

                    override fun onError(errorCode: String, errorMessage: String) {
                        pendingResult?.error(errorCode, errorMessage, null)
                    }
                })
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        
        qrScanner?.handlePermissionResult(requestCode, grantResults)
    }
}