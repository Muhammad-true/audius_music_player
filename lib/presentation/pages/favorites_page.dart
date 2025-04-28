import 'package:audius_music_player/presentation/bloc/favorites_bloc.dart/bloc/favorites_bloc.dart';
import 'package:audius_music_player/presentation/bloc/player_bloc/player_bloc.dart'
    as player_bloc;
import 'package:audius_music_player/router/router.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    context.read<FavoritesBloc>().add(LoadFavorites());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Избранное")),
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          if (state is FavoritesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FavoritesLoaded) {
            final tracks = state.favorites;

            if (tracks.isEmpty) {
              return const Center(child: Text("Нет избранных треков"));
            }

            return ListView.builder(
              itemCount: tracks.length,
              itemBuilder: (context, index) {
                final track = tracks[index];
                return ListTile(
                  onTap: () {
                    context
                        .read<player_bloc.PlayerBloc>()
                        .add(player_bloc.PlayTrack(track, tracks));
                    AutoRouter.of(context)
                        .push(PlayerRoute(track: track, tracks: tracks));
                  },
                  title: Text(track.title),
                  subtitle: Text(track.artistName),
                  leading: Image.network(track.coverArt),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () {},
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text("Ошибка загрузки"));
          }
        },
      ),
    );
  }
}
