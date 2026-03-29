import 'dart:convert';

import 'package:firebase_2/model/comment/comment.dart';
import 'package:firebase_2/model/songs/song.dart';
import 'package:http/http.dart' as http;

import '../../../model/artist/artist.dart';
import '../../dtos/artist_dto.dart';
import '../../dtos/song_dto.dart';
import '../../dtos/comment_dto.dart';
import 'artist_repository.dart';

class ArtistRepositoryFirebase implements ArtistRepository {
  final Uri artistsUri = Uri.https(
    'week-8-practice-c244d-default-rtdb.asia-southeast1.firebasedatabase.app',
    '/artists.json',
  );

  List<Artist> _cachedArtists = [];

  final Map<String, List<Song>> _cachedArtistSongs = {};
  final Map<String, List<Comment>> _cachedArtistComments = {};

  @override
  Future<List<Artist>> fetchArtists({bool forceFetch = false}) async {
    if (!forceFetch && _cachedArtists.isNotEmpty) {
      return _cachedArtists;
    }

    final http.Response response = await http.get(artistsUri);

    if (!forceFetch & _cachedArtists.isNotEmpty) {
      return _cachedArtists;
    }

    if (response.statusCode == 200) {
      // 1 - Send the retrieved list of songs
      Map<String, dynamic> songJson = json.decode(response.body);

      List<Artist> result = [];
      for (final entry in songJson.entries) {
        result.add(ArtistDto.fromJson(entry.key, entry.value));
      }

      _cachedArtists = result;
      return result;
    } else {
      // 2- Throw expcetion if any issue
      throw Exception('Failed to load posts');
    }
  }

  @override
  Future<Artist?> fetchArtistById(String id) async {}

  @override
  Future<List<Comment>> fetchArtistComments(String artistId) async {
    if (_cachedArtistComments.containsKey(artistId)) {
      return _cachedArtistComments[artistId]!;
    }

    final uri = Uri.https(
      'week-8-practice-c244d-default-rtdb.asia-southeast1.firebasedatabase.app',
      '/comments.json',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      if (body == null) {
        _cachedArtistComments[artistId] = [];
        return [];
      }

      final List<Comment> allComments = (body as Map<String, dynamic>).entries
          .map((entry) {
            return CommentDto.fromJson(entry.key, entry.value);
          })
          .toList();

      final List<Comment> filteredComments = allComments
          .where((comment) => comment.artistId == artistId)
          .toList();

      filteredComments.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _cachedArtistComments[artistId] = filteredComments;
      return filteredComments;
    } else {
      throw Exception('Failed to load comments');
    }
  }

  @override
  Future<List<Song>> fetchArtistSongs(String artistId) async {
    if (_cachedArtistSongs.containsKey(artistId)) {
      return _cachedArtistSongs[artistId]!;
    }

    final uri = Uri.https(
      'week-8-practice-c244d-default-rtdb.asia-southeast1.firebasedatabase.app',
      '/songs.json',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body == null) return [];

      final Map<String, dynamic> allSongsMap = body;

      final List<Song> filteredSongs = allSongsMap.entries
          .map((entry) => SongDto.fromJson(entry.key, entry.value))
          .where((song) => song.artistId == artistId)
          .toList();

      return filteredSongs;
    } else {
      throw Exception('Failed to load songs');
    }
  }

  @override
  Future<Comment> postComment(String artistId, String text) async {
    final uri = Uri.https(
      'week-8-practice-c244d-default-rtdb.asia-southeast1.firebasedatabase.app',
      '/comments.json',
    );
    final now = DateTime.now();

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'artistId': artistId,
        'text': text,
        'createdAt': now.toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      final String id = (jsonDecode(response.body) as Map)['name'] as String;
      final comment = Comment(
        id: id,
        artistId: artistId,
        text: text,
        createdAt: now,
      );

      _cachedArtistComments[artistId]?.insert(0, comment);

      return comment;
    } else {
      throw Exception('Failed to post comment');
    }
  }
}
