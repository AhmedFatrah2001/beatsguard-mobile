import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MeasurementService {
  final String baseUrl = 'http://192.168.1.31:8080/api/measurements';

  /// Get the JWT token from shared preferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  /// Add authorization headers
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No JWT token found. Please log in.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Create a new measurement for a specific user
  Future<Map<String, dynamic>> createMeasurement(
      int userId, Map<String, dynamic> measurement) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/$userId'),
        headers: headers,
        body: jsonEncode(measurement),
      );
      print(jsonEncode(measurement));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(response.statusCode);
      }
    } catch (e) {
      throw Exception('Error occurred while creating measurement: $e');
    }
  }

  /// Get all measurements
  Future<List<dynamic>> getAllMeasurements() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception(
            'Failed to fetch measurements. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred while fetching measurements: $e');
    }
  }

  /// Get measurements by user ID
  Future<List<dynamic>> getMeasurementsByUserId(int userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/user/$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception(
            'Failed to fetch measurements by user ID. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(
          'Error occurred while fetching measurements by user ID: $e');
    }
  }

  /// Get a measurement by ID
  Future<Map<String, dynamic>> getMeasurementById(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to fetch measurement by ID. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred while fetching measurement by ID: $e');
    }
  }

  /// Delete a measurement by ID
  Future<void> deleteMeasurementById(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      if (response.statusCode != 204) {
        throw Exception(
            'Failed to delete measurement. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred while deleting measurement: $e');
    }
  }
}
