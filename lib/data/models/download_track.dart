import 'package:audius_music_player/data/models/track_model.dart';

class DownloadTrack {
  final TrackModel track;
  final String url;
  final String filename;
  double progress = 0.0; // Прогресс в % (0.0 - 1.0)
  DownloadStatus status = DownloadStatus.pending; // Статус загрузки

  DownloadTrack({
    required this.track,
    required this.url,
    required this.filename,
  });
}

enum DownloadStatus { pending, downloading, completed, paused, failed }
