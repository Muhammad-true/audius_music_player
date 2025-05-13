import 'package:audius_music_player/data/models/track_model.dart';
import 'package:audius_music_player/data/repositories/i_track_repository.dart';
import 'package:audius_music_player/data/services/storage_service.dart';

class OfflineRepository implements ITrackRepository {
  final StorageService storageService;

  OfflineRepository(this.storageService);

  @override
  Future<List<TrackModel>> getTopTracks() async {
    return await storageService.getDownloadedTracks();
  }

  @override
  Future<List<TrackModel>> searchTracks(String query) async {
    // офлайн-поиск (например, по названию или артисту)
    final all = await storageService.getDownloadedTracks();
    return all
        .where((t) =>
            t.title.toLowerCase().contains(query.toLowerCase()) ||
            t.artistName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<TrackModel> getTrackDetails(String trackId) async {
    final all = await storageService.getDownloadedTracks();
    return all.firstWhere((t) => t.id == trackId);
  }

  @override
  Future<String> getStreamUrl(String trackId) {
    throw UnimplementedError('Оффлайн поток не поддерживается');
  }
}
