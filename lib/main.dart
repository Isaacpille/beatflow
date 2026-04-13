import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_service/audio_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'ui/theme/app_theme.dart';
import 'ui/widgets/navigation_wrapper.dart';
import 'services/audio_handler.dart';
import 'services/audio_service.dart';
import 'features/auth/auth_repository.dart';
import 'features/auth/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase initialization error: $e");
  }

  final authRepo = AuthRepository();

  if (!kIsWeb) {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    );
  }

  BeatFlowAudioHandler? audioHandler;
  try {
    audioHandler = await AudioService.init(
      builder: () => BeatFlowAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
        androidNotificationChannelName: 'Audio playback',
        androidNotificationOngoing: true,
        fastForwardInterval: Duration(seconds: 10),
        rewindInterval: Duration(seconds: 10),
      ),
    );
  } catch (e) {
    debugPrint("AudioService init error: $e");
    audioHandler = BeatFlowAudioHandler(); 
  }

  runApp(
    ProviderScope(
      overrides: [
        audioHandlerProvider.overrideWithValue(audioHandler),
        authRepositoryProvider.overrideWithValue(authRepo),
      ],
      child: const BeatFlowApp(),
    ),
  );
}

class BeatFlowApp extends ConsumerWidget {
  const BeatFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'BeatFlow',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: authState.when(
        data: (user) => user == null ? const LoginScreen() : const MainNavigationWrapper(),
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, st) => Scaffold(body: Center(child: Text('Erreur: $e'))),
      ),
    );
  }
}
