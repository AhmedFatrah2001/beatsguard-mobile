import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  final String _baseUrl = "http://192.168.1.13:5000";

  Future<Map<String, dynamic>> getChatbotResponse(String question) async {
    try {
      final url = Uri.parse("$_baseUrl/get_answer");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"question": question}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception("Failed to get response: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error connecting to server: $e");
    }
  }
}
