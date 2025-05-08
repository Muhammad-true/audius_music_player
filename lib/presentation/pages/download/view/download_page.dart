import 'dart:io';

import 'package:audius_music_player/data/models/download_track.dart';
import 'package:audius_music_player/presentation/bloc/download/bloc/download_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

@RoutePage()
class DownloadPage extends StatelessWidget {
  const DownloadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Downloads')),
      body: BlocConsumer<DownloadBloc, DownloadState>(
        listener: (context, state) {
          if (state is DownloadFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage)),
            );
          }
        },
        builder: (context, state) {
          if (state is DownloadInitial) {
            return const Center(child: Text('No downloads in progress.'));
          }

          final downloads =
              state is DownloadInProgress || state is DownloadCompleted
                  ? (state as dynamic).downloads
                  : <DownloadTrack>[];

          if (downloads.isEmpty) {
            return const Center(child: Text('No downloads found.'));
          }

          return ListView.builder(
            itemCount: downloads.length,
            itemBuilder: (context, index) {
              final downloadTrack = downloads[index];
              return FutureBuilder<File>(
                future: _getCoverFile(downloadTrack.filename),
                builder: (context, snapshot) {
                  Widget leading;

                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.data != null &&
                      snapshot.data!.existsSync()) {
                    leading = Image.file(
                      snapshot.data!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    );
                  } else {
                    leading = Image.network(
                      downloadTrack.track.coverArt,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.music_note),
                    );
                  }

                  return ListTile(
                    leading: leading,
                    title: Text(downloadTrack.track.title),
                    subtitle: Text(
                      downloadTrack.status == DownloadStatus.completed
                          ? 'Downloaded'
                          : 'Progress: ${(downloadTrack.progress * 100).toStringAsFixed(2)}%',
                    ),
                    trailing: _buildTrailing(context, downloadTrack),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget? _buildTrailing(BuildContext context, DownloadTrack downloadTrack) {
    switch (downloadTrack.status) {
      case DownloadStatus.downloading:
        return IconButton(
          icon: const Icon(Icons.pause),
          onPressed: () {
            context
                .read<DownloadBloc>()
                .add(PauseDownload(track: downloadTrack.track));
          },
        );
      case DownloadStatus.paused:
        return IconButton(
          icon: const Icon(Icons.play_arrow),
          onPressed: () {
            context
                .read<DownloadBloc>()
                .add(ResumeDownload(track: downloadTrack.track));
          },
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
