import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

import '../../../data/models/track_model.dart';
import '../../../data/repositories/jamendoRepositor.dart';
import '../../../data/services/storage_service.dart';

part 'player_event.dart';
part 'player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final JamendoRepository repository;
  final AudioPlayer audioPlayer;
  final StorageService storageService;

  int _currentIndex = -1;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerStateSubscription;
  bool isclicked = false;
  bool _isShuffle = false;

  PlayerBloc({
    required this.repository,
    required this.storageService,
    required this.audioPlayer,
  }) : super(const PlayerInitial()) {
    on<PlayTrack>(_onPlayTrack);
    on<PauseTrack>(_onPauseTrack);
    on<ResumeTrack>(_onResumeTrack);
    on<ToggleFavorite>(_onToggleFavorite);
    on<SeekTo>(_onSeekTo);
    on<NextTrack>(_onNextTrack);
    on<PreviousTrack>(_onPreviousTrack);
    on<UpdatePosition>(_onUpdatePosition);
    on<PlayerStateChanged>(_onPlayerStateChanged);
    on<ToggleRepeat>(_onToggleRepeat);
    on<ToggleShuffle>(_onToggleShuffle);
    on<PlayerStopped>(_playerStoped);
  }

  void _setupAudioPlayer(List<TrackModel> tracks) {
    _playerStateSubscription?.cancel(); // отменяем старую подписку
    _positionSubscription?.cancel();

    _playerStateSubscription =
        audioPlayer.playerStateStream.listen((playerState) async {
      if (playerState.processingState == ProcessingState.completed) {
        if (state.isRepeat) {
          await audioPlayer.seek(Duration.zero);
          await audioPlayer.play();
        } else {
          if (!isclicked) {
            isclicked = true;
            add(NextTrack(tracks: tracks));
          }
        }
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

  Future<void> _onPlayTrack(
    PlayTrack event,
    Emitter<PlayerState> emit,
  ) async {
    try {
      _setupAudioPlayer(event.tracks);
      _currentIndex =
          event.tracks.indexWhere((track) => track.id == event.track.id);
      if (_currentIndex == -1) return;

      emit(PlayerLoading(track: event.track, tracks: event.tracks));

      final stream = await repository.getStreamUrl(event.track.id);

      await audioPlayer.setUrl(stream);
      audioPlayer.play();

      emit(PlayerPlaying(
        event.track,
        tracks: event.tracks,
        position: Duration.zero,
        duration: audioPlayer.duration ?? Duration.zero,
        isRepeat: state.isRepeat,
        isShuffle: _isShuffle,
      ));

      isclicked = false;
    } catch (e) {
      emit(PlayerError(e.toString()));
    }
  }

  Future<void> _onPauseTrack(
    PauseTrack event,
    Emitter<PlayerState> emit,
  ) async {
    if (state is! PlayerPlaying) return;

    // Сохраняем данные ДО await
    final currentTrack = (state as PlayerPlaying).track;
    final currentTracks = (state as PlayerPlaying).tracks;
    final currentPosition = audioPlayer.position;
    final currentDuration = audioPlayer.duration ?? Duration.zero;

    await audioPlayer.pause(); // Здесь состояние может измениться асинхронно

    //Проверяем, что состояние все еще актуально
    if (state is PlayerPlaying) {
      emit(PlayerPaused(
        currentTrack,
        position: currentPosition,
        duration: currentDuration,
        tracks: currentTracks,
        isRepeat: (state as PlayerPlaying).isRepeat,
        isShuffle: (state as PlayerPlaying).isShuffle,
      ));
    }
  }

  Future<void> _onResumeTrack(
      ResumeTrack event, Emitter<PlayerState> emit) async {
    if (state is PlayerPaused) {
      await audioPlayer.play();
      emit(PlayerPlaying((state as PlayerPaused).track,
          tracks: event.tracks,
          position: audioPlayer.position,
          duration: audioPlayer.duration ?? Duration.zero,
          isRepeat: state.isRepeat,
          isShuffle: (state as PlayerPlaying).isShuffle));
    }
  }

  void _onUpdatePosition(UpdatePosition event, Emitter<PlayerState> emit) {
    if (state is PlayerPlaying) {
      emit(PlayerPlaying((state as PlayerPlaying).track,
          tracks: (state as PlayerPlaying).tracks,
          position: event.position,
          duration: (state as PlayerPlaying).duration,
          isRepeat: (state as PlayerPlaying).isRepeat,
          isShuffle: (state as PlayerPlaying).isShuffle));
    }
  }

  Future<void> _onToggleFavorite(
      ToggleFavorite event, Emitter<PlayerState> emit) async {
    final updatedTrack =
        event.track.copyWith(isFavorite: !event.track.isFavorite);

    emit(PlayerPlaying(updatedTrack,
        tracks: (state as PlayerPlaying).tracks,
        position: (state as PlayerPlaying).position,
        duration: (state as PlayerPlaying).duration,
        isRepeat: (state as PlayerPlaying).isRepeat,
        isShuffle: (state as PlayerPlaying).isShuffle));

    event.track.isFavorite
        ? storageService.removeFavoriteTrack(event.track.id)
        : storageService.saveFavoriteTrack(event.track.id);
  }

  Future<void> _onNextTrack(
    NextTrack event,
    Emitter<PlayerState> emit,
  ) async {
    audioPlayer.stop();
    if (event.tracks.isNotEmpty) {
      if (_isShuffle) {
        final random = event.tracks.toList()..shuffle();
        _currentIndex = 0;
        final nextTrack = random[_currentIndex];
        await _onPlayTrack(PlayTrack(nextTrack, random), emit);
      } else {
        _currentIndex = (_currentIndex + 1) % event.tracks.length;
        final nextTrack = event.tracks[_currentIndex];
        await _onPlayTrack(PlayTrack(nextTrack, event.tracks), emit);
      }
    }
  }

  Future<void> _onPreviousTrack(
      PreviousTrack event, Emitter<PlayerState> emit) async {
    if (event.tracks.isNotEmpty) {
      _currentIndex =
          (_currentIndex - 1 + event.tracks.length) % event.tracks.length;
      await _onPlayTrack(
          PlayTrack(event.tracks[_currentIndex], event.tracks), emit);
    }
  }

  Future<void> _onSeekTo(SeekTo event, Emitter<PlayerState> emit) async {
    await audioPlayer.seek(event.position);
  }

  /// Обработчик изменения состояния плеера
  void _onPlayerStateChanged(
    PlayerStateChanged event,
    Emitter<PlayerState> emit,
  ) {
    if (state is PlayerPlaying || state is PlayerPaused) {
      final currentState = state as dynamic;
      final currentTrack = currentState.track;
      final currentTracks = currentState.tracks;
      final currentPosition = audioPlayer.position;
      final currentDuration = audioPlayer.duration ?? Duration.zero;

      if (event.isPlaying) {
        emit(PlayerPlaying(
          currentTrack,
          tracks: currentTracks,
          position: currentPosition,
          duration: currentDuration,
          isRepeat: currentState.isRepeat,
          isShuffle: currentState.isShuffle,
        ));
      } else {
        emit(PlayerPaused(
          currentTrack,
          position: currentPosition,
          duration: currentDuration,
          tracks: currentTracks,
          isRepeat: currentState.isRepeat,
          isShuffle: currentState.isShuffle,
        ));
      }
    }
  }

  void _onToggleRepeat(ToggleRepeat event, Emitter<PlayerState> emit) {
    final bool newRepeat = !state.isRepeat;

    audioPlayer.setLoopMode(newRepeat ? LoopMode.one : LoopMode.off);

    if (state is PlayerPlaying) {
      final playingState = state as PlayerPlaying;
      emit(PlayerPlaying(
        playingState.track,
        tracks: playingState.tracks,
        position: playingState.position,
        duration: playingState.duration,
        isRepeat: newRepeat,
        isShuffle: playingState.isShuffle,
      ));
    } else {
      emit(const PlayerInitial()); // fallback
    }
  }

  void _onToggleShuffle(ToggleShuffle event, Emitter<PlayerState> emit) {
    _isShuffle = !_isShuffle;

    if (state is PlayerPlaying) {
      final playing = state as PlayerPlaying;
      emit(PlayerPlaying(
        playing.track,
        tracks: playing.tracks,
        position: playing.position,
        duration: playing.duration,
        isRepeat: playing.isRepeat,
        isShuffle: _isShuffle,
      ));
    }
  }

  @override
  Future<void> close() async {
    await _positionSubscription?.cancel();
    await _playerStateSubscription?.cancel();
    await audioPlayer.dispose();
    return super.close();
  }

  FutureOr<void> _playerStoped(
      PlayerStopped event, Emitter<PlayerState> emit) async {
    await audioPlayer.stop(); // остановка плеера
    emit(PlayerInitial());
  }
}
