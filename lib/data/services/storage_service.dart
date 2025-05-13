import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/track_model.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // ==== ИЗБРАННОЕ ====

  Future<void> saveFavoriteTrack(String trackId) async {
    final favorites = await getFavoriteTracks();
    favorites.add(trackId);
    await _prefs.setStringList('favorites', favorites.toList());
  }

  Future<Set<String>> getFavoriteTracks() async {
    final favorites = _prefs.getStringList('favorites') ?? [];
    return favorites.toSet();
  }

  Future<void> removeFavoriteTrack(String trackId) async {
    final favorites = await getFavoriteTracks();
    favorites.remove(trackId);
    await _prefs.setStringList('favorites', favorites.toList());
  }

  Future<bool> isTrackFavorite(String trackId) async {
    final favorites = await getFavoriteTracks();
    return favorites.contains(trackId);
  }

  // ==== ЛОКАЛЬНЫЕ ФАЙЛЫ ====

  Future<String> getDownloadedTrackPath(String trackId) async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$trackId.mp3';
  }

  Future<bool> fileExists(String path) async {
    return File(path).exists();
  }

  // ==== СКАЧАННЫЕ ТРЕКИ ====

  Future<void> saveDownloadedTrack(TrackModel track) async {
    final downloaded = _prefs.getStringList('download_tracks') ?? [];

    final trackJson = json.encode({
      'id': track.id,
      'title': track.title,
      'artistName': track.artistName,
      'coverArt': track.coverArt,
      'audioUrl': track.audioUrl,
      'duration': track.duration,
      'isFavorite': track.isFavorite,
      'canDownload': track.canDownload,
    });

    // не дублируем
    if (!downloaded.contains(trackJson)) {
      downloaded.add(trackJson);
      await _prefs.setStringList('download_tracks', downloaded);
    }
  }

  Future<List<TrackModel>> getDownloadedTracks() async {
    final downloaded = _prefs.getStringList('download_tracks') ?? [];

    return downloaded.map((trackJson) {
      final jsonMap = json.decode(trackJson);
      return TrackModel.fromJson({
        'id': jsonMap['id'],
        'title': jsonMap['title'],
        'artist_name': jsonMap['artistName'],
        'coverArt': jsonMap['coverArt'],
        'audioUrl': jsonMap['audioUrl'],
        'duration': jsonMap['duration'],
        'isFavorite': jsonMap['isFavorite'],
        'canDownload': jsonMap['canDownload'],
      });
    }).toList();
  }
}
