import 'dart:async';

import 'package:audius_music_player/data/models/track_model.dart';
import 'package:audius_music_player/presentation/bloc/player_bloc/player_bloc.dart'
    as player_bloc;
import 'package:audius_music_player/presentation/bloc/search_bloc/search_bloc.dart'
    as search_bloc;
import 'package:audius_music_player/presentation/pages/favorites_page.dart';
import 'package:audius_music_player/presentation/pages/player_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  List<TrackModel> _playlist = [];

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isEmpty) {
        context
            .read<player_bloc.PlayerBloc>()
            .add(player_bloc.LoadTrendingTracks());
      } else {
        context
            .read<search_bloc.SearchBloc>()
            .add(search_bloc.SearchTracks(query));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  context
                      .read<player_bloc.PlayerBloc>()
                      .add(player_bloc.LoadTrendingTracks());
                },
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildMiniPlayer(_playlist),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Audius Music',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.favorite),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FavoritesPage(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.playlist_play),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search tracks, artists...',
          prefixIcon: Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context
                        .read<search_bloc.SearchBloc>()
                        .add(search_bloc.ClearSearch());
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return BlocBuilder<search_bloc.SearchBloc, search_bloc.SearchState>(
        builder: (context, searchState) {
      if (searchState is search_bloc.SearchLoading) {
        return Center(child: CircularProgressIndicator());
      }

      if (searchState is search_bloc.SearchError) {
        return Center(child: Text('Ошибка: ${searchState.message}'));
      }

      if (searchState is search_bloc.SearchSuccess) {
        if (searchState.tracks.isEmpty) {
          return Center(child: Text('Ничего не найдено'));
        }
        return ListView(
          children: [_buildTrendingSection(searchState.tracks)],
        );
      }

      return BlocBuilder<player_bloc.PlayerBloc, player_bloc.PlayerState>(
        builder: (context, state) {
          if (state is player_bloc.PlayerLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading tracks...'),
                ],
              ),
            );
          }

          if (state is player_bloc.PlayerError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Error loading tracks:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      state.message,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<player_bloc.PlayerBloc>()
                          .add(player_bloc.LoadTrendingTracks());
                    },
                    child: Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          if (state is player_bloc.TracksLoaded) {
            if (state.tracks.isEmpty) {
              return const Center(
                child: Text('No tracks found'),
              );
            } else if (_searchController.text.isEmpty)
              return ListView(
                children: [
                  _buildTrendingSection(state.tracks),
                ],
              );
          }

          return SizedBox();
        },
      );
    });
  }

  Widget _buildTrendingSection(List<TrackModel> tracks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Trending Now',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: tracks.length,
            itemBuilder: (context, index) =>
                _buildTrackCard(tracks[index], tracks),
          ),
        ),
      ],
    );
  }

  Widget _buildTrackCard(TrackModel track, List<TrackModel> tracks) {
    return GestureDetector(
      onTap: () {
        context
            .read<player_bloc.PlayerBloc>()
            .add(player_bloc.PlayTrack(track, tracks));
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayerPage(tracks: tracks),
          ),
        );
      },
      child: Container(
        width: 150,
        margin: EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[100],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
                aspectRatio: 1,
                child: CachedNetworkImage(
                  imageUrl: track.coverArt,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    track.artistName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniPlayer(List<TrackModel> tracks) {
    return BlocBuilder<player_bloc.PlayerBloc, player_bloc.PlayerState>(
      builder: (context, state) {
        if (state is player_bloc.PlayerPlaying ||
            state is player_bloc.PlayerPaused) {
          final track = state is player_bloc.PlayerPlaying
              ? (state as player_bloc.PlayerPlaying).track
              : (state as player_bloc.PlayerPaused).track;
          final isPlaying = state is player_bloc.PlayerPlaying;

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PlayerPage(tracks: tracks)),
              );
            },
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: track.coverArt,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          track.title,
                          style: TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          track.artistName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                    onPressed: () {
                      if (isPlaying) {
                        context
                            .read<player_bloc.PlayerBloc>()
                            .add(player_bloc.PauseTrack(track: track));
                      } else {
                        context.read<player_bloc.PlayerBloc>().add(
                            player_bloc.ResumeTrack(
                                tracks: List<TrackModel>.empty()));
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        }
        return SizedBox();
      },
    );
  }
}
