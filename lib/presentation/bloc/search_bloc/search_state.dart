part of 'search_bloc.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchSuccess extends SearchState {
  final List<TrackModel> tracks;
  SearchSuccess(this.tracks);
}

class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}
