import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';


class WeatherServices {
  final String apiKey = dotenv.env['API_KEY'] ?? 'no-api-key-found';
  final String forecastBaseUrl = 'http://api.weatherapi.com/v1/forecast.json';
  final String currentBaseUrl = 'http://api.weatherapi.com/v1/current.json';
  final String searchBaseUrl = 'http://api.weatherapi.com/v1/search.json';

  Future<Map<String, dynamic>> fetchCurrentWeather(String city) async {
    final url = '$currentBaseUrl?key=$apiKey&q=$city&aqi=no';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load current weather data: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetch7Weather(String city) async {
    final url = '$forecastBaseUrl?key=$apiKey&q=$city&days=7&aqi=no&alerts=no';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load forecast data: ${response.statusCode}');
    }
  }

  Future<List<dynamic>?> fetchCitySuggestion(String query) async {
    final url = '$searchBaseUrl?key=$apiKey&q=$query';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }
}
