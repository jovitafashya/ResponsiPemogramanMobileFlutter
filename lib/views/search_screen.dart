import 'dart:async';

import 'package:flutter/material.dart';

import '../models/location.dart';
import '../theme/app_theme.dart';
import '../viewmodels/weather_view_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.viewModel});

  final WeatherViewModel viewModel;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      widget.viewModel.searchLocations('');
      return;
    }
    _debounce = Timer(
      const Duration(milliseconds: 450),
      () => widget.viewModel.searchLocations(query),
    );
  }

  Future<void> _selectLocation(Location location) async {
    await widget.viewModel.loadWeather(location);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _toggleFavorite(Location location) async {
    try {
      await widget.viewModel.toggleFavorite(location);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lokasi favorit gagal disimpan.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cari lokasi')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: TextField(
                  controller: _controller,
                  onChanged: _onQueryChanged,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Ketik nama kota...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: IconButton(
                      tooltip: 'Hapus pencarian',
                      onPressed: () {
                        _controller.clear();
                        _onQueryChanged('');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: AnimatedBuilder(
                  animation: widget.viewModel,
                  builder: (context, _) => _buildResults(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResults() {
    final viewModel = widget.viewModel;
    final hasQuery = _controller.text.trim().isNotEmpty;
    if (!hasQuery) {
      if (viewModel.favorites.isEmpty) {
        return const _Hint(
          icon: Icons.travel_explore_rounded,
          title: 'Cari kota untuk cek cuaca',
          subtitle: 'Ketik nama kota di kolom atas untuk mulai mencari.',
        );
      }
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Text(
            'Lokasi favorit',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...viewModel.favorites.map(
            (location) => _LocationTile(
              location: location,
              isFavorite: true,
              onTap: () => _selectLocation(location),
              onFavoriteTap: () => _toggleFavorite(location),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Pilih kota untuk melihat cuaca terkini.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      );
    }

    if (viewModel.isSearching && viewModel.searchResults.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.searchError != null) {
      return _Hint(
        icon: Icons.wifi_off_rounded,
        title: 'Pencarian belum berhasil',
        subtitle: viewModel.searchError!,
      );
    }
    if (viewModel.searchResults.isEmpty) {
      return const _Hint(
        icon: Icons.location_searching_rounded,
        title: 'Kota tidak ditemukan',
        subtitle: 'Coba periksa ejaan atau cari dengan nama lain.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        Text(
          'Hasil pencarian',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ...viewModel.searchResults.map(
          (location) => _LocationTile(
            location: location,
            isFavorite: viewModel.isFavorite(location),
            onTap: () => _selectLocation(location),
            onFavoriteTap: () => _toggleFavorite(location),
          ),
        ),
      ],
    );
  }
}

class _LocationTile extends StatelessWidget {
  const _LocationTile({
    required this.location,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteTap,
  });

  final Location location;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppTheme.paleBlue,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.location_on_outlined, color: AppTheme.blue),
        ),
        title: Text(
          location.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          location.subtitle.isEmpty ? 'Lokasi ditemukan' : location.subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          tooltip: isFavorite ? 'Hapus dari favorit' : 'Simpan ke favorit',
          onPressed: onFavoriteTap,
          icon: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: isFavorite ? const Color(0xFFE87979) : AppTheme.muted,
          ),
        ),
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: AppTheme.blue),
            const SizedBox(height: 14),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
