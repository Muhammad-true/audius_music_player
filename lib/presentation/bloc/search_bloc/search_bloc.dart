import 'package:audius_music_player/data/models/track_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/audius_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

// BLoC для управления поиском
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final AudiusRepository repository;

  SearchBloc(this.repository) : super(SearchInitial()) {
    on<SearchTracks>(_onSearchTracks);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onSearchTracks(
    SearchTracks event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());
    try {
      final tracks = await repository.searchTracks(event.query);
      emit(SearchSuccess(tracks));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  void _onClearSearch(ClearSearch event, Emitter<SearchState> emit) {
    emit(SearchInitial());
  }
}
