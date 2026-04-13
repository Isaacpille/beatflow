import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/mock_data.dart';
import '../../services/audio_service.dart';
import '../../ui/theme/app_theme.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../../services/youtube_service.dart';
import '../../core/models.dart';

final trendingProvider = FutureProvider((ref) => YouTubeService().getTrendingTracks());

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final trendingAsync = ref.watch(trendingProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.backgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Text(
                'Salut, ${user?.displayName ?? 'Ami'} 👋',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tendances de la semaine', 
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 16),
                  trendingAsync.when(
                    data: (tracks) => SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: tracks.length,
                        itemBuilder: (context, index) => _TrendCard(track: tracks[index]),
                      ),
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Erreur: $e'),
                  ),
                ],
              ),
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverToBoxAdapter(
              child: Text('Tes sons favoris', 
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final track = MockData.trendingTracks[index % MockData.trendingTracks.length];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(track.thumbnailUrl, width: 50, height: 50, fit: BoxFit.cover),
                  ),
                  title: Text(track.title),
                  subtitle: Text(track.artist),
                  onTap: () => ref.read(playerProvider.notifier).playTrack(track),
                );
              },
              childCount: 4,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _TrendCard extends ConsumerWidget {
  final MusicTrack track;
  const _TrendCard({required this.track});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(playerProvider.notifier).playTrack(track),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(track.thumbnailUrl, height: 150, width: 150, fit: BoxFit.cover),
            ),
            const SizedBox(height: 8),
            Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis, 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)
            ),
            Text(track.artist, maxLines: 1, overflow: TextOverflow.ellipsis, 
              style: const TextStyle(color: Colors.grey, fontSize: 12)
            ),
          ],
        ),
      ),
    );
  }
}
