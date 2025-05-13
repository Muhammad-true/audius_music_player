import 'package:audius_music_player/presentation/bloc/favorites.dart/favorites_bloc.dart';
import 'package:audius_music_player/presentation/bloc/player/player_bloc.dart'
    as player_bloc;
import 'package:audius_music_player/router/router.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoritesView extends StatefulWidget {
  const FavoritesView({super.key});

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
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

                return Dismissible(
                  key: Key(track.id.toString()),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) {
                    context
                        .read<FavoritesBloc>()
                        .add(RemoveFromFavorites(track));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('${track.title} удалён из избранного')),
                    );
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
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
                      onPressed: () {
                        context
                            .read<FavoritesBloc>()
                            .add(RemoveFromFavorites(track));
                      },
                    ),
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
