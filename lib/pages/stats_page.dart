import 'dart:convert';

import 'package:beatsguard/components/app_provider.dart';
import 'package:beatsguard/components/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:beatsguard/components/services/measurements_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  /// Retrieve the user ID from shared preferences
  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userInfo = prefs.getString('userInfo');
    if (userInfo != null) {
      final userMap = Map<String, dynamic>.from(jsonDecode(userInfo));
      return userMap['id'] as int?;
    }
    return null;
  }

  /// Save the current measurement using MeasurementService
  Future<void> _saveMeasurement(BuildContext context) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final measurementService = MeasurementService();

    try {
      // Retrieve user ID dynamically
      final userId = await _getUserId();
      if (userId == null) {
        throw Exception('User ID not found. Please log in again.');
      }

      // Prepare measurement data
      final now = DateTime.now();
      final measurement = {
        "avgBpm": int.tryParse(appProvider.bpm ?? '0'),
        "avgSpO2": int.tryParse(appProvider.spo2 ?? '0'),
        "avgTemp": int.tryParse(appProvider.temperature ?? '0'),
        "avgHumidity": int.tryParse(appProvider.humidity ?? '0'),
        "time": now.toIso8601String().split('.').first,
      };

      // Save the measurement
      await measurementService.createMeasurement(userId, measurement);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Measurement saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Stats',
      ),
      drawer: const CustomDrawer(),
      body: Center(
        child: appProvider.isConnecting
            ? const Text(
                'Connecting to device...',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              )
            : appProvider.isConnected
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                        _buildStatCard(
                          icon: Icons.favorite,
                          title: 'BPM',
                          value: appProvider.bpm ?? 'Loading...',
                          iconColor: Colors.red,
                          textColor: appProvider.bpm == '0' ? Colors.red : Colors.black,
                        ),
                        const SizedBox(height: 16),
                        _buildStatCard(
                          icon: Icons.opacity,
                          title: 'SpO2',
                          value: '${appProvider.spo2 ?? 'Loading...'}%',
                          iconColor: Colors.blue,
                        ),
                        const SizedBox(height: 16),
                        _buildStatCard(
                          icon: Icons.thermostat,
                          title: 'Temperature',
                          value: appProvider.temperature ?? 'Loading...',
                          iconColor: Colors.orange,
                        ),
                        const SizedBox(height: 16),
                        _buildStatCard(
                          icon: Icons.water_drop,
                          title: 'Humidity',
                          value: appProvider.humidity ?? 'Loading...',
                          iconColor: Colors.teal,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => _saveMeasurement(context),
                          style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          ),
                          icon: const Icon(Icons.save, size: 24),
                          label: const Text(
                          'Save Measurement',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  )
                : const Text(
                    'No device connected',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    Color iconColor = Colors.black,
    Color textColor = Colors.black,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              icon,
              size: 40,
              color: iconColor,
            ),
            const SizedBox(width: 16),
            Flexible( // Prevent row overflow
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis, // Handle long text gracefully
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
