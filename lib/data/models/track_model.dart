// Модель трека, которая будет использоваться для работы с API Audius
class TrackModel {
  final String id;
  final String title;
  final String artistName;
  final String coverArt;
  final String audioUrl;
  final int duration;
  final bool isFavorite;

  TrackModel({
    required this.id,
    required this.title,
    required this.artistName,
    required this.coverArt,
    required this.audioUrl,
    required this.duration,
    this.isFavorite = false,
  });

  // Преобразование JSON в модель
  factory TrackModel.fromJson(Map<String, dynamic> json) {
    final artwork = json['artwork'] ?? {};
    final user = json['user'] ?? {};

    return TrackModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      artistName: user['name'] ?? '',
      coverArt: artwork['480x480'] ?? artwork['150x150'] ?? '',
      audioUrl: json['stream_url'] ?? '',
      duration: json['duration'] ?? 0,
      isFavorite: false,
    );
  }

  TrackModel copyWith({
    String? id,
    String? title,
    String? artistName,
    String? coverArt,
    String? audioUrl,
    int? duration,
    bool? isFavorite,
  }) {
    return TrackModel(
      id: id ?? this.id,
      title: title ?? this.title,
      artistName: artistName ?? this.artistName,
      coverArt: coverArt ?? this.coverArt,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
