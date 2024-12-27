import 'package:beatsguard/components/services/ble_service.dart';
import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  final BleService _bleService = BleService(); // Instance of your BleService

  // Sensor readings
  String? _bpm;
  String? _spo2;
  String? _temperature;
  String? _humidity;

  // Connection state
  bool _isConnecting = false;
  bool _isConnected = false;

  // Exposed getters
  String? get bpm => _bpm;
  String? get spo2 => _spo2;
  String? get temperature => _temperature;
  String? get humidity => _humidity;
  bool get isConnecting => _isConnecting;
  set isConnecting(bool value) {
    _isConnecting = value;
    notifyListeners();
  }
  bool get isConnected => _isConnected;

  AppProvider() {
    _initializeBle(); // Automatically start BLE connection
  }

  /// Private method to initialize BLE connection and subscribe to characteristics
  Future<void> _initializeBle() async {
    try {
      _isConnecting = true;
      notifyListeners();

      // Start scanning and connect to the first device
      final deviceStream = _bleService.scanForDevices();
      final discoveredDevices = await deviceStream.first;

      if (discoveredDevices.isNotEmpty) {
        final deviceId = discoveredDevices.first.id; // Pick the first device
        await _bleService.connectToDevice(deviceId);
        _isConnected = true;
        _isConnecting = false;

        notifyListeners();

        // Subscribe to characteristics
        _bleService.subscribeToCharacteristics();
        _listenToSensorData();
      } else {
        throw Exception("No devices found.");
      }
    } catch (e) {
      _isConnecting = false;
      _isConnected = false;
      notifyListeners();
      debugPrint('BLE initialization failed: $e');
    }
  }

  /// Listen to sensor data from BleService
  void _listenToSensorData() {
    _bleService.dataStream.listen((data) {
      _bpm = data['bpm'] ?? _bpm;
      _spo2 = data['spo2'] ?? _spo2;
      _temperature = data['temperature'] ?? _temperature;
      _humidity = data['humidity'] ?? _humidity;

      notifyListeners(); // Notify listeners of updated sensor data
    }, onError: (error) {
      debugPrint('Error reading sensor data: $error');
    });
  }

  /// Public method to reconnect to the BLE service and re-subscribe to characteristics
  Future<void> reconnect() async {
    debugPrint('Reconnecting to BLE service...');
    await _initializeBle();
  }
}
