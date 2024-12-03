package com.dnsconfigure.dnsconfigure
import android.content.Context
import android.net.wifi.WifiConfiguration
import android.net.wifi.WifiInfo
import android.net.wifi.WifiManager
import android.os.Build
import android.util.Log
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.dnsconfigure.dnsconfigure/dns"

    // Create a method channel to communicate with Flutter
    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)

        MethodChannel(getFlutterEngine()!!.dartExecutor.binaryMessenger, "com.example.dnsconfigure/dns")
            .setMethodCallHandler { call, result ->
                if (call.method == "changeDNS") {
                    val dnsAddress = call.argument<String>("dns")
                    if (dnsAddress != null) {
                        changeDNS(dnsAddress)
                        result.success("DNS updated to $dnsAddress")
                    } else {
                        result.error("INVALID_ARGUMENT", "DNS address is missing", null)
                    }
                } else if (call.method == "resetDNS") {
                    resetDNS()
                    result.success("DNS reset to default")
                } else {
                    result.notImplemented()
                }
            }

    }

    // Function to change DNS settings on the Android device
    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    private fun changeDNS(dns: String) {
        try {
            val wifiManager = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
            val currentConfig = wifiManager.connectionInfo
            val wifiConfig = WifiConfiguration()

            // Assuming you're changing the currently connected network
            wifiConfig.SSID = "\"${currentConfig.ssid}\""

            // WifiConfiguration does not allow direct setting of DNS, so you will need
            // to manually modify network settings or use specific APIs to manipulate the DNS.
            // This will likely require root access to the device or other means to set DNS programmatically.

            // Log for debugging
            Log.d("MainActivity", "Attempting to change DNS to $dns for SSID ${currentConfig.ssid}")

            // Example: Simply printing the updated DNS (but actual update requires advanced networking privileges)
            Log.d("MainActivity", "DNS change to: $dns")
        } catch (e: Exception) {
            Log.e("MainActivity", "Error changing DNS: ${e.message}")
        }
    }

    // Reset DNS settings to default (Google's DNS)
    private fun resetDNS() {
        try {
            val wifiManager = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
            val currentConfig = wifiManager.connectionInfo
            val wifiConfig = WifiConfiguration()

            // Assuming you're resetting the DNS for the connected network
            wifiConfig.SSID = "\"${currentConfig.ssid}\""

            // Set default DNS to Google's public DNS
            val defaultDns1 = "8.8.8.8"
            val defaultDns2 = "8.8.4.4"

            // Log for debugging
            Log.d("MainActivity", "Resetting DNS to default: $defaultDns1, $defaultDns2")

            // The method to reset DNS will depend on the specific APIs and privileges you have
            // Actual DNS reset requires advanced permissions or root access.
        } catch (e: Exception) {
            Log.e("MainActivity", "Error resetting DNS: ${e.message}")
        }
    }
}
