import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/location.dart';

class FavoritesStorage {
  static const _key = 'favorite_locations';

  Future<List<Location>> load() async {
    final preferences = await SharedPreferences.getInstance();
    final records = preferences.getStringList(_key) ?? [];
    return records
        .map((record) =>
            Location.fromStoredJson(jsonDecode(record) as Map<String, dynamic>))
        .toList();
  }

  Future<void> save(List<Location> locations) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _key,
      locations.map((location) => jsonEncode(location.toJson())).toList(),
    );
  }
}
