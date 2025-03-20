import 'package:dio/dio.dart';

import '../models/track_model.dart';

class AudiusRepository {
  final Dio _dio;
  String? _host;

  AudiusRepository() : _dio = Dio() {
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  Future<void> initialize() async {
    try {
      print('Initializing Audius API...');
      final response = await _dio.get(
        'https://api.audius.co',
        options: Options(
          headers: {'Accept': 'application/json'},
          responseType: ResponseType.json,
        ),
      );

      final List<String> hosts = List<String>.from(response.data['data']);
      _host = hosts.first;
      print('Selected host: $_host');
    } catch (e) {
      print('Error initializing Audius API: $e');
      throw Exception('Failed to initialize Audius API: $e');
    }
  }

  Future<String> getStreamUrl(String trackId) async {
    if (_host == null) await initialize();

    try {
      // Сразу формируем URL для стриминга
      return '$_host/v1/tracks/$trackId/stream?app_name=AUDIUS_MUSIC_PLAYER';
    } catch (e) {
      print('Error getting stream URL: $e');
      throw Exception('Failed to get stream URL: $e');
    }
  }

  Future<List<TrackModel>> getTrendingTracks() async {
    if (_host == null) await initialize();

    try {
      final response = await _dio.get(
        '$_host/v1/tracks/trending',
        queryParameters: {
          'app_name': 'AUDIUS_MUSIC_PLAYER',
          'limit': 20,
        },
      );

      final List<dynamic> data = response.data['data'];
      return data.map((json) => TrackModel.fromJson(json)).toList();
    } catch (e) {
      print('Error getting trending tracks: $e');
      throw Exception('Failed to load trending tracks: $e');
    }
  }

  /// Поиск треков
  Future<List<TrackModel>> searchTracks(String query) async {
    try {
      if (_host == null) {
        await initialize();
      }

      final response = await _dio.get(
        '$_host/v1/tracks/search',
        queryParameters: {'query': query},
      );

      if (response.statusCode != 200 || response.data['data'] == null) {
        throw Exception('Failed to search tracks.');
      }

      final List<dynamic> data = response.data['data'];
      return data.map((json) => TrackModel.fromJson(json)).toList();
    } catch (e) {
      print('Error searching tracks: $e');
      throw Exception('Failed to search tracks.');
    }
  }
}
