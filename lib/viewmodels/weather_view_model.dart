import 'package:flutter/foundation.dart';

import '../models/location.dart';
import '../models/weather.dart';
import '../services/favorites_storage.dart';
import '../services/open_meteo_service.dart';

class WeatherViewModel extends ChangeNotifier {
  WeatherViewModel({
    OpenMeteoService? service,
    FavoritesStorage? favoritesStorage,
  })  : _service = service ?? OpenMeteoService(),
        _favoritesStorage = favoritesStorage ?? FavoritesStorage();

  final OpenMeteoService _service;
  final FavoritesStorage _favoritesStorage;

  Location selectedLocation = const Location(
    id: 'jakarta',
    name: 'Jakarta',
    latitude: -6.2088,
    longitude: 106.8456,
    region: 'Daerah Khusus Jakarta',
    country: 'Indonesia',
  );
  Weather? weather;
  List<Location> favorites = [];
  List<Location> searchResults = [];
  bool isLoadingWeather = false;
  bool isSearching = false;
  String? weatherError;
  String? searchError;
  int _weatherRequestId = 0;
  int _searchRequestId = 0;

  bool isFavorite(Location location) =>
      favorites.any((favorite) => favorite.id == location.id);

  Future<void> initialize() async {
    try {
      favorites = await _favoritesStorage.load();
    } catch (error) {
      debugPrint('Gagal memuat lokasi favorit: $error');
    }
    notifyListeners();
    await loadWeather(selectedLocation);
  }

  Future<void> loadWeather(Location location) async {
    final requestId = ++_weatherRequestId;
    selectedLocation = location;
    isLoadingWeather = true;
    weatherError = null;
    notifyListeners();

    try {
      final result = await _service.getWeather(location);
      if (requestId != _weatherRequestId) return;
      weather = result;
    } catch (error) {
      if (requestId != _weatherRequestId) return;
      weatherError = 'Tidak dapat memuat cuaca. Periksa koneksi internet Anda.';
      debugPrint('Gagal memuat cuaca: $error');
    } finally {
      if (requestId == _weatherRequestId) {
        isLoadingWeather = false;
        notifyListeners();
      }
    }
  }

  Future<void> searchLocations(String query) async {
    final requestId = ++_searchRequestId;
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      searchResults = [];
      searchError = null;
      isSearching = false;
      notifyListeners();
      return;
    }

    isSearching = true;
    searchError = null;
    notifyListeners();
    try {
      final results = await _service.searchLocations(trimmedQuery);
      if (requestId != _searchRequestId) return;
      searchResults = results;
    } catch (error) {
      if (requestId != _searchRequestId) return;
      searchResults = [];
      searchError = 'Pencarian gagal. Coba lagi saat koneksi tersedia.';
      debugPrint('Gagal mencari lokasi: $error');
    } finally {
      if (requestId == _searchRequestId) {
        isSearching = false;
        notifyListeners();
      }
    }
  }

  Future<void> toggleFavorite(Location location) async {
    if (isFavorite(location)) {
      favorites = favorites.where((item) => item.id != location.id).toList();
    } else {
      favorites = [...favorites, location];
    }
    notifyListeners();
    try {
      await _favoritesStorage.save(favorites);
    } catch (error) {
      debugPrint('Gagal menyimpan lokasi favorit: $error');
      rethrow;
    }
  }

  @override
  void dispose() {
    _service.close();
    super.dispose();
  }
}
