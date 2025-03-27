import 'package:shared_preferences/shared_preferences.dart';

// Сервис для работы с локальным хранилищем
class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // Сохранение избранных треков
  Future<void> saveFavoriteTrack(String trackId) async {
    final favorites =
        await getFavoriteTracks(); // изменяем на асинхронный метод
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
    final favorites =
        await getFavoriteTracks(); // изменяем на асинхронный метод
    favorites.remove(trackId);
    await _prefs.setStringList('favorites', favorites.toList());
  }

  // Проверка, находится ли трек в избранном
  Future<bool> isTrackFavorite(String trackId) async {
    final favorites =
        await getFavoriteTracks(); // изменяем на асинхронный метод
    return favorites.contains(trackId);
  }
}
