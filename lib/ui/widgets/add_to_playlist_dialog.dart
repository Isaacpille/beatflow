import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/library_service.dart';
import '../../core/models.dart';
import '../../ui/theme/app_theme.dart';

class AddToPlaylistDialog extends ConsumerWidget {
  final MusicTrack track;
  const AddToPlaylistDialog({super.key, required this.track});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(userPlaylistsProvider);

    return AlertDialog(
      backgroundColor: AppTheme.surfaceColor,
      title: const Text('Ajouter à une playlist'),
      content: SizedBox(
        width: double.maxFinite,
        child: playlists.when(
          data: (list) => list.isEmpty 
            ? const Text('Aucune playlist trouvée. Créez-en une d\'abord !')
            : ListView.builder(
              shrinkWrap: true,
              itemCount: list.length,
              itemBuilder: (context, index) {
                final p = list[index];
                final alreadyIn = p.trackIds.contains(track.id);
                return ListTile(
                  title: Text(p.name),
                  trailing: Icon(alreadyIn ? Icons.check_circle : Icons.add_circle_outline, 
                    color: alreadyIn ? AppTheme.primaryColor : Colors.white),
                  onTap: () async {
                    if (!alreadyIn) {
                      await ref.read(libraryProvider).addTrackToPlaylist(p.id, track);
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Ajouté à ${p.name}'))
                      );
                    }
                  },
                );
              },
            ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Erreur: $e'),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer')),
      ],
    );
  }
}

void showAddToPlaylistDialog(BuildContext context, MusicTrack track) {
  showDialog(
    context: context,
    builder: (context) => AddToPlaylistDialog(track: track),
  );
}
