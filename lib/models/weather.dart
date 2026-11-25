class Weather {
  const Weather({
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
    required this.forecast,
  });

  final double temperature;
  final double apparentTemperature;
  final int humidity;
  final double precipitation;
  final int weatherCode;
  final double windSpeed;
  final List<DailyForecast> forecast;

  factory Weather.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    final daily = json['daily'] as Map<String, dynamic>;
    final dates = daily['time'] as List<dynamic>;
    final codes = daily['weather_code'] as List<dynamic>;
    final highs = daily['temperature_2m_max'] as List<dynamic>;
    final lows = daily['temperature_2m_min'] as List<dynamic>;
    final rainChances =
        daily['precipitation_probability_max'] as List<dynamic>;

    return Weather(
      temperature: (current['temperature_2m'] as num).toDouble(),
      apparentTemperature:
          (current['apparent_temperature'] as num).toDouble(),
      humidity: (current['relative_humidity_2m'] as num).round(),
      precipitation: (current['precipitation'] as num).toDouble(),
      weatherCode: (current['weather_code'] as num).toInt(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      forecast: List<DailyForecast>.generate(
        dates.length,
        (index) => DailyForecast(
          date: DateTime.parse(dates[index] as String),
          weatherCode: (codes[index] as num).toInt(),
          high: (highs[index] as num).toDouble(),
          low: (lows[index] as num).toDouble(),
          precipitationProbability: (rainChances[index] as num).toInt(),
        ),
      ),
    );
  }
}

class DailyForecast {
  const DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.high,
    required this.low,
    required this.precipitationProbability,
  });

  final DateTime date;
  final int weatherCode;
  final double high;
  final double low;
  final int precipitationProbability;
}

String weatherDescription(int code) {
  if (code == 0) return 'Cerah';
  if (code <= 3) return 'Berawan';
  if (code <= 48) return 'Berkabut';
  if (code <= 57) return 'Gerimis';
  if (code <= 67 || (code >= 80 && code <= 82)) return 'Hujan';
  if (code <= 77) return 'Salju';
  if (code >= 95) return 'Badai petir';
  return 'Kondisi cuaca';
}

String weatherEmoji(int code) {
  if (code == 0) return '☀️';
  if (code <= 3) return '⛅';
  if (code <= 48) return '🌫️';
  if (code <= 57) return '🌦️';
  if (code <= 67 || (code >= 80 && code <= 82)) return '🌧️';
  if (code <= 77) return '🌨️';
  if (code >= 95) return '⛈️';
  return '🌤️';
}
