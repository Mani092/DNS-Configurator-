#include <windows.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

void ChangeDNS(const std::string& dns) {
    // Logic for changing DNS on Windows
    // Typically, this would use Windows APIs or system commands to update DNS settings.
    // This may require administrator privileges.
}

void ResetDNS() {
    // Logic for resetting DNS to default
}

class DNSPlugin : public flutter::Plugin {
public:
    static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar) {
        auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
                registrar->messenger(), "com.dnsconfigure.dnsconfigure/dns",
                        &flutter::StandardMethodCodec::GetInstance());

        auto plugin = std::make_unique<DNSPlugin>();

        channel->SetMethodCallHandler([plugin_pointer = plugin.get()](const auto& call, auto result) {
            if (call.method_name().compare("changeDNS") == 0) {
                const auto* dns = std::get_if<std::string>(call.arguments());
                if (dns) {
                    ChangeDNS(*dns);
                    result->Success("DNS updated to " + *dns);
                } else {
                    result->Error("INVALID_ARGUMENT", "DNS address is missing");
                }
            } else if (call.method_name().compare("resetDNS") == 0) {
                ResetDNS();
                result->Success("DNS reset to default");
            } else {
                result->NotImplemented();
            }
        });

        registrar->AddPlugin(std::move(plugin));
    }
};
