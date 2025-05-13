import '../models/track_model.dart';

abstract class ITrackRepository {
  Future<List<TrackModel>> getTopTracks();
  Future<List<TrackModel>> searchTracks(String query);
  Future<TrackModel> getTrackDetails(String trackId);
  Future<String> getStreamUrl(String trackId);
}
