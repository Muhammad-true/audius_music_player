import 'dart:async';
import 'dart:convert';

import 'package:audius_music_player/data/models/download_track.dart';
import 'package:audius_music_player/data/models/track_model.dart';
import 'package:audius_music_player/data/repositories/jamendoRepositor.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'download_event.dart';
part 'download_state.dart';

class DownloadBloc extends Bloc<DownloadEvent, DownloadState> {
  final JamendoRepository repository;
  final List<DownloadTrack> _downloads = [];
  List<TrackModel> _completedTracks = [];

  DownloadBloc({required this.repository})
      : super(DownloadInitial(downloads: [])) {
    on<StartDownload>(_onStartDownload);
    on<UpdateProgress>(_onUpdateProgress);
    on<PauseDownload>(_onPauseDownload);
    on<ResumeDownload>(_onResumeDownload);
    on<CancelDownload>(_onCancelDownload);
    on<LoadDownloadedTracks>(_onLoadDownloadedTracks);
    on<DeleteDownloadedTrack>(_onDeleteDownloadTrak);
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
      final localTrack = event.track.copyWith(audioUrl: streamUrl);
      await repository.downloadFullTrack(
        track: localTrack,
        onProgress: (progress) {
          downloadTrack.progress = progress;
          downloadTrack.status = DownloadStatus.downloading;
          add(UpdateProgress(
              downloads: List.from(_downloads))); // триггер прогресса
        },
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

  Future<void> _onLoadDownloadedTracks(
    LoadDownloadedTracks event,
    Emitter<DownloadState> emit,
  ) async {
    emit(DownloadLoading(downloads: []));
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedList = prefs.getStringList('download_tracks') ?? [];

      final tracks = savedList.map((jsonStr) {
        final jsonMap = json.decode(jsonStr);
        return TrackModel(
          id: jsonMap['id'],
          title: jsonMap['title'],
          artistName: jsonMap['artistName'],
          coverArt: jsonMap['coverArt'],
          audioUrl: jsonMap['audioUrl'],
          duration: jsonMap['duration'],
          isFavorite: jsonMap['isFavorite'],
          canDownload: jsonMap['canDownload'],
        );
      }).toList();

      _completedTracks = tracks;

      emit(DownloadLoaded(tracks));
    } catch (e) {
      emit(DownloadError('Ошибка загрузки треков: $e'));
    }
  }

  Future<void> _onDeleteDownloadTrak(
    DeleteDownloadedTrack event,
    Emitter<DownloadState> emit,
  ) async {
    try {
      _completedTracks.removeWhere((t) => t.id == event.track.id);

      final prefs = await SharedPreferences.getInstance();
      final updatedJsonList = _completedTracks
          .map((track) => json.encode({
                'id': track.id,
                'title': track.title,
                'artistName': track.artistName,
                'coverArt': track.coverArt,
                'audioUrl': track.audioUrl,
                'duration': track.duration,
                'isFavorite': track.isFavorite,
                'canDownload': track.canDownload,
              }))
          .toList();

      await prefs.setStringList('download_tracks', updatedJsonList);

      emit(DownloadLoaded(List.unmodifiable(_completedTracks)));
    } catch (e) {
      emit(DownloadError('Ошибка при удалении: $e'));
    }
  }
}
