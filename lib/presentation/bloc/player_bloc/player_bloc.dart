import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

import '../../../data/models/track_model.dart';
import '../../../data/repositories/audius_repository.dart';
import '../../../data/services/storage_service.dart';

part 'player_event.dart';
part 'player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final AudiusRepository repository;
  final AudioPlayer audioPlayer;
  final StorageService storageService;
  List<TrackModel> _playlist = [];
  int _currentIndex = -1;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _durationSubscription;

  PlayerBloc({
    required this.repository,
    required this.storageService,
    required this.audioPlayer,
  }) : super(PlayerInitial()) {
    on<LoadTrendingTracks>(_onLoadTrendingTracks);
    on<PlayTrack>(_onPlayTrack);
    on<PauseTrack>(_onPauseTrack);
    on<ResumeTrack>(_onResumeTrack);
    on<ToggleFavorite>(_onToggleFavorite);
    on<SeekTo>(_onSeekTo);
    on<NextTrack>(_onNextTrack);
    on<PreviousTrack>(_onPreviousTrack);
    on<UpdatePosition>(_onUpdatePosition);
    on<PlayerStateChanged>(_onPlayerStateChanged);
  }

  Future<void> _onLoadTrendingTracks(
    LoadTrendingTracks event,
    Emitter<PlayerState> emit,
  ) async {
    emit(PlayerLoading(
        track: TrackModel(
            id: '',
            title: '',
            artistName: '',
            coverArt: '',
            audioUrl: '',
            duration: 0),
        tracks: []));
    try {
      final tracks = await repository.getTrendingTracks();
      _playlist = await Future.wait(tracks.map((track) async {
        final isFavorite = await storageService.isTrackFavorite(track.id);
        return track.copyWith(isFavorite: isFavorite);
      }));

      emit(TracksLoaded(_playlist));
    } catch (e) {
      emit(PlayerError(e.toString()));
    }
  }

  void _setupAudioPlayer(traks) {
    _playerStateSubscription =
        audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        add(NextTrack(tracks: traks)); // Используем _playlist
      } else {
        add(PlayerStateChanged(audioPlayer.playing));
      }
    });

    _positionSubscription = audioPlayer.positionStream.listen((position) {
      if (state is PlayerPlaying && audioPlayer.playing) {
        add(UpdatePosition(position));
      }
    });
  }

  void _onPlayerStateChanged(
    PlayerStateChanged event,
    Emitter<PlayerState> emit,
  ) {
    if (state is PlayerPlaying || state is PlayerPaused) {
      final currentTrack = (state as dynamic).track;
      final currentTracks = (state as dynamic).tracks;
      final currentPosition = audioPlayer.position;
      final currentDuration = audioPlayer.duration ?? Duration.zero;

      if (event.isPlaying) {
        emit(PlayerPlaying(
          currentTrack,
          tracks: currentTracks,
          position: currentPosition,
          duration: currentDuration,
        ));
      } else {
        if (state is PlayerPaused) {
          emit(PlayerPaused(currentTrack,
              position: currentPosition,
              duration: currentDuration,
              tracks: currentTracks // Без приведения!
              ));
        } else if (state is PlayerPlaying) {
          emit(PlayerPaused(currentTrack,
              position: currentPosition,
              duration: currentDuration,
              tracks: currentTracks));
        }
      }
    }
  }

  Future<void> _onPlayTrack(
    PlayTrack event,
    Emitter<PlayerState> emit,
  ) async {
    try {
      _setupAudioPlayer(event.tracks);
      print(
          "Получено событие PlayTrack для трека: ${event.track.title}"); // Проверка
      // Если трека нет в плейлисте, добавляем
      if (!event.tracks.any((track) => track.id == event.track.id)) {
        event.tracks.add(event.track);
        print("Трек ${event.track.title} добавлен в плейлист");
      }
      _currentIndex =
          event.tracks.indexWhere((track) => track.id == event.track.id);
      print("Текущий индекс в плейлисте: $_currentIndex");
      if (_currentIndex == -1) {
        print("Ошибка: трек не найден в плейлисте!");
        return;
      }

      emit(PlayerLoading(track: event.track, tracks: event.tracks));

      final streamUrl = await repository.getStreamUrl(event.track.id);
      emit(PlayerPlaying(event.track,
          tracks: event.tracks,
          position: audioPlayer.position,
          duration: audioPlayer.duration ?? Duration.zero));

      await audioPlayer.setUrl(streamUrl);
      print("Статус плеера перед воспроизведением: ${audioPlayer.playerState}");

      await audioPlayer.play();

      print(
          "Статус плеера после попытки воспроизведения: ${audioPlayer.playerState}");
    } catch (e) {
      emit(PlayerError(e.toString()));
    }
  }

  Future<void> _onPauseTrack(
    PauseTrack event,
    Emitter<PlayerState> emit,
  ) async {
    if (state is PlayerPlaying) {
      await audioPlayer.pause();

      // Проверяем, что state всё ещё PlayerPlaying
      if (state is PlayerPlaying) {
        emit(PlayerPaused(
          event.track,
          position: audioPlayer.position,
          duration: audioPlayer.duration ?? Duration.zero,
          tracks: (state as PlayerPlaying).tracks,
        ));
      }
    }
  }

  Future<void> _onResumeTrack(
    ResumeTrack event,
    Emitter<PlayerState> emit,
  ) async {
    if (state is PlayerPaused) {
      final currentTrack = (state as PlayerPaused).track;
      await audioPlayer.play();

      emit(PlayerPlaying(
        currentTrack,
        tracks: event.tracks,
        position: audioPlayer.position,
        duration: audioPlayer.duration ?? Duration.zero,
      ));
    }
  }

  void _onUpdatePosition(
    UpdatePosition event,
    Emitter<PlayerState> emit,
  ) {
    if (state is PlayerPlaying) {
      final currentState = state as PlayerPlaying;
      emit(PlayerPlaying(
        currentState.track,
        tracks: currentState.tracks,
        position: event.position,
        duration: currentState.duration,
      ));
    }
  }

  Future<void> _onSeekTo(
    SeekTo event,
    Emitter<PlayerState> emit,
  ) async {
    await audioPlayer.seek(event.position);
  }

  Future<void> _onNextTrack(
    NextTrack event,
    Emitter<PlayerState> emit,
  ) async {
    if (event.tracks.isNotEmpty) {
      _currentIndex = (_currentIndex + 1) % event.tracks.length;
      await _onPlayTrack(
          PlayTrack(event.tracks[_currentIndex], event.tracks), emit);
    }
  }

  Future<void> _onPreviousTrack(
    PreviousTrack event,
    Emitter<PlayerState> emit,
  ) async {
    if (event.tracks.isNotEmpty) {
      _currentIndex =
          (_currentIndex - 1 + event.tracks.length) % event.tracks.length;
      await _onPlayTrack(
          PlayTrack(event.tracks[_currentIndex], event.tracks), emit);
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<PlayerState> emit,
  ) async {
    try {
      if (event.track.isFavorite) {
        await storageService.removeFavoriteTrack(event.track.id);
      } else {
        await storageService.saveFavoriteTrack(event.track.id);
      }

      // Обновляем список треков (если он загружен)
      if (state is TracksLoaded) {
        final tracks = (state as TracksLoaded).tracks.map((track) {
          if (track.id == event.track.id) {
            return track.copyWith(isFavorite: !track.isFavorite);
          }
          return track;
        }).toList();
        emit(TracksLoaded(tracks));
      }

      // Обновляем текущий трек, если он сейчас играет
      if (state is PlayerPlaying) {
        final currentState = state as PlayerPlaying;
        if (currentState.track.id == event.track.id) {
          final updatedTrack = currentState.track
              .copyWith(isFavorite: !currentState.track.isFavorite);
          emit(PlayerPlaying(updatedTrack,
              tracks: currentState.tracks,
              position: currentState.position,
              duration: currentState.duration));
        }
      }
    } catch (e) {
      emit(PlayerError(e.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _positionSubscription?.cancel();
    await _playerStateSubscription?.cancel();
    await _durationSubscription?.cancel();
    await audioPlayer.dispose();
    return super.close();
  }
}
