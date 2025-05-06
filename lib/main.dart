import 'package:audius_music_player/core/theme/app_theme.dart';
import 'package:audius_music_player/data/repositories/jamendoRepositor.dart';
import 'package:audius_music_player/data/services/storage_service.dart';
import 'package:audius_music_player/presentation/bloc/favorites.dart/favorites_bloc.dart';
import 'package:audius_music_player/presentation/bloc/player/player_bloc.dart';
import 'package:audius_music_player/presentation/bloc/search/search_bloc.dart';
import 'package:audius_music_player/router/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);
  final repository = await JamendoRepository.create();
  final audioPlayer = AudioPlayer();

  runApp(MyApp(
    storageService: storageService,
    repository: repository,
    audioPlayer: audioPlayer,
  ));
}

class MyApp extends StatelessWidget {
  final StorageService storageService;
  final JamendoRepository repository;
  final AudioPlayer audioPlayer;

  MyApp({
    required this.storageService,
    required this.repository,
    required this.audioPlayer,
  });

  final _appRouter = AppRouter(); // Ensure your root route is MainScaffoldRoute

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => PlayerBloc(
            repository: repository,
            storageService: storageService,
            audioPlayer: audioPlayer,
          ),
        ),
        BlocProvider(
          create: (_) => SearchBloc(
            repository: repository,
            storageService: storageService,
          )..add(LoadTrendingTracks()),
        ),
        BlocProvider(
          create: (_) => FavoritesBloc(
            repository: repository,
            storageService: storageService,
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'Audius Music Player',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: _appRouter.config(),
      ),
    );
  }
}
