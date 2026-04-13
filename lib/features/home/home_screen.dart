import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/mock_data.dart';
import '../../services/audio_service.dart';
import '../../ui/theme/app_theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour, Isaac';
    if (hour < 18) return 'Bon après-midi, Isaac';
    return 'Bonsoir, Isaac';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.withOpacity(0.2),
              AppTheme.backgroundColor,
            ],
            stops: const [0.0, 0.4],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: false,
              backgroundColor: Colors.transparent,
              actions: [
                IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
                IconButton(icon: const Icon(Icons.history), onPressed: () {}),
                IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
              ],
              title: Text(_getGreeting(), 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)
              ),
            ),
            
            // Grid of favorites (Recently played style)
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final track = MockData.trendingTracks[index % MockData.trendingTracks.length];
                    return Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(4)),
                            child: Image.network(track.thumbnailUrl, width: 56, height: 56, fit: BoxFit.cover),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(track.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    );
                  },
                  childCount: 6, // Mock "Recently Played"
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.only(left: 16, top: 24, bottom: 8),
              sliver: SliverToBoxAdapter(
                child: Text('Vos favoris', 
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)
                ),
              ),
            ),

            // Horizontal List
            SliverToBoxAdapter(
              child: SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: MockData.trendingTracks.length,
                  itemBuilder: (context, index) {
                    final track = MockData.trendingTracks[index];
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
                            Text(track.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1),
                            Text(track.artist, style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom spacing
          ],
        ),
      ),
    );
  }
}
