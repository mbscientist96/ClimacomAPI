// lib/weather_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = '2a473d86b37b266da4d70ce5eafc1d02'; // Substitua pela sua chave da API.

  Future<Map<String, dynamic>> fetchWeather(String city) async {
    final response = await http.get(
      Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Falha ao carregar dados do clima');
    }
  }
}
