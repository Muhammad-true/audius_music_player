import 'package:audius_music_player/presentation/bloc/favorites.dart/favorites_bloc.dart';
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Избранное"),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: theme.appBarTheme.elevation,
        iconTheme: theme.appBarTheme.iconTheme,
        titleTextStyle: theme.appBarTheme.titleTextStyle,
      ),
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          if (state is FavoritesError) {
            return Center(child: Text(state.message));
          }
          if (state is FavoritesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FavoritesLoaded) {
            final tracks = state.favorites;

            if (tracks.isEmpty) {
              return Center(
                child: Text(
                  "Нет избранных треков",
                  style: theme.textTheme.bodyMedium,
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: tracks.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
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
                        content: Text('${track.title} удалён из избранного'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    onTap: () {
                      AutoRouter.of(context).push(
                        PlayerRoute(track: track, tracks: tracks),
                      );
                    },
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        track.coverArt,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.music_note, size: 40),
                      ),
                    ),
                    title: Text(
                      track.title,
                      style: theme.textTheme.bodyLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      track.artistName,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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
            return Center(
              child: Text(
                "Ошибка загрузки",
                style: theme.textTheme.bodyMedium,
              ),
            );
          }
        },
      ),
    );
  }
}
