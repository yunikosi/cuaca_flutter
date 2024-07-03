import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = '428e84f8c7f9027dc1c72ddbf4d68185';

  Future<Map<String, dynamic>> fetchWeather(String location) async {
    final response = await http.get(
      Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$location&appid=$apiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<List<dynamic>> fetchHourlyForecast(String location) async {
    final response = await http.get(
      Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$location&appid=$apiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['list'];
    } else {
      throw Exception('Failed to load hourly forecast data');
    }
  }
}
