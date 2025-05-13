part of 'search_bloc.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class LoadTrendingTracks extends SearchEvent {}

class SearchTracks extends SearchEvent {
  final String query;

  const SearchTracks(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearSearch extends SearchEvent {}
