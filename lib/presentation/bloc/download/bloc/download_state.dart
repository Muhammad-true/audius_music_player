part of 'download_bloc.dart';

abstract class DownloadState {
  final List<DownloadTrack> downloads;

  DownloadState({required this.downloads});
}

class DownloadInitial extends DownloadState {
  DownloadInitial({required super.downloads});
}

class DownloadInProgress extends DownloadState {
  final List<DownloadTrack> downloads;

  DownloadInProgress({required this.downloads}) : super(downloads: []);
}

class DownloadCompleted extends DownloadState {
  final List<DownloadTrack> downloads;

  DownloadCompleted({required this.downloads}) : super(downloads: []);
}

class DownloadFailed extends DownloadState {
  final String errorMessage;

  DownloadFailed({required this.errorMessage}) : super(downloads: []);
}

class DownloadPaused extends DownloadState {
  final List<DownloadTrack> downloads;

  DownloadPaused({required this.downloads}) : super(downloads: []);
}
