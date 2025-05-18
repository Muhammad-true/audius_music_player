import 'package:audius_music_player/data/models/track_model.dart';
import 'package:audius_music_player/data/repositories/audius_repositor.dart';
import 'package:audius_music_player/data/services/storage_service.dart';
import 'package:audius_music_player/presentation/cubit/app_mode_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final StorageService storageService;
  final AudiusRepository repository;
  final AppModeCubit appModeCubit;

  FavoritesBloc({
    required this.storageService,
    required this.repository,
    required this.appModeCubit,
  }) : super(FavoritesInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<RemoveFromFavorites>(_onRemoveFromFavorites);
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(FavoritesLoading());
    final isOnline = appModeCubit.state.isOnline;
    if (!isOnline) {
      emit(FavoritesError(
          message: 'Вы не можете увидеть избрание треки без интернета'));
      return;
    }
    final favorites = await storageService.getFavoriteTracks();
    final track = await getFavoriteTracksWithDetails(favorites);
    emit(FavoritesLoaded(track));
  }

  // Получение списка избранных треков
  Future<List<TrackModel>> getFavoriteTracksWithDetails(
      Set<String> favoriteIds) async {
    List<TrackModel> favoriteTracks = await Future.wait(
      favoriteIds.map((trackId) async {
        try {
          final track = await repository.getTrackDetails(trackId);
          return track.copyWith(
              isFavorite: true, canDownload: track.canDownload);
        } catch (e) {
          return TrackModel.empty();
        }
      }),
    );

    return favoriteTracks
        .whereType<TrackModel>()
        .toList(); // Ensure this is List<TrackModel>
  }

  //удалим трек от списка избранных
  Future<void> _onRemoveFromFavorites(
    RemoveFromFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    if (state is FavoritesLoaded) {
      final currentState = state as FavoritesLoaded;

      // Удалить из storage
      await storageService.removeFavoriteTrack(event.track.id);

      // Обновить список без удалённого трека
      final updatedTracks = List<TrackModel>.from(currentState.favorites)
        ..removeWhere((track) => track.id == event.track.id);

      emit(FavoritesLoaded(updatedTracks));
    }
  }
}
