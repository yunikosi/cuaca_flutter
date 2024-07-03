import 'package:flutter/material.dart';
import '../services/weather_service.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService = WeatherService();

  Map<String, dynamic>? _weatherData;
  List<dynamic>? _hourlyForecast;
  Map<String, dynamic>? get weatherData => _weatherData;
  List<dynamic>? get hourlyForecast => _hourlyForecast;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  get dailyForecast => null;

  Future<void> fetchWeather(String location) async {
    _isLoading = true;

    try {
      _weatherData = await _weatherService.fetchWeather(location);
      _hourlyForecast = await _weatherService.fetchHourlyForecast(location);
    } catch (e) {
      _weatherData = null;
      _hourlyForecast = null;
    }

    _isLoading = false;
    notifyListeners();
  }
}
