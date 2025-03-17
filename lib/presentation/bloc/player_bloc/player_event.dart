part of 'player_bloc.dart';

// События для управления плеером
abstract class PlayerEvent {}

class LoadTrendingTracks extends PlayerEvent {}

class SearchTracks extends PlayerEvent {
  final String query;
  SearchTracks(this.query);
}

class PlayTrack extends PlayerEvent {
  final TrackModel track;
  PlayTrack(this.track);
}

class PauseTrack extends PlayerEvent {}

class ResumeTrack extends PlayerEvent {}

class NextTrack extends PlayerEvent {}

class PreviousTrack extends PlayerEvent {}

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
