part of 'player_bloc.dart';

// События для управления плеером
abstract class PlayerEvent {}

class SearchTracks extends PlayerEvent {
  final String query;
  SearchTracks(this.query);
}

class PlayTrack extends PlayerEvent {
  final TrackModel track;
  final List<TrackModel> tracks;
  PlayTrack(this.track, this.tracks);
}

class PauseTrack extends PlayerEvent {
  TrackModel track;
  PauseTrack({required this.track});
}

class ResumeTrack extends PlayerEvent {
  final List<TrackModel> tracks;
  ResumeTrack({required this.tracks});
}

class NextTrack extends PlayerEvent {
  final List<TrackModel> tracks;
  NextTrack({required this.tracks});
}

class PreviousTrack extends PlayerEvent {
  final List<TrackModel> tracks;
  PreviousTrack({required this.tracks});
}

class SeekTo extends PlayerEvent {
  final Duration position;
  SeekTo(this.position);
}

class UpdatePosition extends PlayerEvent {
  final Duration position;
  UpdatePosition(this.position);
}

class ToggleFavorite extends PlayerEvent {
  final TrackModel track;
  ToggleFavorite(this.track);
}

class PlayerStateChanged extends PlayerEvent {
  final bool isPlaying;

  PlayerStateChanged(this.isPlaying);
}

class ToggleRepeat extends PlayerEvent {}

class ToggleShuffle extends PlayerEvent {}
