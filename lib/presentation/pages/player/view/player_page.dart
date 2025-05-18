import 'dart:io';

import 'package:audius_music_player/data/models/download_track.dart';
import 'package:audius_music_player/data/models/track_model.dart';
import 'package:audius_music_player/presentation/bloc/download/bloc/download_bloc.dart';
import 'package:audius_music_player/presentation/bloc/player/player_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

@RoutePage()
class PlayerPage extends StatefulWidget {
  final TrackModel track;
  final List<TrackModel> tracks;

  const PlayerPage({super.key, required this.track, required this.tracks});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  Future<String?>? _localCoverPathFuture;

  @override
  void initState() {
    super.initState();

    final playerBloc = context.read<PlayerBloc>();
    final currentState = playerBloc.state;

    final isSameTrack = (currentState is PlayerPlaying &&
            currentState.track.id == widget.track.id) ||
        (currentState is PlayerPaused &&
            currentState.track.id == widget.track.id);

    if (!isSameTrack) {
      playerBloc.add(PlayTrack(widget.track, widget.tracks));
    }

    _localCoverPathFuture = _getLocalCoverPathIfExists(widget.track);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      body: BlocBuilder<PlayerBloc, PlayerState>(
        builder: (context, state) {
          bool isLoading = false;
          TrackModel? loadingTrack;

          if (state is PlayerError) {
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.message),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('назад'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            ));
          }

          if (state is PlayerLoading) {
            isLoading = true;
            loadingTrack = state.track;
            state = PlayerPlaying(
              state.track,
              tracks: state.tracks,
              position: Duration.zero,
              duration: Duration.zero,
              isRepeat: false,
              isShuffle: false,
            );
          }

          if (state is PlayerPlaying || state is PlayerPaused) {
            final trackState = state as dynamic;
            final track = trackState.track;
            final position = trackState.position;
            final duration = trackState.duration;
            final isPlaying = state is PlayerPlaying;
            final tracks = trackState.tracks;
            final isCurrentTrackLoading =
                isLoading && loadingTrack?.id == track.id;

            return Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              body: SafeArea(
                child: Column(
                  children: [
                    _buildHeader(context, theme),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildArtwork(track),
                          _buildTrackInfo(track, textTheme, theme),
                          _buildProgressBar(context, position, duration, theme),
                          _buildControls(
                            context,
                            isPlaying,
                            track,
                            tracks,
                            state.isRepeat,
                            trackState.isShuffle,
                            isCurrentTrackLoading,
                            theme,
                          ),
                          _buildAdditionalControls(context, track, theme),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Center(
            child: Text(
              "Ошибка загрузки",
              style: theme.textTheme.bodyMedium,
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    final primaryColor = theme.primaryColor;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.keyboard_arrow_down, color: primaryColor),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'Сейчас играет',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: primaryColor),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildArtwork(TrackModel track) {
    return FutureBuilder<String?>(
      future: _localCoverPathFuture,
      builder: (context, snapshot) {
        final localPath = snapshot.data;

        Widget imageWidget;

        if (snapshot.connectionState == ConnectionState.done &&
            localPath != null &&
            File(localPath).existsSync()) {
          imageWidget = Image.file(
            File(localPath),
            fit: BoxFit.cover,
          );
        } else {
          imageWidget = CachedNetworkImage(
            imageUrl: track.coverArt,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) =>
                Icon(Icons.music_note, size: 100, color: Colors.grey[400]),
          );
        }

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
            child: imageWidget,
          ),
        );
      },
    );
  }

  Future<String?> _getLocalCoverPathIfExists(TrackModel track) async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/${track.title}.jpg';

    if (File(filePath).existsSync()) {
      return filePath;
    }
    return null;
  }

  Widget _buildTrackInfo(
    TrackModel track,
    TextTheme textTheme,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Text(
            track.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyLarge?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            track.artistName,
            style: textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, Duration position,
      Duration duration, ThemeData theme) {
    final double progress =
        duration.inSeconds > 0 ? position.inSeconds / duration.inSeconds : 0.0;

    return Column(
      children: [
        Slider(
          activeColor: theme.sliderTheme.activeTrackColor,
          inactiveColor: theme.sliderTheme.inactiveTrackColor,
          thumbColor: theme.sliderTheme.thumbColor,
          value: progress.clamp(0.0, 1.0),
          onChanged: (value) => _onSeekChanged(context, value, duration),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(position),
                style: TextStyle(color: theme.textTheme.bodyMedium?.color),
              ),
              Text(
                _formatDuration(duration),
                style: TextStyle(color: theme.textTheme.bodyMedium?.color),
              ),
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

  Widget _buildControls(
    BuildContext context,
    bool isPlaying,
    TrackModel track,
    List<TrackModel> tracks,
    bool repeat,
    bool isShuffle,
    bool isLoading,
    ThemeData theme,
  ) {
    final primaryColor = theme.primaryColor;
    final iconInactive = theme.iconTheme.color;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(!isShuffle ? Icons.redo : Icons.shuffle,
              color: iconInactive),
          onPressed: () {
            context.read<PlayerBloc>().add(ToggleShuffle());
          },
        ),
        IconButton(
          icon: Icon(Icons.skip_previous, size: 40, color: iconInactive),
          onPressed: () {
            context.read<PlayerBloc>().add(PreviousTrack(tracks: tracks));
          },
        ),
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primaryColor,
          ),
          child: isLoading
              ? const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 40,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    context.read<PlayerBloc>().add(isPlaying
                        ? PauseTrack(track: track)
                        : ResumeTrack(tracks: tracks));
                  },
                ),
        ),
        IconButton(
          icon: Icon(Icons.skip_next, size: 40, color: iconInactive),
          onPressed: () {
            context.read<PlayerBloc>().add(NextTrack(tracks: tracks));
          },
        ),
        IconButton(
          icon: Icon(!repeat ? Icons.repeat : Icons.repeat_one,
              color: iconInactive),
          onPressed: () {
            context.read<PlayerBloc>().add(ToggleRepeat());
          },
        ),
      ],
    );
  }

  Widget _buildAdditionalControls(
      BuildContext context, TrackModel track, ThemeData theme) {
    final isFavorite = context.select<PlayerBloc, bool>(
      (bloc) => bloc.state is PlayerPlaying &&
              (bloc.state as PlayerPlaying).track.id == track.id
          ? (bloc.state as PlayerPlaying).track.isFavorite
          : track.isFavorite,
    );

    final favoriteColor = isFavorite
        ? const Color.fromARGB(255, 255, 170, 163)
        : theme.iconTheme.color?.withOpacity(0.7);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: favoriteColor,
          ),
          onPressed: () {
            context.read<PlayerBloc>().add(ToggleFavorite(track));
          },
        ),
        if (track.canDownload)
          BlocBuilder<DownloadBloc, DownloadState>(
            builder: (context, state) {
              final downloadBloc = context.read<DownloadBloc>();

              final isDownloading = state is DownloadInProgress &&
                  state.downloads.any((d) =>
                      d.track.id == track.id &&
                      d.status == DownloadStatus.downloading);

              final isDownloaded = downloadBloc.isTrackDownloaded(track.id);

              if (isDownloading) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }

              if (isDownloaded) {
                return Icon(Icons.download_done, color: Colors.green.shade400);
              }

              return IconButton(
                icon: const Icon(Icons.download),
                onPressed: () {
                  context.read<DownloadBloc>().add(
                        StartDownload(
                          track: track,
                          url: track.id,
                          filename: track.title,
                        ),
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Загрузка началась")),
                  );
                },
              );
            },
          ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
