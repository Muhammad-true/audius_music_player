import 'package:audius_music_player/data/models/track_model.dart';
import 'package:audius_music_player/data/repositories/audius_repositor.dart';
import 'package:dio/dio.dart';

class DummyAudiusRepository implements AudiusRepository {
  final Dio dio;

  DummyAudiusRepository({Dio? dio})
      : dio = dio ?? Dio(); // Используем базовый Dio по умолчанию

  @override
  Future<List<TrackModel>> searchTracks(String query) async {
    return []; // Возвращаем пустой список для имитации
  }

  Future<List<TrackModel>> getTopTracks() async {
    return []; // Вернёт пустой список
  }

  Future<String> getStreamUrl(String trackId) async {
    throw 'Невозможно получить поток без подключения к интернету.';
  }

  Future<TrackModel> getTrackDetails(String trackId) async {
    throw Exception('Невозможно получить детали трека в офлайн-режиме.');
  }

  Future<TrackModel> downloadFullTrack({
    required TrackModel track,
    required void Function(double progress) onProgress,
  }) async {
    throw Exception('Загрузка недоступна в офлайн-режиме.');
  }

  Future<void> downloadPlaylist({
    required List<TrackModel> tracks,
    required void Function(String trackId, double progress) onProgress,
  }) async {
    throw Exception('Загрузка плейлиста недоступна в офлайн-режиме.');
  }

  @override
  Future<List<TrackModel>> getUndergroundTrendingTracks() {
    throw 'Загрузка плейлиста недоступна в офлайн-режиме.';
  }
}
