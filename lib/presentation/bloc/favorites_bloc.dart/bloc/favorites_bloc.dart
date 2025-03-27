import 'package:audius_music_player/data/models/track_model.dart';
import 'package:audius_music_player/data/repositories/audius_repository.dart';
import 'package:audius_music_player/data/services/storage_service.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final StorageService storageService;
  final AudiusRepository repository;

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
    print('Favorites: $favorites');
    final track = await getFavoriteTracksWithDetails(favorites);
    emit(FavoritesLoaded(track));
  }

  // Получение списка избранных треков
  Future<List<TrackModel>> getFavoriteTracksWithDetails(
      Set<String> favoriteIds) async {
    List<TrackModel> favoriteTracks = [];
    for (var trackId in favoriteIds) {
      // Запрашиваем полные данные о треке по его ID
      TrackModel track = await repository.getTrackDetails(trackId);
      favoriteTracks.add(track);
    }

    return favoriteTracks;
  }
}
