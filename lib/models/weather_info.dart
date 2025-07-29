// lib/models/weather_info.dart
class WeatherInfo {
  final String description;
  final double temperature;
  final String icon;
  final String location;

  WeatherInfo({
    required this.description,
    required this.temperature,
    required this.icon,
    required this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'temperature': temperature,
      'icon': icon,
      'location': location,
    };
  }

  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    return WeatherInfo(
      description: json['description'] ?? '',
      temperature: json['temperature']?.toDouble() ?? 0.0,
      icon: json['icon'] ?? '',
      location: json['location'] ?? '',
    );
  }

  String get temperatureString => '${temperature.round()}°C';
}
