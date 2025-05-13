import 'package:audius_music_player/data/models/track_model.dart';
import 'package:audius_music_player/data/repositories/audius_repositor.dart';
import 'package:audius_music_player/data/repositories/i_track_repository.dart';
import 'package:audius_music_player/data/repositories/offline_repository.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class HybridTrackRepository implements ITrackRepository {
  final AudiusRepository online;
  final OfflineRepository offline;

  HybridTrackRepository({required this.online, required this.offline});

  Future<bool> get _isConnected async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  @override
  Future<List<TrackModel>> getTopTracks() async {
    return await _isConnected ? online.getTopTracks() : offline.getTopTracks();
  }

  @override
  Future<List<TrackModel>> searchTracks(String query) async {
    return await _isConnected
        ? online.searchTracks(query)
        : offline.searchTracks(query);
  }

  @override
  Future<TrackModel> getTrackDetails(String trackId) async {
    return await _isConnected
        ? online.getTrackDetails(trackId)
        : offline.getTrackDetails(trackId);
  }

  @override
  Future<String> getStreamUrl(String trackId) async {
    if (await _isConnected) {
      return online.getStreamUrl(trackId);
    } else {
      throw Exception('Нет подключения к интернету');
    }
  }
}
