import 'dart:convert';

class TrackModel {
  final String id;
  final String title;
  final String artistName;
  final String coverArt;
  final String audioUrl;
  final int duration;
  final bool isFavorite;
  final bool canDownload;

  TrackModel({
    required this.id,
    required this.title,
    required this.artistName,
    required this.coverArt,
    required this.audioUrl,
    required this.duration,
    this.isFavorite = false,
    this.canDownload = true,
  });

  // Static method to create an empty TrackModel
  static TrackModel empty() {
    return TrackModel(
        id: '',
        title: '',
        artistName: '',
        coverArt: '',
        audioUrl: '',
        duration: 0,
        isFavorite: false,
        canDownload: true);
  }

  factory TrackModel.fromJson(Map<String, dynamic> json) {
    return TrackModel(
      id: json['id'].toString(),
      title: json['name'] ?? '',
      artistName: json['artist_name'] ?? '',
      coverArt: json['album_image'] ?? '',
      audioUrl: json['audio'] ?? '',
      duration: json['duration'] ?? 0,
      isFavorite: false,
      canDownload: json['is_streamable'] ?? true,
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
    bool? canDownload,
  }) {
    return TrackModel(
      id: id ?? this.id,
      title: title ?? this.title,
      artistName: artistName ?? this.artistName,
      coverArt: coverArt ?? this.coverArt,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      isFavorite: isFavorite ?? this.isFavorite,
      canDownload: canDownload ?? this.canDownload,
    );
  }

  // Метод для преобразования объекта TrackModel в Map (для JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist_name': artistName,
      'album_image': coverArt,
      'audio': audioUrl,
      'duration': duration,
      'isFavorite': isFavorite,
      'is_streamable': canDownload,
    };
  }

  // Метод для преобразования объекта TrackModel в строку JSON
  String toJsonString() => jsonEncode(toJson());

  // Метод для десериализации строки JSON обратно в объект TrackModel
  static TrackModel fromJsonString(String jsonString) {
    return TrackModel.fromJson(jsonDecode(jsonString));
  }
}
