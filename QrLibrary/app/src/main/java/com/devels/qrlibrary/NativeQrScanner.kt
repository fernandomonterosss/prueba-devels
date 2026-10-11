package com.devels.qrlibrary

import SenderManager
import android.Manifest
import android.app.Activity
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.google.mlkit.vision.codescanner.GmsBarcodeScanning

class NativeQrScanner( private val activity: Activity ) {

    interface ScannerCallback {
        fun onSuccess(qrCode: String)
        fun onError(errorCode: String, errorMessage: String)
    }

    private var currentCallback: ScannerCallback? = null
    private val CAMERA_REQUEST_CODE = 8801
    private val managerSender = SenderManager()

    fun startScan( callback: ScannerCallback ){
        this.currentCallback = callback

        if( ContextCompat.checkSelfPermission( activity, Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED){
            launchGoogleScanner()
        }else{
            ActivityCompat.requestPermissions(
                activity,
                arrayOf( Manifest.permission.CAMERA ),
                CAMERA_REQUEST_CODE
            )
        }
    }

    private fun launchGoogleScanner(){
        val scanner = GmsBarcodeScanning.getClient( activity )
        scanner.startScan()
            .addOnSuccessListener { barcode ->
                val readText = barcode.rawValue ?: ""
                val validateResult = managerSender.validateQRFormat( readText );

                if( validateResult == null ) {
                    currentCallback?.onError("BAD_FORMAT", "Formato inválido. El QR no sigue el patrón 'product:[id]' correcto.")
                }else{
                    currentCallback?.onSuccess(validateResult)
                }

            }
            .addOnFailureListener{ e ->
                if( e.message?.contains("canceled") == true ) {
                    currentCallback?.onError("SCANNER_CANCELED", "El usuario canceló el escaneo")
                }else{
                    currentCallback?.onError("UNKNOWN_ERROR", e.localizedMessage ?: "Error desconocido")
                }
            }
    }

    fun handlePermissionResult( requestCode: Int, grantResults: IntArray ): Boolean {
        if( requestCode == CAMERA_REQUEST_CODE ) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                launchGoogleScanner()
            } else {
                currentCallback?.onError("PERMISSION_DENIED", "Permiso de cámara denegado por el usuario")
            }
            return true
        }
        return false
    }

}