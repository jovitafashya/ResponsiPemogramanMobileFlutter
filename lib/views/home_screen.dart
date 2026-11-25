import 'package:flutter/material.dart';

import '../models/weather.dart';
import '../theme/app_theme.dart';
import '../viewmodels/weather_view_model.dart';
import 'search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.viewModel});

  final WeatherViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.wb_sunny_rounded, color: AppTheme.blue, size: 23),
            SizedBox(width: 9),
            Text(
              'cuaca kita',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Cari lokasi',
            icon: const Icon(Icons.search_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => SearchScreen(viewModel: viewModel),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedBuilder(
        animation: viewModel,
        builder: (context, _) => _WeatherContent(viewModel: viewModel),
      ),
    );
  }
}

class _WeatherContent extends StatelessWidget {
  const _WeatherContent({required this.viewModel});

  final WeatherViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
          children: [
            Row(
              children: [
                const Icon(Icons.location_on_rounded,
                    color: AppTheme.blue, size: 19),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    viewModel.selectedLocation.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (viewModel.isFavorite(viewModel.selectedLocation))
                  const Icon(Icons.favorite_rounded,
                      color: Color(0xFFE87979), size: 20),
              ],
            ),
            if (viewModel.selectedLocation.subtitle.isNotEmpty) ...[
              const SizedBox(height: 3),
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Text(
                  viewModel.selectedLocation.subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
            const SizedBox(height: 18),
            if (viewModel.isLoadingWeather && viewModel.weather == null)
              const _LoadingCard()
            else if (viewModel.weatherError != null &&
                viewModel.weather == null)
              _ErrorCard(
                message: viewModel.weatherError!,
                onRetry: () => viewModel.loadWeather(viewModel.selectedLocation),
              )
            else if (viewModel.weather == null)
              const _EmptyWeatherCard()
            else ...[
              _CurrentWeatherCard(weather: viewModel.weather!),
              const SizedBox(height: 22),
              _SectionHeading(
                title: 'Kondisi saat ini',
                subtitle: 'Diperbarui langsung dari Open-Meteo',
              ),
              const SizedBox(height: 12),
              _WeatherDetails(weather: viewModel.weather!),
              const SizedBox(height: 24),
              _SectionHeading(
                title: 'Prakiraan 5 hari',
                subtitle: 'Cuaca beberapa hari ke depan',
              ),
              const SizedBox(height: 12),
              _ForecastList(forecast: viewModel.weather!.forecast),
            ],
            if (viewModel.isLoadingWeather && viewModel.weather != null)
              const Padding(
                padding: EdgeInsets.only(top: 14),
                child: LinearProgressIndicator(minHeight: 2),
              ),
            if (viewModel.weatherError != null && viewModel.weather != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  viewModel.weatherError!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CurrentWeatherCard extends StatelessWidget {
  const _CurrentWeatherCard({required this.weather});

  final Weather weather;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF244966), Color(0xFF3977B8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.navy.withValues(alpha: 0.16),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'CUACA SEKARANG',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
              Text(
                weatherEmoji(weather.weatherCode),
                style: const TextStyle(fontSize: 42),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${weather.temperature.round()}°',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 72,
              height: 1,
              fontWeight: FontWeight.w300,
              letterSpacing: -4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            weatherDescription(weather.weatherCode),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Terasa seperti ${weather.apparentTemperature.round()}°',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _WeatherDetails extends StatelessWidget {
  const _WeatherDetails({required this.weather});

  final Weather weather;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 24) / 3;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _MetricCard(
              width: width,
              icon: Icons.water_drop_outlined,
              label: 'Kelembapan',
              value: '${weather.humidity}%',
            ),
            _MetricCard(
              width: width,
              icon: Icons.air_rounded,
              label: 'Kecepatan angin',
              value: '${weather.windSpeed.round()} km/j',
            ),
            _MetricCard(
              width: width,
              icon: Icons.umbrella_outlined,
              label: 'Curah hujan',
              value: '${weather.precipitation} mm',
            ),
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
  });

  final double width;
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.blue, size: 21),
          const SizedBox(height: 13),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: Theme.of(context).textTheme.titleMedium),
          ),
        ],
      ),
    );
  }
}

class _ForecastList extends StatelessWidget {
  const _ForecastList({required this.forecast});

  final List<DailyForecast> forecast;

  @override
  Widget build(BuildContext context) {
    if (forecast.isEmpty) return const _EmptyWeatherCard();
    return SizedBox(
      height: 155,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: forecast.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = forecast[index];
          final today = DateTime.now();
          final isToday = item.date.year == today.year &&
              item.date.month == today.month &&
              item.date.day == today.day;
          final day = isToday
              ? 'Hari ini'
              : const [
                  'Sen',
                  'Sel',
                  'Rab',
                  'Kam',
                  'Jum',
                  'Sab',
                  'Min',
                ][item.date.weekday - 1];
          return Container(
            width: 112,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(day, style: Theme.of(context).textTheme.bodySmall),
                Text(weatherEmoji(item.weatherCode),
                    style: const TextStyle(fontSize: 26)),
                Text(
                  '${item.high.round()}° / ${item.low.round()}°',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.water_drop, size: 12, color: AppTheme.blue),
                    const SizedBox(width: 3),
                    Text(
                      '${item.precipitationProbability}%',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 3),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 320,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _EmptyWeatherCard extends StatelessWidget {
  const _EmptyWeatherCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Text('Data cuaca belum tersedia untuk lokasi ini.'),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_outlined,
              color: AppTheme.muted, size: 38),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba lagi'),
          ),
        ],
      ),
    );
  }
}
