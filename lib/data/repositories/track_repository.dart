import 'package:audius_music_player/data/models/track_model.dart';
import 'package:dio/dio.dart';

class TrackRepository {
  final Dio _dio;

  TrackRepository({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'https://api.audius.co/v1',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ));

  // 🔍 Поиск треков по запросу
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
          'audio': trackJson['preview_cid'] != null
              ? 'https://ipfs.audius.co/ipfs/${trackJson['preview_cid']}'
              : '',
          'duration': trackJson['duration'] ?? 0,
        });
      }).toList();
    } on DioException catch (e) {
      throw Exception('Ошибка при поиске треков: ${e.message}');
    }
  }

  // 🎧 Получение топовых треков
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
          'audio': trackJson['preview_cid'] != null
              ? 'https://ipfs.audius.co/ipfs/${trackJson['preview_cid']}'
              : '',
          'duration': trackJson['duration'] ?? 0,
        });
      }).toList();
    } on DioException catch (e) {
      throw Exception('Ошибка при получении топовых треков: ${e.message}');
    }
  }

  // Получение прямого URL на стрим трека
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
        // Сервер вернул редирект на реальный аудиофайл
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
}

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
