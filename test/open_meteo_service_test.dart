import 'dart:convert';

import 'package:cuaca_kita/models/location.dart';
import 'package:cuaca_kita/services/open_meteo_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('searchLocations requests geocoding and parses location results',
      () async {
    final client = _MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.host, 'geocoding-api.open-meteo.com');
      expect(request.url.queryParameters['name'], 'Bandung');
      return http.Response(
        jsonEncode({
          'results': [
            {
              'id': 1650357,
              'name': 'Bandung',
              'latitude': -6.9175,
              'longitude': 107.6191,
              'admin1': 'West Java',
              'country': 'Indonesia',
            }
          ],
        }),
        200,
      );
    });
    final service = OpenMeteoService(client: client);

    final locations = await service.searchLocations('Bandung');

    expect(locations, hasLength(1));
    expect(locations.single.name, 'Bandung');
    expect(locations.single.latitude, -6.9175);
    service.close();
  });

  test('getWeather parses current conditions and five-day forecast', () async {
    final location = const Location(
      id: 'jakarta',
      name: 'Jakarta',
      latitude: -6.2,
      longitude: 106.8,
    );
    final client = _MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.host, 'api.open-meteo.com');
      expect(request.url.queryParameters['latitude'], '-6.2');
      expect(request.url.queryParameters['timezone'], 'auto');
      return http.Response(
        jsonEncode({
          'current': {
            'temperature_2m': 30.4,
            'relative_humidity_2m': 72,
            'apparent_temperature': 34.1,
            'precipitation': 0.2,
            'weather_code': 3,
            'wind_speed_10m': 10.5,
          },
          'daily': {
            'time': [
              '2026-11-25',
              '2026-11-26',
              '2026-11-27',
              '2026-11-28',
              '2026-11-29',
            ],
            'weather_code': [3, 61, 0, 2, 95],
            'temperature_2m_max': [31, 30, 32, 31, 29],
            'temperature_2m_min': [25, 24, 25, 24, 23],
            'precipitation_probability_max': [10, 70, 0, 20, 85],
          },
        }),
        200,
      );
    });
    final service = OpenMeteoService(client: client);

    final weather = await service.getWeather(location);

    expect(weather.temperature, 30.4);
    expect(weather.humidity, 72);
    expect(weather.forecast, hasLength(5));
    expect(weather.forecast[1].precipitationProbability, 70);
    service.close();
  });
}

class _MockClient extends http.BaseClient {
  _MockClient(this._handler);

  final Future<http.Response> Function(http.BaseRequest request) _handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await _handler(request);
    return http.StreamedResponse(
      Stream<List<int>>.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
      request: request,
    );
  }
}
