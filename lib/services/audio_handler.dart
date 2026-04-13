import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'cache_service.dart';
import '../core/models.dart';

class BeatFlowAudioHandler extends BaseAudioHandler with SeekHandler {
  final _player = AudioPlayer();
  final _cache = CacheService();

  BeatFlowAudioHandler() {
    _player.playbackEventStream.map(_transformEvent).listen(playbackState.add);
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() => _player.stop();

  // Position stream for UI progress bars
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.rewind,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.fastForward,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
    );
  }

  Future<void> loadTrack(String url, {String? mediaId, String? title, String? artist}) async {
    try {
      final source = AudioSource.uri(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1',
        },
        tag: MediaItem(
          id: mediaId ?? url,
          album: "BeatFlow Premium",
          title: title ?? "Titre inconnu",
          artist: artist ?? "Artiste inconnu",
          artUri: Uri.parse("https://github.com/Isaacpille/beatflow/raw/main/assets/icon.png"), // Placeholder
        ),
      );
      await _player.setAudioSource(source);
      mediaItem.add(source.tag as MediaItem);
    } catch (e) {
      print("Audio load error: $e");
    }
  }

  // Implementation of auto-download logic
  Future<void> startDownload(MusicTrack track) async {
     try {
       print("Auto-downloading: ${track.title}...");
       final path = await _cache.downloadTrack(track);
       print("Downloaded to: $path");
     } catch (e) {
       print("Download error for ${track.title}: $e");
     }
  }
}
