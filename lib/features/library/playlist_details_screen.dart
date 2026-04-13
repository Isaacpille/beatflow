import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/library_service.dart';
import '../../services/audio_service.dart';
import '../../core/models.dart';
import '../../ui/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlaylistDetailsScreen extends ConsumerWidget {
  final MusicPlaylist playlist;
  const PlaylistDetailsScreen({super.key, required this.playlist});

  void _showRenameDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: playlist.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Renommer la playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nouveau nom'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(libraryProvider).renamePlaylist(playlist.id, controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Renommer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch track details for each ID in playlist.trackIds
    final tracksAsync = FutureProvider((ref) async {
      if (playlist.trackIds.isEmpty) return <MusicTrack>[];
      final snapshots = await Future.wait(
        playlist.trackIds.map((id) => FirebaseFirestore.instance.collection('tracks').doc(id).get())
      );
      return snapshots.where((s) => s.exists).map((s) => MusicTrack.fromMap(s.data()!)).toList();
    });

    final tracks = ref.watch(tracksAsync);

    return Scaffold(
      appBar: AppBar(
        title: Text(playlist.name),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: () => _showRenameDialog(context, ref)),
          IconButton(icon: const Icon(Icons.delete_outline), onPressed: () {
            // TODO: Delete playlist
          }),
        ],
      ),
      body: tracks.when(
        data: (list) => list.isEmpty 
          ? const Center(child: Text('Cette playlist est vide.'))
          : ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final track = list[index];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(track.thumbnailUrl, width: 50, height: 50, fit: BoxFit.cover),
                ),
                title: Text(track.title),
                subtitle: Text(track.artist),
                onTap: () => ref.read(playerProvider.notifier).playTrack(track),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => ref.read(libraryProvider).removeTrackFromPlaylist(playlist.id, track.id),
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
