import 'package:firebase_2/data/repositories/artist/artist_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../model/artist/artist.dart';
import '../artists/view_model/artists_view_model.dart';
import 'widgets/artist_detail_content.dart';

class ArtistDetailScreen extends StatelessWidget {
  final Artist artist;
  const ArtistDetailScreen({super.key, required this.artist});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ArtistsViewModel(
        artistRepository: context.read<ArtistRepository>(),
      )..fetchArtistData(artist.id),
      child: ArtistDetailContent(artist: artist),
    );
  }
}