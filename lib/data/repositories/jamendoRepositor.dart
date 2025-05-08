import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/track_model.dart';

class JamendoRepository {
  final Dio _dio;

  JamendoRepository._(this._dio);

  static Future<JamendoRepository> create() async {
    final discoveryUrl = await _getDiscoveryNode();

    final dio = Dio(BaseOptions(
      baseUrl: '$discoveryUrl/v1',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(minutes: 2),
      sendTimeout: const Duration(minutes: 1),
    ));

    return JamendoRepository._(dio);
  }

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
          'audio': '',
          'duration': trackJson['duration'] ?? 0,
          'is_streamable': trackJson['is_streamable'],
          'can_download': trackJson['download']['is_downloadable'] ?? false,
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
          'audio': '',
          'duration': trackJson['duration'] ?? 0,
          'is_streamable': trackJson['is_streamable'],
          'can_download': trackJson['is_streamable'] ?? false,
        });
      }).toList();
    } on DioException catch (e) {
      throw Exception('Ошибка при получении топовых треков: ${e.message}');
    }
  }

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

  Future<TrackModel> getTrackDetails(String trackId) async {
    try {
      final response = await _dio.get('/tracks/$trackId');

      final trackJson = response.data['data'];

      return TrackModel.fromJson({
        'id': trackJson['id'],
        'name': trackJson['title'],
        'artist_name': trackJson['user']['name'],
        'album_image': trackJson['artwork']?['1000x1000'] ?? '',
        'audio': '',
        'duration': trackJson['duration'] ?? 0,
        'can_download': trackJson['is_streamable'] ?? false,
      });
    } on DioException catch (e) {
      throw Exception('Ошибка при получении деталей трека: ${e.message}');
    }
  }

  Future<void> downloadTrack({
    required String streamUrl,
    required String fileName,
    required void Function(double progress) onProgress,
  }) async {
    try {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Нет разришения на доступ к хранилищу');
      }
      final downloadsDir = Directory('/storage/emulated/0/Download');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }
      final filePath = '${downloadsDir.path}/$fileName.mp3';

      await _dio.download(
        streamUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress(received / total);
          }
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> downloadPlaylist({
    required List<TrackModel> tracks,
    required void Function(String trackId, double progress) onProgress,
  }) async {
    for (final track in tracks) {
      if (track.canDownload) {
        final streamUrl = await getStreamUrl(track.id);
        await downloadTrack(
          streamUrl: streamUrl,
          fileName: '${track.artistName} - ${track.title}',
          onProgress: (progress) => onProgress(track.id, progress),
        );
      }
    }
  }

  Future<void> downloadImage({
    required String imageUrl,
    required String fileName,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/$fileName.jpg';

      await _dio.download(
        imageUrl,
        filePath,
        options: Options(
          receiveTimeout: const Duration(seconds: 20),
          responseType: ResponseType.bytes,
        ),
      );
    } catch (e) {
      rethrow;
    }
  }
}
