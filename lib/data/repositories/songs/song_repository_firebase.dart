import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../model/songs/song.dart';
import '../../dtos/song_dto.dart';
import 'song_repository.dart';

class SongRepositoryFirebase extends SongRepository {
  final Uri songsUri = Uri.https(
    'week-8-practice-c244d-default-rtdb.asia-southeast1.firebasedatabase.app',
    '/songs.json',
  );

  List<Song> _cachedSongs = [];

  @override
  Future<List<Song>> fetchSongs({bool forceFetch = false}) async {
    final http.Response response = await http.get(songsUri);

    if(!forceFetch && _cachedSongs.isNotEmpty){
      return _cachedSongs;
    }

    if (response.statusCode == 200) {

      // 1 - Send the retrieved list of songs
      Map<String, dynamic> songJson = json.decode(response.body);

      List<Song> result = [];
      for (final entry in songJson.entries) {
        result.add(SongDto.fromJson(entry.key, entry.value));
      }

      _cachedSongs = result;
      return result;
    } else {
      // 2- Throw expcetion if any issue
      throw Exception('Failed to load posts');
    }
  }

  @override
  Future<Song?> fetchSongById(String id) async {}

  @override
  Future<void> likeSong(String songId, int currentLike) async{
    final Uri uri = Uri.https('week-8-practice-c244d-default-rtdb.asia-southeast1.firebasedatabase.app','/songs/$songId.json');

    final response = await http.patch(
      uri,
      body: json.encode({'likes': currentLike + 1,}),
    );

    if(response.statusCode != 200){
      throw Exception('Failed to like song');
    }
  }
}
