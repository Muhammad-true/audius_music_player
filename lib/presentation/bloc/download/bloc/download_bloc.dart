import 'dart:async';
import 'dart:convert';

import 'package:audius_music_player/data/models/download_track.dart';
import 'package:audius_music_player/data/models/track_model.dart';
import 'package:audius_music_player/data/repositories/audius_repositor.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'download_event.dart';
part 'download_state.dart';

class DownloadBloc extends Bloc<DownloadEvent, DownloadState> {
  final AudiusRepository repository;
  final List<DownloadTrack> _downloads = [];
  final List<TrackModel> _completedTracks = [];

  DownloadBloc({required this.repository})
      : super(DownloadInitial(downloads: [])) {
    on<StartDownload>(_onStartDownload);
    on<UpdateProgress>(_onUpdateProgress);
    on<PauseDownload>(_onPauseDownload);
    on<ResumeDownload>(_onResumeDownload);
    on<CancelDownload>(_onCancelDownload);
    on<LoadDownloadedTracks>(_onLoadDownloadedTracks);
    on<DeleteDownloadedTrack>(_onDeleteDownloadTrack);
  }

  /// Проверка — скачан ли трек (используется в UI)
  bool isTrackDownloaded(String trackId) {
    return _completedTracks.any((track) => track.id == trackId);
  }

  Future<void> _onStartDownload(
    StartDownload event,
    Emitter<DownloadState> emit,
  ) async {
    // 1. добавляем «черновик» в UI-список, но НЕ в SharedPrefs
    final d = DownloadTrack(
      track: event.track,
      url: event.url,
      filename: event.filename,
    );
    _downloads.add(d);
    emit(DownloadInProgress(downloads: List.from(_downloads)));

    try {
      // 2. stream-url
      final streamUrl = await repository.getStreamUrl(event.track.id);
      final trackWithStream = event.track.copyWith(audioUrl: streamUrl);

      // 3. скачиваем; метод возвращает МОДЕЛЬ с ЛОКАЛЬНЫМИ путями
      final localTrack = await repository.downloadFullTrack(
        track: trackWithStream,
        onProgress: (p) {
          d
            ..progress = p
            ..status = DownloadStatus.downloading;
          add(UpdateProgress(downloads: List.from(_downloads)));
        },
      );

      // 4. итог
      d.status = DownloadStatus.completed;
      _completedTracks.add(localTrack);

      await _saveOrReplace(localTrack); // ← записываем одну, удаляя старые

      emit(DownloadCompleted(downloads: List.from(_downloads)));
      emit(DownloadLoaded(List.unmodifiable(_completedTracks)));
    } catch (e) {
      d.status = DownloadStatus.failed;
      emit(DownloadFailed(errorMessage: e.toString()));
    }
  }

  Future<void> _saveOrReplace(TrackModel t) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('download_tracks') ?? [];

    // убираем все записи с тем же id
    list.removeWhere((s) => json.decode(s)['id'] == t.id);

    // добавляем одну «чистую» запись
    list.add(json.encode(_trackToJson(t)));
    await prefs.setStringList('download_tracks', list);
  }

  void _onUpdateProgress(UpdateProgress event, Emitter<DownloadState> emit) {
    emit(DownloadInProgress(downloads: List.from(event.downloads)));
  }

  void _onPauseDownload(PauseDownload event, Emitter<DownloadState> emit) {
    final track = _downloads.firstWhere((d) => d.track.id == event.track.id);
    track.status = DownloadStatus.paused;
    emit(DownloadPaused(downloads: List.from(_downloads)));
  }

  void _onResumeDownload(ResumeDownload event, Emitter<DownloadState> emit) {
    final track = _downloads.firstWhere((d) => d.track.id == event.track.id);
    track.status = DownloadStatus.downloading;
    emit(DownloadInProgress(downloads: List.from(_downloads)));
    // Здесь можно перезапустить загрузку, если хочешь
  }

  void _onCancelDownload(CancelDownload event, Emitter<DownloadState> emit) {
    _downloads.removeWhere((d) => d.track.id == event.track.id);
    emit(DownloadInProgress(downloads: List.from(_downloads)));
  }

  Future<void> _onLoadDownloadedTracks(
      LoadDownloadedTracks event, Emitter<DownloadState> emit) async {
    emit(DownloadLoading(downloads: []));
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedList = prefs.getStringList('download_tracks') ?? [];

      _completedTracks.clear();
      _completedTracks.addAll(savedList.map((jsonStr) {
        return _trackFromJson(json.decode(jsonStr));
      }));

      emit(DownloadLoaded(List.unmodifiable(_completedTracks)));
    } catch (e) {
      emit(DownloadError('Ошибка загрузки треков: $e'));
    }
  }

  Future<void> _onDeleteDownloadTrack(
      DeleteDownloadedTrack event, Emitter<DownloadState> emit) async {
    try {
      _completedTracks.removeWhere((t) => t.id == event.track.id);

      final prefs = await SharedPreferences.getInstance();
      final updatedJsonList = _completedTracks
          .map((track) => json.encode(_trackToJson(track)))
          .toList();

      await prefs.setStringList('download_tracks', updatedJsonList);

      emit(DownloadLoaded(List.unmodifiable(_completedTracks)));
    } catch (e) {
      emit(DownloadError('Ошибка при удалении: $e'));
    }
  }

  /// Хелперы
  Map<String, dynamic> _trackToJson(TrackModel track) => {
        'id': track.id,
        'title': track.title,
        'artistName': track.artistName,
        'coverArt': track.coverArt,
        'audioUrl': track.audioUrl,
        'duration': track.duration,
        'isFavorite': track.isFavorite,
        'canDownload': track.canDownload,
      };

  TrackModel _trackFromJson(Map<String, dynamic> json) => TrackModel(
        id: json['id'],
        title: json['title'],
        artistName: json['artistName'],
        coverArt: json['coverArt'],
        audioUrl: json['audioUrl'],
        duration: json['duration'],
        isFavorite: json['isFavorite'],
        canDownload: json['canDownload'],
      );
}
