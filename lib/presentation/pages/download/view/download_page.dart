import 'dart:io';

import 'package:audius_music_player/data/models/download_track.dart';
import 'package:audius_music_player/presentation/bloc/download/bloc/download_bloc.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Downloads')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Saved Downloads',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            BlocBuilder<DownloadBloc, DownloadState>(
              builder: (context, state) {
                if (state is DownloadLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is DownloadLoaded) {
                  if (state.downloadedTracks.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('No saved downloads.'),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.downloadedTracks.length,
                    itemBuilder: (context, index) {
                      final track = state.downloadedTracks[index];
                      return Dismissible(
                        key: Key(track.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          context
                              .read<DownloadBloc>()
                              .add(DeleteDownloadedTrack(track: track));
                        },
                        child: ListTile(
                          leading: Image.file(
                            File(track.coverArt),
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                          ),
                          title: Text(track.title),
                          subtitle: Text(track.artistName),
                          onTap: () {
                            // TODO: Запустить плеер с локального файла
                          },
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Active Downloads',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
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
                    state is DownloadInProgress || state is DownloadCompleted
                        ? (state as dynamic).downloads
                        : <DownloadTrack>[];

                if (downloads.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('No active downloads.'),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
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
          ],
        ),
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
