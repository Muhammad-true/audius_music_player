import 'dart:io';

import 'package:audius_music_player/presentation/bloc/player/player_bloc.dart';
import 'package:audius_music_player/router/router.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MiniPlayer extends StatelessWidget {
  final VoidCallback onClose;

  const MiniPlayer({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) {
        if (state is! PlayerPlaying && state is! PlayerPaused) {
          return const SizedBox.shrink();
        }

        final trackState = state as dynamic;
        final track = trackState.track;
        final tracks = trackState.tracks;
        final isPlaying = state is PlayerPlaying;

        // определяем тип изображения
        final ImageProvider imageProvider = track.coverArt.startsWith('/data')
            ? FileImage(File(track.coverArt))
            : CachedNetworkImageProvider(track.coverArt);

        return GestureDetector(
          onTap: () => context.router.push(
            PlayerRoute(track: track, tracks: tracks),
          ),
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: Theme.of(context).cardColor,
            child: Row(
              children: [
                Image(
                  image: imageProvider,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        track.artistName,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 24,
                  ),
                  onPressed: () {
                    context.read<PlayerBloc>().add(
                          isPlaying
                              ? PauseTrack(track: track)
                              : ResumeTrack(tracks: tracks),
                        );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onClose,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
