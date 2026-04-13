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
  final List<String> playlistIds;

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
    this.playlistIds = const [],
  });

  factory MusicTrack.fromMap(Map<String, dynamic> map) {
    return MusicTrack(
      id: map['id'] ?? '',
      title: map['title'] ?? 'Unknown Title',
      artist: map['artist'] ?? 'Unknown Artist',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      audioUrl: map['audioUrl'],
      localPath: map['localPath'],
      duration: map['duration'] != null ? Duration(milliseconds: map['duration']) : null,
      isDownloaded: map['isDownloaded'] ?? false,
      isLiked: map['isLiked'] ?? false,
      playlistIds: List<String>.from(map['playlistIds'] ?? []),
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
      'playlistIds': playlistIds,
    };
  }

  MusicTrack copyWith({
    bool? isDownloaded,
    bool? isLiked,
    String? localPath,
    String? audioUrl,
    List<String>? playlistIds,
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
      playlistIds: playlistIds ?? this.playlistIds,
    );
  }
}

class MusicPlaylist {
  final String id;
  final String name;
  final String ownerId;
  final List<String> trackIds;
  final DateTime createdAt;

  MusicPlaylist({
    required this.id,
    required this.name,
    required this.ownerId,
    this.trackIds = const [],
    required this.createdAt,
  });

  factory MusicPlaylist.fromMap(Map<String, dynamic> map, String docId) {
    return MusicPlaylist(
      id: docId,
      name: map['name'] ?? 'Ma Playlist',
      ownerId: map['ownerId'] ?? '',
      trackIds: List<String>.from(map['trackIds'] ?? []),
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'ownerId': ownerId,
      'trackIds': trackIds,
      'createdAt': createdAt,
    };
  }
}
