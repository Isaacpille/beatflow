import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/home/home_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/library/library_screen.dart';
import '../../features/player/mini_player.dart';

final navigationProvider = StateProvider<int>((ref) => 0);

class MainNavigationWrapper extends ConsumerWidget {
  const MainNavigationWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationProvider);
    
    final screens = [
      const HomeScreen(),
      const SearchScreen(),
      const LibraryScreen(),
      const Center(child: Text("Compte (Bientôt)")), // Placeholder for Auth
    ];

    return Scaffold(
      extendBody: true, // Important for glassmorphism
      body: Stack(
        children: [
          screens[selectedIndex],
          Positioned(
            left: 0,
            right: 0,
            bottom: kBottomNavigationBarHeight + 10,
            child: const MiniPlayer(),
          ),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: selectedIndex,
              onTap: (index) => ref.read(navigationProvider.notifier).state = index,
              backgroundColor: Colors.transparent, // Transparent to see the blur
              selectedFontSize: 12,
              unselectedFontSize: 12,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_filled), label: 'Accueil'),
                BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Recherche'),
                BottomNavigationBarItem(icon: Icon(Icons.library_music_outlined), activeIcon: Icon(Icons.library_music), label: 'Bibliothèque'),
                BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Compte'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
