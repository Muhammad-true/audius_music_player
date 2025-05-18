import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/track_model.dart';

class AudiusRepository {
  final Dio dio;

  AudiusRepository({required this.dio});

  static Future<AudiusRepository> create() async {
    final discoveryUrl = await _getDiscoveryNode();

    if (!discoveryUrl.isSuccess) {
      throw Exception(discoveryUrl.error);
    }

    final dio = Dio(BaseOptions(
      baseUrl: '${discoveryUrl.node}/v1',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(minutes: 2),
      sendTimeout: const Duration(minutes: 1),
    ));

    return AudiusRepository(dio: dio);
  }

  static Future<DiscoveryNodeResult> _getDiscoveryNode() async {
    try {
      final response = await Dio().get('https://api.audius.co');
      final data = response.data['data'];

      if (data != null && data is List && data.isNotEmpty) {
        return DiscoveryNodeResult.success(data.first.toString());
      } else {
        return DiscoveryNodeResult.failure('Сервер вернул пустой список нод.');
      }
    } catch (e) {
      return DiscoveryNodeResult.failure(
          'Ошибка подключения к Audius, проверьте интернет подключения');
    }
  }

  Future<List<TrackModel>> searchTracks(String query) async {
    try {
      final response = await dio.get(
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
          'can_download': trackJson['is_downloadable'] ?? false,
        });
      }).toList();
    } on DioError catch (e) {
      throw Exception('Ошибка при поиске треков: ${e.message}');
    }
  }

  Future<List<TrackModel>> getTopTracks() async {
    try {
      final response = await dio.get(
        '/tracks/trending',
        queryParameters: {'limit': 30},
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
    } on DioError catch (e) {
      throw Exception('Ошибка при получении топовых треков: ${e.message}');
    }
  }

  Future<List<TrackModel>> getUndergroundTrendingTracks() async {
    try {
      final response = await dio.get(
        '/tracks/trending/underground',
        queryParameters: {'limit': 30},
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
    } catch (e) {
      throw Exception('Ошибка при получении топовых треков: ${e.toString()}');
    }
  }

  Future<String> getStreamUrl(String trackId) async {
    try {
      final response = await dio.get(
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
    } on DioError catch (e) {
      throw Exception('Ошибка при получении стрима: ${e.message}');
    }
  }

  Future<TrackModel> getTrackDetails(String trackId) async {
    try {
      final response = await dio.get('/tracks/$trackId');

      final trackJson = response.data['data'];

      return TrackModel.fromJson({
        'id': trackJson['id'],
        'name': trackJson['title'],
        'artist_name': trackJson['user']['name'],
        'album_image': trackJson['artwork']?['1000x1000'] ?? '',
        'audio': '',
        'duration': trackJson['duration'] ?? 0,
        'can_download': trackJson['is_streamable'],
      });
    } catch (e) {
      throw Exception('Ошибка при получении деталей трека: ${e.toString()}');
    }
  }

  Future<TrackModel> downloadFullTrack({
    required TrackModel track,
    required void Function(double p) onProgress,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final audio = '${dir.path}/${track.id}.mp3';
    final cover = '${dir.path}/${track.id}.jpg';

    await dio.download(track.audioUrl, audio,
        onReceiveProgress: (r, t) => onProgress(t > 0 ? r / t : 0));
    if (track.coverArt.isNotEmpty) await dio.download(track.coverArt, cover);

    return track.copyWith(audioUrl: audio, coverArt: cover);
  }

  Future<void> _saveDownloadedTrack(TrackModel track) async {
    final prefs = await SharedPreferences.getInstance();
    final downloaded = prefs.getStringList('download_tracks') ?? [];

    // Проверяем, что этот трек ещё не был добавлен
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

    if (!downloaded.contains(trackJson)) {
      downloaded.add(trackJson);
      await prefs.setStringList('download_tracks', downloaded);
    }
  }

  Future<void> downloadPlaylist({
    required List<TrackModel> tracks,
    required void Function(String trackId, double progress) onProgress,
  }) async {
    for (final track in tracks) {
      if (track.canDownload!) {
        await downloadFullTrack(
          track: track,
          onProgress: (progress) => onProgress(track.id, progress),
        );
      }
    }
  }
}

class DiscoveryNodeResult {
  final String? node;
  final String? error;

  DiscoveryNodeResult.success(this.node) : error = null;
  DiscoveryNodeResult.failure(this.error) : node = null;

  bool get isSuccess => node != null;
}
