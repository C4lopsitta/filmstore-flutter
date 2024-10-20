package cc.atomtech.filmstore.filmstore

import android.os.Bundle
import android.security.KeyChain
import android.security.KeyChainAliasCallback
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "cc.atomtech.filmstore.filmstore/keychain"
    private var methodResult: MethodChannel.Result? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Corrected typo: using `flutterEngine`
        if (flutterEngine != null) {
            MethodChannel(
                flutterEngine!!.dartExecutor.binaryMessenger,
                CHANNEL
            ).setMethodCallHandler { call, result ->
                if (call.method == "getCertificate") {
                    methodResult = result
                    requestUserCertificate()
                } else {
                    result.notImplemented()
                }
            }
        }
    }

    // Method to request user certificate from KeyChain
    private fun requestUserCertificate() {
        try {
            KeyChain.choosePrivateKeyAlias(this, { alias: String? ->
                if (alias != null) {
                    methodResult?.success(alias)
                } else {
                    methodResult?.error("NO_CERTIFICATE", "No certificate selected", null)
                }
            }, null, null, null, -1, null)
        } catch (e: Exception) {
            methodResult?.error("ERROR", "Failed to request certificate: ${e.localizedMessage}", null)
        }
    }
}
