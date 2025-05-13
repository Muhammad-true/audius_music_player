import 'dart:async';

import 'package:audius_music_player/core/theme/app_theme.dart';
import 'package:audius_music_player/data/repositories/audius_repositor.dart';
import 'package:audius_music_player/data/services/storage_service.dart';
import 'package:audius_music_player/presentation/bloc/download/bloc/download_bloc.dart';
import 'package:audius_music_player/presentation/bloc/player/player_bloc.dart';
import 'package:audius_music_player/presentation/cubit/app_mode_cubit.dart';
import 'package:audius_music_player/router/router.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appRouter = AppRouter();
  final AppModeCubit _appModeCubit = AppModeCubit();
  final repository = GetIt.I<AudiusRepository>();
  final storage = GetIt.I<StorageService>();
  final audio = AudioPlayer();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();

    // Подписка на изменения подключения
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      final isOnline = results.any((r) => r != ConnectivityResult.none);
      if (isOnline) {
        _appModeCubit.setOnline();
      } else {
        _appModeCubit.setOffline();
      }
    });

    // Проверка текущего состояния сети при запуске
    Connectivity().checkConnectivity().then((results) {
      final isOnline = results.any((r) => r != ConnectivityResult.none);
      if (isOnline) {
        _appModeCubit.setOnline();
      } else {
        _appModeCubit.setOffline();
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _appModeCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppModeCubit>(
          create: (context) => _appModeCubit,
        ),
        BlocProvider(
            create: (context) => PlayerBloc(
                repository: repository,
                storageService: storage,
                audioPlayer: audio)),
        BlocProvider(create: (context) => DownloadBloc(repository: repository))
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
