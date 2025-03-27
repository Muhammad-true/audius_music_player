part of 'search_bloc.dart';

abstract class SearchEvent {}

class SearchTracks extends SearchEvent {
  final String query;

  SearchTracks(this.query);
}

class ClearSearch extends SearchEvent {}
