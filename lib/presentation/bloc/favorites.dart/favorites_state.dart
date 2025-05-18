part of 'favorites_bloc.dart';

sealed class FavoritesState {}

final class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<TrackModel> favorites; // Assuming this is a Set

  FavoritesLoaded(this.favorites);
// Getter to convert Set to List
}

class FavoritesError extends FavoritesState {
  final String message;

  FavoritesError({required this.message});
}
