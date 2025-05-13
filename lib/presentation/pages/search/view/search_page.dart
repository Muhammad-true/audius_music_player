import 'package:audius_music_player/data/repositories/audius_repositor.dart';
import 'package:audius_music_player/data/services/storage_service.dart';
import 'package:audius_music_player/presentation/bloc/search/search_bloc.dart';
import 'package:audius_music_player/presentation/cubit/app_mode_cubit.dart';
import 'package:audius_music_player/presentation/pages/search/view/search_view.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

@RoutePage()
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchBloc(
        repository: GetIt.I<AudiusRepository>(),
        storageService: GetIt.I<StorageService>(),
        appModeCubit: context.read<AppModeCubit>(),
      )..add(LoadTrendingTracks()),
      child: const SearchView(),
    );
  }
}
