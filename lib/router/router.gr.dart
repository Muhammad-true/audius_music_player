// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

/// generated route for
/// [FavoritesPage]
class FavoritesRoute extends PageRouteInfo<void> {
  const FavoritesRoute({List<PageRouteInfo>? children})
      : super(
          FavoritesRoute.name,
          initialChildren: children,
        );

  static const String name = 'FavoritesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const FavoritesPage();
    },
  );
}

/// generated route for
/// [PlayerPage]
class PlayerRoute extends PageRouteInfo<PlayerRouteArgs> {
  PlayerRoute({
    Key? key,
    required TrackModel track,
    required List<TrackModel> tracks,
    List<PageRouteInfo>? children,
  }) : super(
          PlayerRoute.name,
          args: PlayerRouteArgs(
            key: key,
            track: track,
            tracks: tracks,
          ),
          initialChildren: children,
        );

  static const String name = 'PlayerRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PlayerRouteArgs>();
      return PlayerPage(
        key: args.key,
        track: args.track,
        tracks: args.tracks,
      );
    },
  );
}

class PlayerRouteArgs {
  const PlayerRouteArgs({
    this.key,
    required this.track,
    required this.tracks,
  });

  final Key? key;

  final TrackModel track;

  final List<TrackModel> tracks;

  @override
  String toString() {
    return 'PlayerRouteArgs{key: $key, track: $track, tracks: $tracks}';
  }
}

/// generated route for
/// [SearchPage]
class SearchRoute extends PageRouteInfo<void> {
  const SearchRoute({List<PageRouteInfo>? children})
      : super(
          SearchRoute.name,
          initialChildren: children,
        );

  static const String name = 'SearchRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SearchPage();
    },
  );
}
