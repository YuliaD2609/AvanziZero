import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const apiKey = 'AIzaSyBjJwepLVHcvKm1F8W-_q8vCkSsQg0aAb4';
  final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey');
  
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final models = data['models'] as List;
    print("Modelli disponibili per questa chiave API:");
    for (var m in models) {
      if (m['name'].toString().contains('gemini')) {
        print(m['name'].toString());
      }
    }
  } else {
    print("Errore Status: ${response.statusCode}");
    print("Body: ${response.body}");
  }
}
