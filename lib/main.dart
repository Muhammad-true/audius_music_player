import 'package:audius_music_player/core/theme/app_theme.dart';
import 'package:audius_music_player/data/repositories/audius_repository.dart';
import 'package:audius_music_player/data/services/storage_service.dart';
import 'package:audius_music_player/presentation/bloc/favorites_bloc.dart/bloc/favorites_bloc.dart';
import 'package:audius_music_player/presentation/bloc/player_bloc/player_bloc.dart';
import 'package:audius_music_player/presentation/bloc/search_bloc/search_bloc.dart';
import 'package:audius_music_player/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);

  // Инициализация репозитория
  final repository = AudiusRepository();
  await repository.initialize();

  final audioPlayer = AudioPlayer();

  runApp(MyApp(
    storageService: storageService,
    repository: repository,
    audioPlayer: audioPlayer,
  ));
}

/// Главный виджет приложения
class MyApp extends StatelessWidget {
  final StorageService storageService;
  final AudiusRepository repository;
  final AudioPlayer audioPlayer;

  const MyApp({
    required this.storageService,
    required this.repository,
    required this.audioPlayer,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => PlayerBloc(
              repository: repository,
              storageService: storageService,
              audioPlayer: audioPlayer,
            )..add(LoadTrendingTracks()),
          ),
          BlocProvider(
            create: (context) => SearchBloc(
              storageService: storageService,
              repository: repository,
            ),
          ),
          BlocProvider(
              create: (context) => FavoritesBloc(
                  storageService: storageService, repository: repository))
        ],
        child: MaterialApp(
          title: 'Audius Music Player',
          theme: AppTheme.lightTheme,
          home: HomePage(),
        ));
  }
}

/// Виджет для отображения ошибок при запуске
class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({required this.error, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Error initializing app',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(error, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Phoenix.rebirth(context),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Логирование событий BLoC (полезно для дебага)
class SimpleBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    print('BLoC Event: $event');
    super.onEvent(bloc, event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    print('BLoC Transition: $transition');
    super.onTransition(bloc, transition);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('BLoC Error: $error');
    print(stackTrace);
    super.onError(bloc, error, stackTrace);
  }
}
