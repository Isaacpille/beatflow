import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/library_service.dart';
import '../../core/models.dart';
import '../../ui/theme/app_theme.dart';
import 'playlist_details_screen.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  void _showCreatePlaylistDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Nouvelle playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nom de la playlist'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(libraryProvider).createPlaylist(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likedSongs = ref.watch(likedSongsProvider);
    final playlists = ref.watch(userPlaylistsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bibliothèque', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => _showCreatePlaylistDialog(context, ref)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          likedSongs.when(
            data: (songs) => _buildLibraryItem(
              icon: Icons.favorite,
              color: AppTheme.primaryColor,
              title: 'Titres likés',
              subtitle: 'Playlist • ${songs.length} titres',
              onTap: () {
                // Navigate to a temporary details view or reusing PlaylistDetails for Liked
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PlaylistDetailsScreen(
                    playlist: MusicPlaylist(
                      id: 'liked',
                      name: 'Titres likés',
                      ownerId: 'system',
                      trackIds: songs.map((s) => s.id).toList(),
                      createdAt: DateTime.now(),
                    ),
                  )),
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Erreur: $e'),
          ),
          const SizedBox(height: 24),
          const Text('Tes Playlists', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          playlists.when(
            data: (list) => Column(
              children: list.map((p) => _buildLibraryItem(
                icon: Icons.music_note,
                color: Colors.blue,
                title: p.name,
                subtitle: 'Playlist • ${p.trackIds.length} titres',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PlaylistDetailsScreen(playlist: p)),
                  );
                },
              )).toList(),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Erreur: $e'),
          ),
        ],
      ),
    );
  }

  Widget _buildLibraryItem({
    required IconData icon, 
    required Color color, 
    required String title, 
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
