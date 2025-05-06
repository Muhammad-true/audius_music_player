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
    return AutoTabsRouter(
      routes: const [
        SearchRoute(),
        FavoritesRoute(),
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
                selectedItemColor: Colors.blue,
                unselectedItemColor: Colors.grey,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.search),
                    label: 'Search',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.favorite),
                    label: 'Favorites',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Account',
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
