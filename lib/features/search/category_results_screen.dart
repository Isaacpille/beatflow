import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/youtube_service.dart';
import '../../services/audio_service.dart';

import '../../ui/theme/app_theme.dart';

class CategoryResultsScreen extends ConsumerWidget {
  final String categoryName;
  const CategoryResultsScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchAsync = FutureProvider((ref) => YouTubeService().searchTracks(categoryName));
    final results = ref.watch(searchAsync);

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        backgroundColor: AppTheme.backgroundColor,
      ),
      body: results.when(
        data: (tracks) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tracks.length,
          itemBuilder: (context, index) {
            final track = tracks[index];
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(track.thumbnailUrl, width: 50, height: 50, fit: BoxFit.cover),
              ),
              title: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(track.artist),
              onTap: () => ref.read(playerProvider.notifier).playTrack(track),
              trailing: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  // TODO: Add to playlist dialog
                },
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
      ),
    );
  }
}
