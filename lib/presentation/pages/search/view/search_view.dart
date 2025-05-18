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
    final theme = Theme.of(context); // берем тему из контекста

    return Scaffold(
      appBar: AppBar(
        title: const Text('Steto-найти ритм в Audius'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: theme.appBarTheme.elevation,
        iconTheme: theme.appBarTheme.iconTheme,
        titleTextStyle: theme.appBarTheme.titleTextStyle,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // _buildHeader(theme),
            _buildSearchBar(theme),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<SearchBloc>().add(LoadTrendingTracks());
                },
                child: _buildContent(theme),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Text(
        'Steto-найти ритм в Audius',
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Поиск треков, исполнителей...',
          prefixIcon: Icon(Icons.search, color: theme.iconTheme.color),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: theme.iconTheme.color),
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
        style: theme.textTheme.bodyLarge,
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state is SearchLoading) {
          return Center(
              child: CircularProgressIndicator(color: theme.primaryColor));
        }

        if (state is SearchError) {
          return Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Text(state.message, style: theme.textTheme.bodyMedium),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<SearchBloc>().add(LoadTrendingTracks());
                  },
                  label: const Text('пробовать заного'),
                ),
              ]));
        }

        if (state is SearchLoaded) {
          if (state.searchTracks.isEmpty) {
            if (state.getTopTracks.isEmpty) {
              return Center(
                  child: Text('Ничего не найдено',
                      style: theme.textTheme.bodyMedium));
            }
            return ListView(
              children: [
                _buildTrendingSection(
                    state.getTopTracks, 'Популярные треки..', theme),
                _buildTrendingSection(state.getUndergroundTrendingTracks,
                    'Подземные трендовые треки..', theme),
              ],
            );
          } else {
            return ListView(children: [
              _buildTrendingSection(
                  state.searchTracks, 'Cмогли найти треки..', theme)
            ]);
          }
        }

        return Center(
            child: Text('Нет данных', style: theme.textTheme.bodyMedium));
      },
    );
  }

  Widget _buildTrendingSection(
      List<TrackModel> tracks, String title, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: theme.textTheme.bodyLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: tracks.length,
            itemBuilder: (context, index) =>
                _buildTrackCard(tracks[index], tracks, theme),
          ),
        ),
      ],
    );
  }

  Widget _buildTrackCard(
      TrackModel track, List<TrackModel> tracks, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        AutoRouter.of(context).push(PlayerRoute(track: track, tracks: tracks));
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: theme.cardColor,
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
              padding: const EdgeInsets.all(6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    track.artistName,
                    style: theme.textTheme.bodyMedium,
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
