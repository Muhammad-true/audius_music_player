part of 'download_bloc.dart';

abstract class DownloadEvent {}

class StartDownload extends DownloadEvent {
  final TrackModel track;
  final String url;
  final String filename;

  StartDownload(
      {required this.track, required this.url, required this.filename});
}

class UpdateProgress extends DownloadEvent {
  final List<DownloadTrack> downloads;

  UpdateProgress({required this.downloads});
}

class PauseDownload extends DownloadEvent {
  final TrackModel track;

  PauseDownload({required this.track});
}

class ResumeDownload extends DownloadEvent {
  final TrackModel track;

  ResumeDownload({required this.track});
}

class CancelDownload extends DownloadEvent {
  final TrackModel track;

  CancelDownload({required this.track});
}
