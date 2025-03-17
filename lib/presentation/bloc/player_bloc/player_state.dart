part of 'player_bloc.dart';

// Состояния плеера
abstract class PlayerState {}

class PlayerInitial extends PlayerState {}

class PlayerLoading extends PlayerState {
  final TrackModel track;

  PlayerLoading({required this.track});
}

class TracksLoaded extends PlayerState {
  final List<TrackModel> tracks;
  TracksLoaded(this.tracks);
}

class PlayerPlaying extends PlayerState {
  final TrackModel track;
  final Duration position;
  final Duration duration;

  PlayerPlaying(this.track, {required this.position, required this.duration});
}

class PlayerPaused extends PlayerState {
  final TrackModel track;
  final Duration position;
  final Duration duration;

  PlayerPaused(this.track, {required this.position, required this.duration});
}

class PlayerError extends PlayerState {
  final String message;
  PlayerError(this.message);
}
