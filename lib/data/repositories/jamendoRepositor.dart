import 'package:dio/dio.dart';

import '../models/track_model.dart';

class JamendoRepository {
  final Dio _dio;

  // Приватный конструктор
  JamendoRepository._(this._dio);

  /// Асинхронная фабрика для создания репозитория с рабочим discovery-узлом
  static Future<JamendoRepository> create() async {
    final discoveryUrl = await _getDiscoveryNode();

    final dio = Dio(BaseOptions(
      baseUrl: '$discoveryUrl/v1',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    return JamendoRepository._(dio);
  }

  /// Получение актуального discovery-узла от Audius
  static Future<String> _getDiscoveryNode() async {
    try {
      final response = await Dio().get('https://api.audius.co');
      final data = response.data['data'];

      if (data != null && data is List && data.isNotEmpty) {
        return data.first.toString();
      } else {
        throw Exception('Не удалось получить discovery-узел Audius');
      }
    } catch (e) {
      throw Exception('Ошибка при подключении к api.audius.co: $e');
    }
  }

  /// Поиск треков по запросу
  Future<List<TrackModel>> searchTracks(String query) async {
    try {
      final response = await _dio.get(
        '/tracks/search',
        queryParameters: {'query': query, 'limit': 20},
      );

      final data = response.data['data'] as List;

      return data.map((trackJson) {
        return TrackModel.fromJson({
          'id': trackJson['id'],
          'name': trackJson['title'],
          'artist_name': trackJson['user']['name'],
          'album_image': trackJson['artwork']?['1000x1000'] ?? '',
          'audio': '', // Поток получаем отдельно
          'duration': trackJson['duration'] ?? 0,
        });
      }).toList();
    } on DioException catch (e) {
      throw Exception('Ошибка при поиске треков: ${e.message}');
    }
  }

  Future<List<TrackModel>> getTopTracks() async {
    try {
      final response = await _dio.get(
        '/tracks/trending',
        queryParameters: {'limit': 20},
      );

      final data = response.data['data'] as List;

      return data.map((trackJson) {
        return TrackModel.fromJson({
          'id': trackJson['id'],
          'name': trackJson['title'],
          'artist_name': trackJson['user']['name'],
          'album_image': trackJson['artwork']?['1000x1000'] ?? '',
          'audio':
              'https://discoveryprovider.audius.co/v1/${trackJson['track_cid']}?stream/app_name=audius_music_player',
          'duration': trackJson['duration'] ?? 0,
        });
      }).toList();
    } on DioException catch (e) {
      throw Exception('Ошибка при получении топовых треков: ${e.message}');
    }
  }

  /// Получение прямого URL на стрим трека
  Future<String> getStreamUrl(String trackId) async {
    try {
      final response = await _dio.get(
        '/tracks/$trackId/stream',
        options: Options(
          followRedirects: false,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 302) {
        final streamUrl = response.headers['location']?.first;
        if (streamUrl != null) {
          return streamUrl;
        } else {
          throw Exception('Stream URL не найден');
        }
      } else {
        throw Exception('Неверный ответ сервера при запросе стрима');
      }
    } on DioException catch (e) {
      throw Exception('Ошибка при получении стрима: ${e.message}');
    }
  }

  /// Получение деталей трека по ID
  Future<TrackModel> getTrackDetails(String trackId) async {
    try {
      final response = await _dio.get('/tracks/$trackId');

      final trackJson = response.data['data'];

      return TrackModel.fromJson({
        'id': trackJson['id'],
        'name': trackJson['title'],
        'artist_name': trackJson['user']['name'],
        'album_image': trackJson['artwork']?['1000x1000'] ?? '',
        'audio': '', // Поток получаем отдельно
        'duration': trackJson['duration'] ?? 0,
      });
    } on DioException catch (e) {
      throw Exception('Ошибка при получении деталей трека: ${e.message}');
    }
  }
}
