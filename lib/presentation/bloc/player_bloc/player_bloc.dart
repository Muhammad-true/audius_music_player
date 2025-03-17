import 'dart:async';

import 'package:flutter/material.dart';
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

    _setupAudioPlayer();
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
            duration: 0)));
    try {
      final tracks = await repository.getTrendingTracks();
      _playlist = tracks.map((track) {
        return track.copyWith(
          isFavorite: storageService.isTrackFavorite(track.id),
        );
      }).toList();
      emit(TracksLoaded(_playlist));
    } catch (e) {
      emit(PlayerError(e.toString()));
    }
  }

  void _setupAudioPlayer() {
    _playerStateSubscription =
        audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        add(NextTrack());
      } else {
        add(PlayerStateChanged(audioPlayer.playing));
      }
    });

    _positionSubscription = audioPlayer.positionStream.listen((position) {
      if (state is PlayerPlaying) {
        add(UpdatePosition(position));
      }
    });
  }

  void _onPlayerStateChanged(
    PlayerStateChanged event,
    Emitter<PlayerState> emit,
  ) {
    debugPrint("Player state changed: isPlaying=${event.isPlaying}");

    if (state is PlayerPlaying || state is PlayerPaused) {
      final currentTrack = (state as dynamic).track;
      final currentPosition = audioPlayer.position;
      final currentDuration = audioPlayer.duration ?? Duration.zero;

      if (event.isPlaying) {
        emit(PlayerPlaying(currentTrack,
            position: currentPosition, duration: currentDuration));
      } else {
        emit(PlayerPaused(currentTrack,
            position: currentPosition, duration: currentDuration));
      }
    }
  }

  Future<void> _onPlayTrack(
    PlayTrack event,
    Emitter<PlayerState> emit,
  ) async {
    try {
      _currentIndex =
          _playlist.indexWhere((track) => track.id == event.track.id);
      if (_currentIndex == -1) return;

      emit(PlayerLoading(track: event.track));

      final streamUrl = await repository.getStreamUrl(event.track.id);
      emit(PlayerPlaying(event.track,
          position: audioPlayer.position,
          duration: audioPlayer.duration ?? Duration.zero));

      await audioPlayer.setUrl(streamUrl);
      await audioPlayer.play();
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
        final currentTrack = (state as PlayerPlaying).track;

        emit(PlayerPaused(
          currentTrack,
          position: audioPlayer.position,
          duration: audioPlayer.duration ?? Duration.zero,
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
    if (_playlist.isNotEmpty) {
      _currentIndex = (_currentIndex + 1) % _playlist.length;
      await _onPlayTrack(PlayTrack(_playlist[_currentIndex]), emit);
    }
  }

  Future<void> _onPreviousTrack(
    PreviousTrack event,
    Emitter<PlayerState> emit,
  ) async {
    if (_playlist.isNotEmpty) {
      _currentIndex = (_currentIndex - 1 + _playlist.length) % _playlist.length;
      await _onPlayTrack(PlayTrack(_playlist[_currentIndex]), emit);
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

      // Обновляем текущее состояние с новым статусом избранного
      if (state is TracksLoaded) {
        final tracks = (state as TracksLoaded).tracks.map((track) {
          if (track.id == event.track.id) {
            return track.copyWith(isFavorite: !track.isFavorite);
          }
          return track;
        }).toList();
        emit(TracksLoaded(tracks));
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
