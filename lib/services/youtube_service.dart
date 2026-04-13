import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../core/models.dart';

class YouTubeService {
  final _yt = YoutubeExplode();

  Future<List<MusicTrack>> searchTracks(String query) async {
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
  }

  Future<String> getAudioUrl(String videoId) async {
    final manifest = await _yt.videos.streamsClient.getManifest(videoId);
    final streamInfo = manifest.audioOnly.withHighestBitrate();
    return streamInfo.url.toString();
  }

  void dispose() {
    _yt.close();
  }
}
