import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../core/models.dart';

class YouTubeService {
  final _yt = YoutubeExplode();

  Future<List<MusicTrack>> searchTracks(String query) async {
    try {
      final results = await _yt.search.search(query);
      return results.map((video) {
        return MusicTrack(
          id: video.id.value,
          title: video.title,
          artist: video.author,
          thumbnailUrl: video.thumbnails.mediumResUrl,
          duration: video.duration,
        );
      }).toList();
    } catch (e) {
      print("YouTube search error: $e");
      return [];
    }
  }

  Future<List<MusicTrack>> getTrendingTracks() async {
    return searchTracks("Tendances musique 2024");
  }

  Future<String> getAudioUrl(String videoId) async {
    try {
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      final streamInfo = manifest.audioOnly.withHighestBitrate();
      return streamInfo.url.toString();
    } catch (e) {
      print("YouTube stream extraction error: $e");
      throw Exception("Impossible d'extraire le flux audio.");
    }
  }

  void dispose() {
    _yt.close();
  }
}
