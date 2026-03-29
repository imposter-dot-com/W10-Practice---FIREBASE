import '../../../model/songs/song.dart';

abstract class SongRepository {
  Future<List<Song>> fetchSongs({bool forceFetch = false});
  
  Future<Song?> fetchSongById(String id);

  Future<void> likeSong(String songId, int currentLike);
}
