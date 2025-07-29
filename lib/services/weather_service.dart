// lib/services/weather_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/weather_info.dart';

class WeatherService {
  static const String _apiKey = 'YOUR_OPENWEATHER_API_KEY'; // 실제 API 키로 교체 필요
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  Future<WeatherInfo?> getCurrentWeather() async {
    try {
      // 위치 권한 확인
      final permission = await _checkLocationPermission();
      if (!permission) {
        return null;
      }

      // 현재 위치 가져오기
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      // 날씨 데이터 가져오기
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$_apiKey&units=metric&lang=kr',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseWeatherData(data);
      }
    } catch (e) {
      print('날씨 데이터 가져오기 실패: $e');
    }

    return null;
  }

  Future<WeatherInfo?> getWeatherByCity(String cityName) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/weather?q=$cityName&appid=$_apiKey&units=metric&lang=kr',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseWeatherData(data);
      }
    } catch (e) {
      print('날씨 데이터 가져오기 실패: $e');
    }

    return null;
  }

  WeatherInfo _parseWeatherData(Map<String, dynamic> data) {
    return WeatherInfo(
      description: data['weather'][0]['description'] ?? '정보 없음',
      temperature: (data['main']['temp'] ?? 0).toDouble(),
      icon: data['weather'][0]['icon'] ?? '',
      location: data['name'] ?? '알 수 없는 위치',
    );
  }

  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 위치 서비스가 활성화되어 있는지 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // 더미 날씨 데이터 (API 키가 없을 때 사용)
  WeatherInfo getDummyWeather() {
    final weathers = [
      WeatherInfo(
        description: '맑음',
        temperature: 22.0,
        icon: '01d',
        location: '울산',
      ),
      WeatherInfo(
        description: '흐림',
        temperature: 18.0,
        icon: '04d',
        location: '울산',
      ),
      WeatherInfo(
        description: '비',
        temperature: 15.0,
        icon: '10d',
        location: '울산',
      ),
    ];

    return weathers[DateTime.now().day % weathers.length];
  }
}
