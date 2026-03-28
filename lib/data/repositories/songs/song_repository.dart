import '../../../model/songs/song.dart';

abstract class SongRepository {
  Future<List<Song>> fetchSongs();
  
  Future<Song?> fetchSongById(String id);

  Future<void> likeSong(String songId, int currentLike);
}
