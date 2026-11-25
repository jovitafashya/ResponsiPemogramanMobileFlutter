import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/location.dart';
import '../models/weather.dart';

class OpenMeteoService {
  OpenMeteoService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<Location>> searchLocations(String query) async {
    final uri = Uri.https(
      'geocoding-api.open-meteo.com',
      '/v1/search',
      {'name': query, 'count': '10', 'language': 'id', 'format': 'json'},
    );
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Pencarian lokasi gagal (${response.statusCode}).');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final results = body['results'] as List<dynamic>? ?? [];
    return results
        .map((item) => Location.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Weather> getWeather(Location location) async {
    final uri = Uri.https(
      'api.open-meteo.com',
      '/v1/forecast',
      {
        'latitude': location.latitude.toString(),
        'longitude': location.longitude.toString(),
        'current':
            'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m',
        'daily':
            'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max',
        'timezone': 'auto',
        'forecast_days': '5',
      },
    );
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Data cuaca gagal dimuat (${response.statusCode}).');
    }

    return Weather.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  void close() => _client.close();
}
