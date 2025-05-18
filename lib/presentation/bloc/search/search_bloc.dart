import 'package:audius_music_player/data/models/track_model.dart';
import 'package:audius_music_player/data/repositories/audius_repositor.dart';
import 'package:audius_music_player/data/services/storage_service.dart';
import 'package:audius_music_player/presentation/cubit/app_mode_cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final AudiusRepository repository;
  final StorageService storageService;
  final AppModeCubit appModeCubit;

  List<TrackModel> _searchTrack = [];

  SearchBloc({
    required this.repository,
    required this.storageService,
    required this.appModeCubit,
  }) : super(SearchInitial()) {
    on<LoadTrendingTracks>(_onLoadTrendingTracks);
    on<SearchTracks>(_onSearchTracks);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onLoadTrendingTracks(
      LoadTrendingTracks event, Emitter<SearchState> emit) async {
    emit(SearchLoading());

    final isOnline = appModeCubit.state.isOnline;
    if (!isOnline) {
      emit(const SearchError(
          'Вы не можете использовать эту страницу в офлайн-режиме.'));
      return;
    }

    try {
      final trendingTracks = await repository.getTopTracks();
      final favoriteStatuses = await Future.wait(
        trendingTracks.map((track) => storageService.isTrackFavorite(track.id)),
      );

      final enrichedTrendingTracks = List.generate(
        trendingTracks.length,
        (index) =>
            trendingTracks[index].copyWith(isFavorite: favoriteStatuses[index]),
      );

      // Можно заменить эту часть, если есть другая логика для _playlistMonth
      final getUndergroundTrendingTracks =
          await repository.getUndergroundTrendingTracks();

      emit(SearchLoaded(
          List.empty(), enrichedTrendingTracks, getUndergroundTrendingTracks));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  Future<void> _onSearchTracks(
      SearchTracks event, Emitter<SearchState> emit) async {
    if (event.query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());

    final isOnline = appModeCubit.state.isOnline;
    if (!isOnline) {
      emit(const SearchError(
          'Вы не можете использовать поиск в офлайн-режиме.'));
      return;
    }

    try {
      final tracks = await repository.searchTracks(event.query);
      _searchTrack = await Future.wait(
        tracks.map((track) async {
          final isFavorite = await storageService.isTrackFavorite(track.id);
          return track.copyWith(isFavorite: isFavorite);
        }),
      );
      emit(SearchLoaded(_searchTrack, List.empty(), List.empty()));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  void _onClearSearch(ClearSearch event, Emitter<SearchState> emit) {
    emit(SearchInitial());
  }
}
