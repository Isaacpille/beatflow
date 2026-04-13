class MusicTrack {
  final String id;
  final String title;
  final String artist;
  final String thumbnailUrl;
  final String? audioUrl;
  final String? localPath;
  final Duration? duration;
  final bool isDownloaded;
  final bool isLiked;

  MusicTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.thumbnailUrl,
    this.audioUrl,
    this.localPath,
    this.duration,
    this.isDownloaded = false,
    this.isLiked = false,
  });

  factory MusicTrack.fromMap(Map<String, dynamic> map) {
    return MusicTrack(
      id: map['id'],
      title: map['title'],
      artist: map['artist'],
      thumbnailUrl: map['thumbnailUrl'],
      audioUrl: map['audioUrl'],
      localPath: map['localPath'],
      duration: map['duration'] != null ? Duration(milliseconds: map['duration']) : null,
      isDownloaded: map['isDownloaded'] ?? false,
      isLiked: map['isLiked'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'thumbnailUrl': thumbnailUrl,
      'audioUrl': audioUrl,
      'localPath': localPath,
      'duration': duration?.inMilliseconds,
      'isDownloaded': isDownloaded,
      'isLiked': isLiked,
    };
  }

  MusicTrack copyWith({
    bool? isDownloaded,
    bool? isLiked,
    String? localPath,
    String? audioUrl,
  }) {
    return MusicTrack(
      id: id,
      title: title,
      artist: artist,
      thumbnailUrl: thumbnailUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      localPath: localPath ?? this.localPath,
      duration: duration,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
