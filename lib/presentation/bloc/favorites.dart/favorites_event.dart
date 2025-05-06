part of 'favorites_bloc.dart';

abstract class FavoritesEvent {}

class LoadFavorites extends FavoritesEvent {}

class ToggleFavorite extends FavoritesEvent {
  final TrackModel track;
  ToggleFavorite(this.track);
}
