import 'package:beatsguard/components/app_provider.dart';
import 'package:beatsguard/components/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:beatsguard/components/services/ble_service.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({super.key});

  @override
  _DevicePageState createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  final BleService _bleService = BleService();

  /// Test device connection
  void _testConnection() async {
    final isConnected = await _bleService.testConnection();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Connection Test",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          isConnected ? "Device is functional!" : "Connection test failed.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  /// Try reconnecting by reinitializing AppProvider
  void _tryReconnect(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    appProvider.reconnect();
    appProvider.isConnecting = false; // Call the initialize method in AppProvider
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reconnection attempt started')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider?>(context);

    return appProvider == null
        ? const Scaffold(
            appBar: CustomAppBar(
              title: "Device Setup",
            ),
            drawer: CustomDrawer(),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            appBar: const CustomAppBar(title: "Device Setup"),
            drawer: const CustomDrawer(),
            body: Center(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.watch, // Big icon representing the device
                        size: 100,
                        color: Colors.teal,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "BeatsGuardDevice",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _testConnection,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: const Text(
                              "Test",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () => _tryReconnect(context),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: const Text(
                              "Reconnect",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
