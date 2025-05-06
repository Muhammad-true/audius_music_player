import 'package:audius_music_player/data/models/track_model.dart';
import 'package:audius_music_player/data/services/storage_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/jamendoRepositor.dart';

part 'search_event.dart';
part 'search_state.dart';

// BLoC для управления поиском
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final JamendoRepository repository;
  final StorageService storageService;
  List<TrackModel> _playlist = [];

  SearchBloc({required this.storageService, required this.repository})
      : super(SearchInitial()) {
    on<LoadTrendingTracks>(_onLoadTrendingTracks);
    on<SearchTracks>(_onSearchTracks);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onLoadTrendingTracks(
      LoadTrendingTracks event, Emitter<SearchState> emit) async {
    emit(SearchLoading());
    try {
      final tracks = await repository.getTopTracks();
      final favoriteStatuses = await Future.wait(
        tracks.map((track) => storageService.isTrackFavorite(track.id)),
      );
      final _playlist = List.generate(
          tracks.length,
          (index) =>
              tracks[index].copyWith(isFavorite: favoriteStatuses[index]));

      final tracksDownloadMonth = await repository.getTopTracks();
      final favoriteStatusesMonth = await Future.wait(
        tracksDownloadMonth
            .map((track) => storageService.isTrackFavorite(track.id)),
      );
      final _playlistMonth = List.generate(
          tracksDownloadMonth.length,
          (index) => tracksDownloadMonth[index]
              .copyWith(isFavorite: favoriteStatusesMonth[index]));

      emit(SearchLoaded(_playlist, _playlistMonth));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
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
      _playlist = await Future.wait(tracks.map((track) async {
        final isFavorite = await storageService.isTrackFavorite(track.id);
        return track.copyWith(isFavorite: isFavorite);
      }));
      emit(SearchLoaded(_playlist, List.empty()));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  void _onClearSearch(ClearSearch event, Emitter<SearchState> emit) {
    emit(SearchInitial());
  }
}
