import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'audio_handler.dart';
import 'youtube_service.dart';
import '../core/models.dart';
import 'package:audio_service/audio_service.dart';

final audioHandlerProvider = Provider<BeatFlowAudioHandler>((ref) => throw UnimplementedError());

final playerProvider = StateNotifierProvider<PlayerNotifier, MusicTrack?>((ref) {
  return PlayerNotifier(ref.watch(audioHandlerProvider), YouTubeService());
});

class PlayerNotifier extends StateNotifier<MusicTrack?> {
  final BeatFlowAudioHandler _handler;
  final YouTubeService _yt;

  PlayerNotifier(this._handler, this._yt) : super(null);

  Stream<Duration> get positionStream => _handler.playbackState.map((state) => state.position).distinct();
  Stream<bool> get playingStream => _handler.playbackState.map((state) => state.playing).distinct();

  Future<void> playTrack(MusicTrack track) async {
    state = track;
    // For auto-download: if localPath exists, use it.
    String url = track.localPath ?? track.audioUrl ?? await _yt.getAudioUrl(track.id);
    
    // Update state with URL if it was just fetched
    if (track.audioUrl == null && track.localPath == null) {
      state = track.copyWith(audioUrl: url);
    }

    await _handler.loadTrack(url, mediaId: track.id, title: track.title, artist: track.artist);
    _handler.play();

    // Trigger auto-download if playing for the first time
    if (!track.isDownloaded) {
      _handler.startDownload(track); 
    }
  }

  void togglePlay() {
    if (_handler.playbackState.value.playing) {
      _handler.pause();
    } else {
      _handler.play();
    }
  }

  void toggleLike() {
    if (state != null) {
      state = state!.copyWith(isLiked: !state!.isLiked);
      // Here we would also sync to Firebase in the future
      if (state!.isLiked && !state!.isDownloaded) {
         _handler.startDownload(state!);
      }
    }
  }
}
