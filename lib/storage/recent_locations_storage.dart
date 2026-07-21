import 'dart:convert';

import 'package:kipgo/models/shuttle_location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecentLocationsStorage {
  RecentLocationsStorage._();

  static final instance = RecentLocationsStorage._();

  static const _key = "recent_shuttle_locations";

  static const int maxItems = 5;

  Future<List<ShuttleLocation>> getRecentLocations() async {
    final prefs = await SharedPreferences.getInstance();

    final jsonList = prefs.getStringList(_key) ?? [];

    return jsonList.map((e) => ShuttleLocation.fromMap(jsonDecode(e))).toList();
  }

  Future<void> saveLocation(ShuttleLocation location) async {
    final prefs = await SharedPreferences.getInstance();

    var locations = await getRecentLocations();

    locations.removeWhere((e) => e.placeId == location.placeId);

    locations.insert(0, location);

    if (locations.length > maxItems) {
      locations = locations.take(maxItems).toList();
    }

    await prefs.setStringList(
      _key,
      locations.map((e) => jsonEncode(e.toMap())).toList(),
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_key);
  }
}
