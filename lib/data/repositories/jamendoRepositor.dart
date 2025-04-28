import 'package:dio/dio.dart';

import '../models/track_model.dart';

class JamendoRepository {
  final Dio _dio;
  String? _clientId;

  JamendoRepository() : _dio = Dio() {
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  // Инициализация с использованием API-ключа
  Future<void> initialize(String clientId) async {
    _clientId = clientId;
    try {
      final response = await _dio.get(
        'https://api.jamendo.com/v3.0/tracks/top',
        queryParameters: {'client_id': _clientId, 'limit': 1},
      );
      if (response.statusCode == 200) return response.data;
    } catch (e) {
      throw '';
    }
  }

  // Получение топовых треков неделя
  Future<List<TrackModel>> getTopTracks() async {
    if (_clientId == null) {
      throw Exception('Client ID is not initialized');
    }

    try {
      final response = await _dio.get(
        'https://api.jamendo.com/v3.0/tracks',
        queryParameters: {'client_id': _clientId, 'order': 'popularity_week'},
      );

      final List<dynamic> data = response.data['results'];

      return data.map((json) => TrackModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load top tracks: $e');
    }
  }

  // Получение топовых треков неделя
  Future<List<TrackModel>> getDownloadsTracksMonth() async {
    if (_clientId == null) {
      throw Exception('Client ID is not initialized');
    }

    try {
      final response = await _dio.get(
        'https://api.jamendo.com/v3.0/tracks',
        queryParameters: {'client_id': _clientId, 'order': 'downloads_month'},
      );

      final List<dynamic> data = response.data['results'];

      return data.map((json) => TrackModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load top tracks: $e');
    }
  }

  // Поиск треков по запросу
  Future<List<TrackModel>> searchTracks(String query) async {
    if (_clientId == null) {
      throw Exception('Client ID is not initialized');
    }

    try {
      final response = await _dio.get(
        'https://api.jamendo.com/v3.0/tracks',
        queryParameters: {
          'client_id': _clientId,
          'limit': 20,
          'search': query,
        },
      );

      final List<dynamic> data = response.data['results'];
      return data.map((json) => TrackModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search tracks: $e');
    }
  }

  // Получение подробной информации о треке
  Future<TrackModel> getTrackDetails(String trackId) async {
    if (_clientId == null) {
      throw Exception('Client ID is not initialized');
    }

    try {
      final response = await _dio.get(
        'https://api.jamendo.com/v3.0/tracks',
        queryParameters: {'client_id': _clientId, 'id': trackId},
      );

      if (response.statusCode == 200) {
        TrackModel.fromJson(response.data['results'][0]);
        final List<dynamic> data = response.data['results'];
        final List<TrackModel> data2 =
            data.map((json) => TrackModel.fromJson(json)).toList();
        return data2[0];
      } else {
        throw Exception('Failed to load track details');
      }
    } catch (e) {
      throw Exception('Failed to get track details: $e');
    }
  }

  // Получение stream URL (например, для воспроизведения)
  Future<String> getStreamUrl(String trackId) async {
    if (_clientId == null) {
      throw Exception('Client ID is not initialized');
    }

    try {
      final response = await _dio.get(
        'https://api.jamendo.com/v3.0/tracks/$trackId',
        queryParameters: {'client_id': _clientId},
      );

      if (response.statusCode == 200) {
        return response.data['tracks'][0]['preview'];
      } else {
        throw Exception('Failed to get stream URL');
      }
    } catch (e) {
      throw Exception('Failed to get stream URL: $e');
    }
  }
}
