part of 'search_bloc.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<TrackModel> playlist;
  final List<TrackModel> playlistMonth;

  const SearchLoaded(this.playlist, this.playlistMonth);

  @override
  List<Object?> get props => [playlist, playlistMonth];
}

class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object?> get props => [message];
}
