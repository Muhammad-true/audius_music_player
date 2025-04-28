import 'package:audius_music_player/core/theme/app_theme.dart';
import 'package:audius_music_player/data/repositories/jamendoRepositor.dart';
import 'package:audius_music_player/data/services/storage_service.dart';
import 'package:audius_music_player/presentation/bloc/favorites_bloc.dart/bloc/favorites_bloc.dart';
import 'package:audius_music_player/presentation/bloc/player_bloc/player_bloc.dart';
import 'package:audius_music_player/presentation/bloc/search_bloc/search_bloc.dart';
import 'package:audius_music_player/router/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  String clientId = dotenv.env['CLIENT_ID'] ?? '';
  // Инициализация SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);

  // Инициализация репозитория
  final repository = JamendoRepository();
  await repository.initialize(clientId);

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
  final JamendoRepository repository;
  final AudioPlayer audioPlayer;
  final _appRouter = AppRouter();

  MyApp({
    required this.storageService,
    required this.repository,
    required this.audioPlayer,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) => PlayerBloc(
                    repository: repository,
                    storageService: storageService,
                    audioPlayer: audioPlayer,
                  )),
          BlocProvider(
              create: (context) => SearchBloc(
                    storageService: storageService,
                    repository: repository,
                  )..add(LoadTrendingTracks())),
          BlocProvider(
              create: (context) => FavoritesBloc(
                  storageService: storageService, repository: repository))
        ],
        child: MaterialApp.router(
          title: 'Audius Music Player',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          routerConfig: _appRouter.config(),
        ));
  }
}
