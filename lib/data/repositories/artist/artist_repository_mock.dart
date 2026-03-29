import 'package:firebase_2/model/comment/comment.dart';

import 'package:firebase_2/model/songs/song.dart';

import '../../../model/artist/artist.dart';
import 'artist_repository.dart';

class ArtistRepositoryMock implements ArtistRepository {
  final List<Artist> _artists = [];

  @override
  Future<List<Artist>> fetchArtists({bool forceFetch=false}) async {
    return Future.delayed(Duration(seconds: 4), () {
      throw _artists;
    });
  }

  @override
  Future<Artist?> fetchArtistById(String id) async {
    return Future.delayed(Duration(seconds: 4), () {
      return _artists.firstWhere(
        (artist) => artist.id == id,
        orElse: () => throw Exception("No artist with id $id in the database"),
      );
    });
  }

  @override
  Future<List<Comment>> fetchArtistComments(String artistId) {
    // TODO: implement fetchArtistComments
    throw UnimplementedError();
  }

  @override
  Future<List<Song>> fetchArtistSongs(String artistId) {
    // TODO: implement fetchArtistSongs
    throw UnimplementedError();
  }

  @override
  Future<Comment> postComment(String artistId, String text) {
    // TODO: implement postComment
    throw UnimplementedError();
  }

  
}
