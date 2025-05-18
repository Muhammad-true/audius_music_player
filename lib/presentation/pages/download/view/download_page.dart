import 'dart:io';

import 'package:audius_music_player/data/models/download_track.dart';
import 'package:audius_music_player/data/models/track_model.dart';
import 'package:audius_music_player/presentation/bloc/download/bloc/download_bloc.dart';
import 'package:audius_music_player/router/router.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

@RoutePage()
class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  @override
  void initState() {
    super.initState();
    context.read<DownloadBloc>().add(LoadDownloadedTracks());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Загрузки'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: theme.appBarTheme.elevation,
        iconTheme: theme.appBarTheme.iconTheme,
        titleTextStyle: theme.appBarTheme.titleTextStyle,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(theme, 'Сохранённые загрузки'),
            BlocBuilder<DownloadBloc, DownloadState>(
              builder: (context, state) {
                if (state is DownloadLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is DownloadLoaded) {
                  return _buildSavedList(theme, state.downloadedTracks);
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 24),
            _sectionTitle(theme, 'Активные загрузки'),
            BlocConsumer<DownloadBloc, DownloadState>(
              listener: (context, state) {
                if (state is DownloadFailed) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.errorMessage)),
                  );
                }
              },
              builder: (context, state) {
                final downloads =
                    (state is DownloadInProgress || state is DownloadCompleted)
                        ? (state as dynamic).downloads
                        : <DownloadTrack>[];

                if (downloads.isEmpty) {
                  return _emptyLabel(theme, 'Нет активных загрузок.');
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: downloads.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) =>
                      _activeTile(context, theme, downloads[index]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── helpers ──────────────────────────

  Widget _sectionTitle(ThemeData theme, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          text,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      );

  Widget _emptyLabel(ThemeData theme, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(text, style: theme.textTheme.bodyMedium),
      );

  Widget _buildSavedList(ThemeData theme, List<TrackModel> tracks) {
    if (tracks.isEmpty) return _emptyLabel(theme, 'Нет сохранённых загрузок.');

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tracks.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final track = tracks[index];
        return Dismissible(
          key: Key(track.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) => context
              .read<DownloadBloc>()
              .add(DeleteDownloadedTrack(track: track)),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            leading: _coverImage(track.coverArt),
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
            onTap: () => AutoRouter.of(context).push(
              PlayerRoute(track: track, tracks: tracks),
            ),
          ),
        );
      },
    );
  }

  Widget _activeTile(
      BuildContext context, ThemeData theme, DownloadTrack dTrack) {
    return FutureBuilder<File>(
      future: _getCoverFile(dTrack.filename),
      builder: (context, snap) {
        final file = snap.data;
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          leading: (file != null && file.existsSync())
              ? _coverImage(file.path)
              : _placeholderBox(),
          title: Text(
            dTrack.track.title,
            style: theme.textTheme.bodyLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            dTrack.status == DownloadStatus.completed
                ? 'Скачано'
                : 'Прогресс: ${(dTrack.progress * 100).toStringAsFixed(1)}%',
            style: theme.textTheme.bodyMedium,
          ),
          trailing: _buildTrailing(context, dTrack),
        );
      },
    );
  }

  Widget _coverImage(String path) => ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.file(
          File(path),
          width: 56,
          height: 56,
          fit: BoxFit.cover,
        ),
      );

  Widget _placeholderBox() => Container(
        width: 56,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: Colors.grey[300],
        ),
        child: const Icon(Icons.music_note, size: 32, color: Colors.grey),
      );

  Widget? _buildTrailing(BuildContext context, DownloadTrack dTrack) {
    final theme = Theme.of(context);
    switch (dTrack.status) {
      case DownloadStatus.downloading:
        return IconButton(
          icon: Icon(Icons.pause, color: theme.primaryColor),
          onPressed: () => context
              .read<DownloadBloc>()
              .add(PauseDownload(track: dTrack.track)),
        );
      case DownloadStatus.paused:
        return IconButton(
          icon: Icon(Icons.play_arrow, color: theme.primaryColor),
          onPressed: () => context
              .read<DownloadBloc>()
              .add(ResumeDownload(track: dTrack.track)),
        );
      default:
        return null;
    }
  }

  Future<File> _getCoverFile(String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$fileName.jpg');
  }
}
