import 'package:audius_music_player/presentation/bloc/player/player_bloc.dart';
import 'package:audius_music_player/presentation/pages/player/view/mini_player.dart';
import 'package:audius_music_player/router/router.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AutoTabsRouter(
      routes: const [
        SearchRoute(),
        FavoritesRoute(),
        DownloadRoute(),
        AccountRoute(),
      ],
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);

        return Stack(
          children: [
            Scaffold(
              body: child,
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: tabsRouter.activeIndex,
                onTap: tabsRouter.setActiveIndex,
                selectedItemColor:
                    theme.bottomNavigationBarTheme.selectedItemColor,
                unselectedItemColor:
                    theme.bottomNavigationBarTheme.unselectedItemColor,
                backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
                selectedLabelStyle:
                    theme.bottomNavigationBarTheme.selectedLabelStyle,
                unselectedLabelStyle:
                    theme.bottomNavigationBarTheme.unselectedLabelStyle,
                showUnselectedLabels:
                    theme.bottomNavigationBarTheme.showUnselectedLabels ?? true,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.search),
                    label: 'Поиск',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.favorite),
                    label: 'Избранное',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.download),
                    label: 'Скачанные',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Профиль',
                  ),
                ],
              ),
            ),
            BlocBuilder<PlayerBloc, PlayerState>(
              builder: (context, state) {
                final currentRoute = AutoRouter.of(context).current.name;
                final isOnPlayerPage = currentRoute == PlayerRoute.name;

                if (isOnPlayerPage || state is PlayerInitial) {
                  return const SizedBox.shrink();
                }

                return Positioned(
                  left: 0,
                  right: 0,
                  bottom: kBottomNavigationBarHeight,
                  child: MiniPlayer(
                    onClose: () {
                      context.read<PlayerBloc>().add(PlayerStopped());
                    },
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
