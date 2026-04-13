import 'package:flutter/material.dart';
import '../../ui/theme/app_theme.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bibliothèque'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildLibraryItem(
            icon: Icons.favorite,
            color: AppTheme.primaryColor,
            title: 'Titres likés',
            subtitle: 'Playlist • 0 titres',
          ),
          const SizedBox(height: 16),
          _buildLibraryItem(
            icon: Icons.download_done,
            color: Colors.green,
            title: 'Téléchargements',
            subtitle: 'Musique hors-ligne',
          ),
          const SizedBox(height: 16),
          _buildLibraryItem(
            icon: Icons.person,
            color: Colors.grey,
            title: 'Artistes',
            subtitle: 'Artistes suivis',
          ),
        ],
      ),
    );
  }

  Widget _buildLibraryItem({required IconData icon, required Color color, required String title, required String subtitle}) {
    return Row(
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
    );
  }
}
