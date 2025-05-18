part of 'search_bloc.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<TrackModel> searchTracks;
  final List<TrackModel> getTopTracks;
  final List<TrackModel> getUndergroundTrendingTracks;

  const SearchLoaded(
      this.searchTracks, this.getTopTracks, this.getUndergroundTrendingTracks);

  @override
  List<Object?> get props =>
      [searchTracks, getTopTracks, getUndergroundTrendingTracks];
}

class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object?> get props => [message];
}
