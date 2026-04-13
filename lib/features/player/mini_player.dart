import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/audio_service.dart';
import '../../ui/theme/app_theme.dart';

import '../../services/library_service.dart';
import '../../ui/widgets/add_to_playlist_dialog.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTrack = ref.watch(playerProvider);
    if (currentTrack == null) return const SizedBox.shrink();

    return Container(
      height: 64,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(currentTrack.thumbnailUrl, width: 44, height: 44, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(currentTrack.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text(currentTrack.artist, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            currentTrack.isLiked ? Icons.favorite : Icons.favorite_border,
                            color: currentTrack.isLiked ? AppTheme.primaryColor : Colors.white,
                            size: 20,
                          ),
                          onPressed: () => ref.read(libraryProvider).toggleLike(currentTrack),
                        ),
                        IconButton(
                          icon: const Icon(Icons.playlist_add, size: 20),
                          onPressed: () => showAddToPlaylistDialog(context, currentTrack),
                        ),
                        IconButton(
                          icon: const Icon(Icons.play_arrow), // Simplification: play/pause logic handled by playerProvider
                          onPressed: () => ref.read(playerProvider.notifier).togglePlay(),
                        ),
                      ],
                    ),
                  ),
                ),
                const _MiniPlayerProgress(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniPlayerProgress extends ConsumerWidget {
  const _MiniPlayerProgress();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider.notifier);
    final currentTrack = ref.watch(playerProvider);
    
    return StreamBuilder<Duration>(
      stream: player.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final total = currentTrack?.duration ?? const Duration(minutes: 3);
        
        return LinearProgressIndicator(
          value: total.inMilliseconds > 0 ? position.inMilliseconds / total.inMilliseconds : 0,
          backgroundColor: Colors.white10,
          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          minHeight: 2,
        );
      },
    );
  }
}
