import 'dart:async';

import 'package:audius_music_player/data/models/track_model.dart';
import 'package:audius_music_player/presentation/bloc/search_bloc/search_bloc.dart'
    as search_bloc;
import 'package:audius_music_player/router/router.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {});
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isEmpty) {
        context
            .read<search_bloc.SearchBloc>()
            .add(search_bloc.LoadTrendingTracks());
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
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  context
                      .read<search_bloc.SearchBloc>()
                      .add(search_bloc.LoadTrendingTracks());
                },
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {},
          ),
          const Text(
            'Барои Mehrona',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              IconButton(
                  icon: const Icon(Icons.favorite),
                  onPressed: () {
                    AutoRouter.of(context).push(const FavoritesRoute());
                  }),
              IconButton(
                icon: const Icon(Icons.playlist_play),
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search tracks, artists...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context
                        .read<search_bloc.SearchBloc>()
                        .add(search_bloc.ClearSearch());
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return BlocBuilder<search_bloc.SearchBloc, search_bloc.SearchState>(
      builder: (context, searchState) {
        if (searchState is search_bloc.SearchLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (searchState is search_bloc.SearchError) {
          return Center(child: Text('Ошибка: ${searchState.message}'));
        }

        if (searchState is search_bloc.SearchLoaded) {
          if (searchState.tracks.isEmpty) {
            return const Center(child: Text('Ничего не найдено'));
          }
          return ListView(
            children: [
              _buildTrendingSection(
                  searchState.tracks, 'Популярные треки недели'),
              _buildTrendingSection(searchState.tracksDownloadedWeek,
                  'Попуоярные скачивание треки неделя')
            ],
          );
        }

        // Default return statement to handle any other state
        return const Center(child: Text('No content available'));
      },
    );
  }

  Widget _buildTrendingSection(
      List<TrackModel> tracks, String text_in_playlist) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            text_in_playlist,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
        AutoRouter.of(context).push(PlayerRoute(track: track, tracks: tracks));
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[100],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
                aspectRatio: 1,
                child: CachedNetworkImage(
                  imageUrl: track.coverArt,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
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
}
