import 'dart:async';

import 'package:audius_music_player/data/models/download_track.dart';
import 'package:audius_music_player/data/models/track_model.dart';
import 'package:audius_music_player/data/repositories/jamendoRepositor.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'download_event.dart';
part 'download_state.dart';

class DownloadBloc extends Bloc<DownloadEvent, DownloadState> {
  final JamendoRepository repository;
  final List<DownloadTrack> _downloads = [];

  DownloadBloc({required this.repository})
      : super(DownloadInitial(downloads: [])) {
    on<StartDownload>(_onStartDownload);
    on<UpdateProgress>(_onUpdateProgress);
    on<PauseDownload>(_onPauseDownload);
    on<ResumeDownload>(_onResumeDownload);
    on<CancelDownload>(_onCancelDownload);
  }

  /// Обработка старта загрузки
  Future<void> _onStartDownload(
      StartDownload event, Emitter<DownloadState> emit) async {
    final downloadTrack = DownloadTrack(
      track: event.track,
      url: event.url,
      filename: event.filename,
    );

    _downloads.add(downloadTrack);
    emit(DownloadInProgress(downloads: List.from(_downloads)));

    try {
      final streamUrl = await repository.getStreamUrl(event.track.id);
      await repository.downloadTrack(
        streamUrl: streamUrl,
        fileName: event.filename,
        onProgress: (progress) {
          downloadTrack.progress = progress;
          downloadTrack.status = DownloadStatus.downloading;
          add(UpdateProgress(
              downloads: List.from(_downloads))); // триггер прогресса
        },
      );
      // Скачиваем картинку
      await repository.downloadImage(
        imageUrl: event.track.coverArt,
        fileName: event.filename, // важно: имя то же, что и у аудио
      );

      downloadTrack.status = DownloadStatus.completed;
      emit(DownloadCompleted(downloads: List.from(_downloads)));
    } catch (e) {
      downloadTrack.status = DownloadStatus.failed;
      emit(DownloadFailed(errorMessage: e.toString()));
    }
  }

  /// Обновление прогресса загрузки
  void _onUpdateProgress(UpdateProgress event, Emitter<DownloadState> emit) {
    emit(DownloadInProgress(downloads: List.from(event.downloads)));
  }

  /// Пауза загрузки (зависит от реализации)
  void _onPauseDownload(PauseDownload event, Emitter<DownloadState> emit) {
    final track = _downloads.firstWhere((d) => d.track.id == event.track.id);
    track.status = DownloadStatus.paused;
    emit(DownloadPaused(downloads: List.from(_downloads)));
  }

  /// Возобновление загрузки (зависит от реализации)
  void _onResumeDownload(ResumeDownload event, Emitter<DownloadState> emit) {
    final track = _downloads.firstWhere((d) => d.track.id == event.track.id);
    track.status = DownloadStatus.downloading;
    emit(DownloadInProgress(downloads: List.from(_downloads)));
    // Реально нужно повторно вызывать downloadTrack если хочешь перезапустить
  }

  /// Отмена загрузки
  void _onCancelDownload(CancelDownload event, Emitter<DownloadState> emit) {
    _downloads.removeWhere((d) => d.track.id == event.track.id);
    emit(DownloadInProgress(downloads: List.from(_downloads)));
  }
}
