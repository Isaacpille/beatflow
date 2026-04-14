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
  
  runApp(
    const ProviderScope(
      child: BeatFlowApp(),
    ),
  );
}

class BeatFlowApp extends ConsumerStatefulWidget {
  const BeatFlowApp({super.key});

  @override
  ConsumerState<BeatFlowApp> createState() => _BeatFlowAppState();
}

class _BeatFlowAppState extends ConsumerState<BeatFlowApp> {
  bool _isInitialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // 1. Firebase
      await Firebase.initializeApp();

      // 2. Audio Background
      if (!kIsWeb) {
        await JustAudioBackground.init(
          androidNotificationChannelId: 'com.isaac.beatflow.audio',
          androidNotificationChannelName: 'Audio playback',
          androidNotificationOngoing: true,
        );
      }

      // 3. Audio Service
      final audioHandler = await AudioService.init(
        builder: () => BeatFlowAudioHandler(),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.isaac.beatflow.audio',
          androidNotificationChannelName: 'Audio playback',
          androidNotificationOngoing: true,
        ),
      );

      // Save audioHandler in the provider
      ref.read(audioHandlerProvider.notifier).state = audioHandler;

      setState(() {
        _isInitialized = true;
      });
    } catch (e, stackTrace) {
      debugPrint("INITIALIZATION ERROR: $e");
      debugPrint("STACK TRACE: $stackTrace");
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SelectableText(
                'ERREUR DE DÉMARRAGE :\n\n$_error',
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return const MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: CircularProgressIndicator(color: Colors.purple),
          ),
        ),
      );
    }

    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'BeatFlow',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: authState.when(
        data: (user) => user == null ? const LoginScreen() : const MainNavigationWrapper(),
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, st) => Scaffold(body: Center(child: Text('Erreur Auth: $e'))),
      ),
    );
  }
}
