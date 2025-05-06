import 'package:audius_music_player/data/models/track_model.dart';
import 'package:audius_music_player/data/repositories/jamendoRepositor.dart';
import 'package:audius_music_player/data/services/storage_service.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final StorageService storageService;
  final JamendoRepository repository;

  FavoritesBloc({required this.storageService, required this.repository})
      : super(FavoritesInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(FavoritesLoading());
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
              isFavorite: true); // Ensure this returns TrackModel
        } catch (e) {
          return TrackModel.empty(); // Return an empty TrackModel
        }
      }),
    );

    // Filter null values if any requests failed
    return favoriteTracks
        .whereType<TrackModel>()
        .toList(); // Ensure this is List<TrackModel>
  }
}
