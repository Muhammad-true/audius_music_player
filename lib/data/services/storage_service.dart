import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Сервис для работы с локальным хранилищем
class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // Сохранение избранных треков
  Future<void> saveFavoriteTrack(String trackId) async {
    final favorites = await getFavoriteTracks();
    favorites.add(trackId);
    await _prefs.setStringList('favorites', favorites.toList());
  }

  // Получение списка избранных треков
  Future<Set<String>> getFavoriteTracks() async {
    final favorites = _prefs.getStringList('favorites') ?? [];
    return favorites.toSet();
  }

  // Удаление трека из избранного
  Future<void> removeFavoriteTrack(String trackId) async {
    final favorites = await getFavoriteTracks();
    favorites.remove(trackId);
    await _prefs.setStringList('favorites', favorites.toList());
  }

  // Проверка, находится ли трек в избранном
  Future<bool> isTrackFavorite(String trackId) async {
    final favorites = await getFavoriteTracks();
    return favorites.contains(trackId);
  }

  Future<String> getDownloadedTrackPath(String trackId) async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$trackId.mp3';
  }

  Future<bool> fileExists(String path) async {
    return File(path).exists();
  }
}
