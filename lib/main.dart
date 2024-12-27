import 'package:beatsguard/components/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:beatsguard/components/services/auth_service.dart';
import 'package:beatsguard/pages/home_page.dart';
import 'package:beatsguard/pages/login_page.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(), // Initialize AppProvider
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// Initialize the application by requesting permissions and checking login state
  Future<bool> _initializeApp() async {
    try {
      // Request necessary permissions
      final permissionsGranted = await _requestPermissions();
      if (!permissionsGranted) {
        throw Exception("Required permissions not granted");
      }

      // Check if user is logged in
      final authService = AuthService();
      return await authService.isLoggedIn();
    } catch (e) {
      debugPrint('Initialization failed: $e');
      return false;
    }
  }

  /// Request necessary permissions, including notification and battery optimization
  Future<bool> _requestPermissions() async {
    // Request BLE, location, and notification permissions
    final status = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
      Permission.notification,
    ].request();

    // Request battery optimization exception if applicable (Android 12+)
    if (await Permission.ignoreBatteryOptimizations.isDenied) {
      await Permission.ignoreBatteryOptimizations.request();
    }

    // Return true if all permissions are granted
    return status.values.every((permission) => permission.isGranted);
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins'),
      home: FutureBuilder<bool>(
        future: _initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasError) {
            return const Scaffold(
              body: Center(
                child: Text(
                  'Error occurred while initializing the app.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
              ),
            );
          }

          final isLoggedIn = snapshot.data ?? false;

          return isLoggedIn ? const HomePage() : const LoginPage();
        },
      ),
    );
  }
}
