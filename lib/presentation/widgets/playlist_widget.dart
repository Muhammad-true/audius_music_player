import 'package:flutter/material.dart';

// Виджет для отображения плейлистов
class PlaylistWidget extends StatelessWidget {
  const PlaylistWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Your Playlists',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) => _buildPlaylistCard(),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaylistCard() {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[200],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                'placeholder_url',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              'Playlist Name',
              style: TextStyle(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
