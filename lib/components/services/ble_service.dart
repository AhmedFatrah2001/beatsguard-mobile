import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
class BleService {
  static final BleService _instance = BleService._internal();
  factory BleService() => _instance;
  BleService._internal();

  final FlutterReactiveBle _ble = FlutterReactiveBle();

  // UUIDs
  static const String serviceUuid = "44f18ec0-e237-46f9-b894-e26a478f4aff";
  static const String bpmCharacteristicUuid = "0ca4e53b-5389-4c3e-8b7d-362094c7cb5f";
  static const String spo2CharacteristicUuid = "3b82cf8f-90ff-467d-86e3-e892c48b765b";
  static const String tempCharacteristicUuid = "a1c4e82e-8f98-4ea2-908e-b403c59b44cc";
  static const String humidityCharacteristicUuid = "c451b3c6-69a6-4935-874f-bf01c5a7c711";
  static const String connectionTestUuid = "5bce7e16-dcfa-45a6-b57d-4b7b96126a4c";

  String? _connectedDeviceId;

  // Streams for characteristic data
  final _dataController = StreamController<Map<String, String>>.broadcast();
  Stream<Map<String, String>> get dataStream => _dataController.stream;

  // Add this method to your BleService class
Stream<List<DiscoveredDevice>> scanForDevices() {
  final discoveredDevices = <DiscoveredDevice>[];
  final controller = StreamController<List<DiscoveredDevice>>();

  _ble.scanForDevices(withServices: [Uuid.parse(serviceUuid)]).listen(
    (device) {
      if (!discoveredDevices.any((d) => d.id == device.id)) {
        discoveredDevices.add(device);
        controller.add(discoveredDevices);
      }
    },
    onError: (error) {
      print("Scan error: $error");
      controller.addError(error);
    },
    onDone: () => controller.close(),
  );

  return controller.stream;
}


  Future<void> connectToDevice(String deviceId) async {
    try {
      await _ble.connectToDevice(id: deviceId).first;
      _connectedDeviceId = deviceId;
      print("Connected to $deviceId");
    } catch (e) {
      print("Failed to connect: $e");
      _connectedDeviceId = null;
    }
  }

  Future<bool> testConnection() async {
    if (_connectedDeviceId == null) return false;

    try {
      final value = await _ble.readCharacteristic(QualifiedCharacteristic(
        deviceId: _connectedDeviceId!,
        serviceId: Uuid.parse(serviceUuid),
        characteristicId: Uuid.parse(connectionTestUuid),
      ));
      return value.isNotEmpty && value[0] == 49; // ASCII for '1'
    } catch (e) {
      print("Connection test failed: $e");
      return false;
    }
  }

  void subscribeToCharacteristics() {
    if (_connectedDeviceId == null) {
      print("No device connected to subscribe to.");
      return;
    }

    final deviceId = _connectedDeviceId!;
    final characteristicUuids = [
      bpmCharacteristicUuid,
      spo2CharacteristicUuid,
      tempCharacteristicUuid,
      humidityCharacteristicUuid,
    ];

    for (final uuid in characteristicUuids) {
      _ble.subscribeToCharacteristic(
        QualifiedCharacteristic(
          deviceId: deviceId,
          serviceId: Uuid.parse(serviceUuid),
          characteristicId: Uuid.parse(uuid),
        ),
      ).listen(
        (data) {
          final key = _uuidToKey(uuid);
          if (key != null) {
            _dataController.add({key: _convertHexToAscii(data)});
          }
        },
        onError: (error) => print("$uuid subscription error: $error"),
      );
    }
  }

  String? _uuidToKey(String uuid) {
    switch (uuid) {
      case bpmCharacteristicUuid:
        return "bpm";
      case spo2CharacteristicUuid:
        return "spo2";
      case tempCharacteristicUuid:
        return "temperature";
      case humidityCharacteristicUuid:
        return "humidity";
      default:
        return null;
    }
  }

  String _convertHexToAscii(List<int> data) {
    try {
      final asciiString = String.fromCharCodes(data);
      final value = double.tryParse(asciiString);
      if (value != null) {
      return value.toStringAsFixed(0); // Convert to integer string
      } else {
      return "Invalid Data";
      }
    } catch (e) {
      print("Error converting hex to ASCII: $e");
      return "Invalid Data";
    }
  }

  void disconnect() {
    _connectedDeviceId = null;
    print("Disconnected from device.");
  }

}
