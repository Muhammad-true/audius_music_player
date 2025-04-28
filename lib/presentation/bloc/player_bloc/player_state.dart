part of 'player_bloc.dart';

// Состояния плеера
abstract class PlayerState {
  final bool isRepeat;
  const PlayerState({this.isRepeat = false});
}

class PlayerInitial extends PlayerState {
  const PlayerInitial() : super(isRepeat: false);
}

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
  final List<TrackModel> tracks;
  final Duration position;
  final Duration duration;
  final bool isRepeat;
  final bool isShuffle;

  PlayerPlaying(this.track,
      {required this.tracks,
      required this.position,
      required this.duration,
      required this.isRepeat,
      required this.isShuffle});
}

class PlayerPaused extends PlayerState {
  final TrackModel track;
  final Duration position;
  final Duration duration;
  final List<TrackModel> tracks;
  final bool isRepeat;
  final bool isShuffle;

  PlayerPaused(this.track,
      {required this.position,
      required this.duration,
      required this.tracks,
      required this.isRepeat,
      required this.isShuffle});
}

class PlayerError extends PlayerState {
  final String message;
  PlayerError(this.message);
}
