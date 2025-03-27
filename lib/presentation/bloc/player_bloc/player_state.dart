part of 'player_bloc.dart';

// Состояния плеера
abstract class PlayerState {}

class PlayerInitial extends PlayerState {}

class PlayerLoading extends PlayerState {
  final TrackModel track;
  final List<TrackModel> tracks;

  PlayerLoading({required this.track, required this.tracks});
}

class TracksLoaded extends PlayerState {
  final List<TrackModel> tracks;
  TracksLoaded(this.tracks);
}

class PlayerPlaying extends PlayerState {
  final TrackModel track;
  List<TrackModel> tracks;
  final Duration position;
  final Duration duration;

  PlayerPlaying(this.track,
      {required this.tracks, required this.position, required this.duration});
}

class PlayerPaused extends PlayerState {
  final TrackModel track;
  final Duration position;
  final Duration duration;
  final List<TrackModel> tracks;

  PlayerPaused(this.track,
      {required this.position, required this.duration, required this.tracks});
}

class PlayerError extends PlayerState {
  final String message;
  PlayerError(this.message);
}
