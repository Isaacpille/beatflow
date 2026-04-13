import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/audio_service.dart';
import '../../services/youtube_service.dart';
import '../../core/models.dart';

final searchResultsProvider = FutureProvider.family<List<MusicTrack>, String>((ref, query) async {
  if (query.isEmpty) return [];
  return YouTubeService().searchTracks(query);
});

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider(_query));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 120,
            flexibleSpace: const FlexibleSpaceBar(
              title: Text('Recherche', style: TextStyle(fontWeight: FontWeight.bold)),
              centerTitle: false,
              titlePadding: EdgeInsets.only(left: 16, bottom: 60),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  onSubmitted: (value) => setState(() => _query = value),
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Colors.black),
                    hintText: 'Que souhaitez-vous écouter ?',
                    hintStyle: const TextStyle(color: Colors.black54),
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          if (_query.isEmpty)
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tout parcourir', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.6,
                      children: [
                        _CategoryCard('Musique', Colors.pink),
                        _CategoryCard('Podcasts', Colors.teal),
                        _CategoryCard('Événements', Colors.purple),
                        _CategoryCard('Conçus pour vous', Colors.blue),
                        _CategoryCard('Nouveautés', Colors.orange),
                        _CategoryCard('Pop', Colors.indigo),
                      ],
                    ),
                  ],
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: searchResults.when(
                data: (tracks) {
                  if (tracks.isEmpty) return const Center(child: Padding(padding: EdgeInsets.only(top: 100), child: Text('Aucun résultat trouvé.')));
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
                      );
                    },
                  );
                },
                loading: () => const Center(child: Padding(padding: EdgeInsets.only(top: 100), child: CircularProgressIndicator())),
                error: (err, stack) => Center(child: Text('Erreur: $err')),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final Color color;
  const _CategoryCard(this.title, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}
