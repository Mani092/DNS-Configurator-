import Cocoa
import FlutterMacOS

public class DNSPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.dnsconfigure.dnsconfigure/dns", binaryMessenger: registrar.messenger)
        let instance = DNSPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "changeDNS":
            if let args = call.arguments as? [String: Any], let dns = args["dns"] as? String {
                changeDNS(dns: dns)
                result("DNS updated to \(dns)")
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "DNS address is missing", details: nil))
            }
        case "resetDNS":
            resetDNS()
            result("DNS reset to default")
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func changeDNS(dns: String) {
        // macOS logic for changing DNS (requires system-level permissions)
    }

    private func resetDNS() {
        // macOS logic for resetting DNS to default
    }
}
