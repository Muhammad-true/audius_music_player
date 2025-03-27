import 'package:audius_music_player/data/models/track_model.dart';
import 'package:audius_music_player/data/services/storage_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/audius_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

// BLoC для управления поиском
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final AudiusRepository repository;
  final StorageService storageService;
  List<TrackModel> _playlist = [];

  SearchBloc({required this.storageService, required this.repository})
      : super(SearchInitial()) {
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

    emit(SearchLoading(TrackModel(
        id: '',
        title: '',
        artistName: '',
        coverArt: '',
        audioUrl: '',
        duration: 0)));
    try {
      final tracks = await repository.searchTracks(event.query);
      _playlist = await Future.wait(tracks.map((track) async {
        final isFavorite = await storageService.isTrackFavorite(track.id);
        return track.copyWith(isFavorite: isFavorite);
      }));
      emit(SearchSuccess(_playlist));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  void _onClearSearch(ClearSearch event, Emitter<SearchState> emit) {
    emit(SearchInitial());
  }
}
