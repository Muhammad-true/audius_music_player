import 'package:audius_music_player/data/repositories/audius_repositor.dart';
import 'package:audius_music_player/data/services/storage_service.dart';
import 'package:audius_music_player/presentation/bloc/favorites.dart/favorites_bloc.dart';
import 'package:audius_music_player/presentation/cubit/app_mode_cubit.dart';
import 'package:audius_music_player/presentation/pages/favorites/view/favorites_view.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

@RoutePage()
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FavoritesBloc(
          storageService: GetIt.I<StorageService>(),
          repository: GetIt.I<AudiusRepository>(),
          appModeCubit: context.read<AppModeCubit>())
        ..add(LoadFavorites()), // Загружаем избранное при инициализации

      child: const FavoritesView(),
    );
  }
}
