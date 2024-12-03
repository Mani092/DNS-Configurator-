import 'package:dnsconfigure/themecontroller.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:async';



class DNSUpdateScreen extends StatefulWidget {
  @override
  _DNSUpdateScreenState createState() => _DNSUpdateScreenState();
}

class _DNSUpdateScreenState extends State<DNSUpdateScreen> {
  static const platform = MethodChannel('com.example.dnsconfigure/dns');
  MethodChannel _channel = MethodChannel('com.example.dnsconfigure/dns');

  final TextEditingController _dnsController = TextEditingController();
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  late Stream<List<ConnectivityResult>> _connectivityStream;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  final List<String> _updatedDNSList = []; // To store updated DNS IPs
  final List<String> _networkInterfaces = ['Wi-Fi', 'Mobile', 'Ethernet']; // Network options
  String _selectedNetwork = 'Wi-Fi';
  final String _defaultDNS = '8.8.8.8';// Default selected network

  @override
  void initState() {
    super.initState();
    _connectivityStream = _connectivity.onConnectivityChanged;
    _connectivitySubscription =
        _connectivityStream.listen((List<ConnectivityResult> results) {
          setState(() {
            _connectionStatus = _mapConnectivityResultsToStatus(results);
          });
        });
    _checkInitialConnectivity();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _checkInitialConnectivity() async {
    try {
      final List<ConnectivityResult> results =
      await _connectivity.checkConnectivity() as List<ConnectivityResult>;
      setState(() {
        _connectionStatus = _mapConnectivityResultsToStatus(results);
      });
    } catch (e) {
      setState(() {
        _connectionStatus = 'Failed to get connectivity: $e';
      });
    }
  }

  String _mapConnectivityResultsToStatus(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.wifi)) {
      return 'Wi-Fi Connected';
    } else if (results.contains(ConnectivityResult.mobile)) {
      return 'Mobile Data Connected';
    } else {
      return 'No Internet Connection';
    }
  }

  Future<void> _changeDNS(String dns) async {
    try {
      final result = await _channel.invokeMethod('changeDNS', {'dns': dns});
      print(result);  // Handle success
    } on PlatformException catch (e) {
      print("Error: ${e.message}");
    }
  }
  void _updateDNS() async {
    if (_connectionStatus == 'No Internet Connection') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No internet connection. Check your network.')),
      );
      return;
    }

    final enteredDNS = _dnsController.text;
    final isValidIP = RegExp(
      r'^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$|^([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}$',
    ).hasMatch(enteredDNS);

    if (!isValidIP) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid IP Address!')),
      );
      return;
    }

    try {
      final result = await platform.invokeMethod('changeDNS', {'dns': enteredDNS});
      setState(() {
        _updatedDNSList.add('$_selectedNetwork: $enteredDNS'); // Add network + DNS to the list
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('DNS updated to $enteredDNS for $_selectedNetwork')),
      );
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update DNS: ${e.message}')),
      );
    }

    _dnsController.clear(); // Clear the input field
  }

  void _resetDNS() async {
    try {
      final result = await platform.invokeMethod('resetDNS');
      setState(() {
        _updatedDNSList.clear(); // Clear the list of updated DNS
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('DNS reset to default ($_defaultDNS)')),
      );
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reset DNS: ${e.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dynamic DNS Updater'),
        actions: [
          // Theme toggle button
          Obx(() => IconButton(
            icon: Icon(Get.find<ThemeController>().themeMode.value == ThemeMode.dark
                ? Icons.nightlight_round
                : Icons.wb_sunny),
            onPressed: () {
              final themeController = Get.find<ThemeController>();
              themeController.toggleTheme(); // Toggle between light and dark
            },
          )),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Connection Status: $_connectionStatus'),
            SizedBox(height: 16),
            DropdownButton<String>(
              value: _selectedNetwork,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedNetwork = newValue!;
                });
              },
              items: _networkInterfaces
                  .map<DropdownMenuItem<String>>((String network) {
                return DropdownMenuItem<String>(
                  value: network,
                  child: Text(network),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _dnsController,
              decoration: InputDecoration(
                labelText: 'Enter DNS IP Address',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _updateDNS,
              child: Text('Update DNS'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _resetDNS, // Call the reset function
              child: Text('Reset DNS'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
            SizedBox(height: 16),
            Expanded(
              child: _updatedDNSList.isEmpty
                  ? Center(child: Text('No DNS IPs updated yet'))
                  : ListView.builder(
                itemCount: _updatedDNSList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_updatedDNSList[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
