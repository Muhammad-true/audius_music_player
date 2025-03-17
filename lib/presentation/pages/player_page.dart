import 'package:audius_music_player/data/models/track_model.dart';
import 'package:audius_music_player/presentation/bloc/player_bloc/player_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlayerPage extends StatelessWidget {
  const PlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: BlocConsumer<PlayerBloc, PlayerState>(
        listener: (context, state) {
          if (state is PlayerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is PlayerLoading) {
            return Scaffold(
              appBar: _buildAppBar(context),
              body: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading track...'),
                  ],
                ),
              ),
            );
          }

          if (state is PlayerPlaying || state is PlayerPaused) {
            final trackState = state as dynamic;
            final track = trackState.track;
            final position = trackState.position;
            final duration = trackState.duration;

            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: SafeArea(
                child: Column(
                  children: [
                    _buildHeader(context),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildArtwork(track),
                          _buildTrackInfo(track),
                          _buildProgressBar(context, position, duration),
                          _buildControls(context),
                          _buildAdditionalControls(context, track),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Scaffold(
            appBar: _buildAppBar(context),
            body: const Center(child: Text('No track selected')),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.keyboard_arrow_down),
        onPressed: () => Navigator.pop(context),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'Now Playing',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Show options menu
            },
          ),
        ],
      ),
    );
  }

  Widget _buildArtwork(TrackModel track) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CachedNetworkImage(
          imageUrl: track.coverArt,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) =>
              Icon(Icons.music_note, size: 100, color: Colors.grey[400]),
        ),
      ),
    );
  }

  Widget _buildTrackInfo(TrackModel track) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Text(
            track.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            track.artistName,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(
      BuildContext context, Duration position, Duration duration) {
    final double progress =
        duration.inSeconds > 0 ? position.inSeconds / duration.inSeconds : 0.0;

    return Column(
      children: [
        Slider(
          value: progress.clamp(0.0, 1.0),
          onChanged: (value) => _onSeekChanged(context, value, duration),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(position),
                  style: TextStyle(color: Colors.grey[600])),
              Text(_formatDuration(duration),
                  style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      ],
    );
  }

  void _onSeekChanged(BuildContext context, double value, Duration duration) {
    if (duration.inSeconds > 0) {
      final newPosition =
          Duration(seconds: (value * duration.inSeconds).toInt());
      context.read<PlayerBloc>().add(SeekTo(newPosition));
    }
  }

  Widget _buildControls(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) {
        final bool isPlaying = state is PlayerPlaying;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(icon: const Icon(Icons.shuffle), onPressed: () {}),
            IconButton(
                icon: const Icon(Icons.skip_previous),
                iconSize: 40,
                onPressed: () {
                  context.read<PlayerBloc>().add(PreviousTrack());
                }),
            Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.blue),
              child: IconButton(
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 40, color: Colors.white),
                onPressed: () {
                  debugPrint('Toggle Play/Pause: isPlaying=$isPlaying');
                  context
                      .read<PlayerBloc>()
                      .add(isPlaying ? PauseTrack() : ResumeTrack());
                },
              ),
            ),
            IconButton(
                icon: const Icon(Icons.skip_next),
                iconSize: 40,
                onPressed: () {
                  context.read<PlayerBloc>().add(NextTrack());
                }),
            IconButton(icon: const Icon(Icons.repeat), onPressed: () {}),
          ],
        );
      },
    );
  }

  Widget _buildAdditionalControls(BuildContext context, TrackModel track) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(track.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: track.isFavorite ? Colors.red : null),
          onPressed: () {
            context.read<PlayerBloc>().add(ToggleFavorite(track));
          },
        ),
        IconButton(icon: const Icon(Icons.playlist_add), onPressed: () {}),
        IconButton(icon: const Icon(Icons.share), onPressed: () {}),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}';
  }
}
