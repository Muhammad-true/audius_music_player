import 'dart:async';

import 'package:audius_music_player/data/models/track_model.dart';
import 'package:audius_music_player/presentation/bloc/search/search_bloc.dart';
import 'package:audius_music_player/router/router.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
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
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final bloc = context.read<SearchBloc>();
      if (query.isEmpty) {
        bloc.add(LoadTrendingTracks());
      } else {
        bloc.add(SearchTracks(query));
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
                  context.read<SearchBloc>().add(LoadTrendingTracks());
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
      child: const Row(
        children: [
          Text(
            'Steto-найти ритм',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                    context.read<SearchBloc>().add(ClearSearch());
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
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state is SearchLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is SearchError) {
          return Center(child: Text('Ошибка: ${state.message}'));
        }

        if (state is SearchLoaded) {
          if (state.playlist.isEmpty) {
            return const Center(child: Text('Ничего не найдено'));
          }
          return ListView(
            children: [
              _buildTrendingSection(state.playlist, 'Популярные треки недели'),
              _buildTrendingSection(
                  state.playlist, 'Популярные скачанные треки недели'),
            ],
          );
        }

        return const Center(child: Text('Нет данных'));
      },
    );
  }

  Widget _buildTrendingSection(List<TrackModel> tracks, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
