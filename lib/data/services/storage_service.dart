import 'package:shared_preferences/shared_preferences.dart';

// Сервис для работы с локальным хранилищем
class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // Сохранение избранных треков
  Future<void> saveFavoriteTrack(String trackId) async {
    final favorites = getFavoriteTracks();
    favorites.add(trackId);
    await _prefs.setStringList('favorites', favorites.toList());
  }

  // Получение списка избранных треков
  Set<String> getFavoriteTracks() {
    return _prefs.getStringList('favorites')?.toSet() ?? {};
  }

  // Удаление трека из избранного
  Future<void> removeFavoriteTrack(String trackId) async {
    final favorites = getFavoriteTracks();
    favorites.remove(trackId);
    await _prefs.setStringList('favorites', favorites.toList());
  }

  // Проверка, находится ли трек в избранном
  bool isTrackFavorite(String trackId) {
    return getFavoriteTracks().contains(trackId);
  }
}
