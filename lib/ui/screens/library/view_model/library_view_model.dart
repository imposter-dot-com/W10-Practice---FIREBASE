import 'package:flutter/material.dart';
import '../../../../../data/repositories/artist/artist_repository.dart';
import '../../../../../data/repositories/songs/song_repository.dart';
import '../../../../../model/artist/artist.dart';
import '../../../states/player_state.dart';
import '../../../../../model/songs/song.dart';
import '../../../utils/async_value.dart';
import 'library_item_data.dart';

class LibraryViewModel extends ChangeNotifier {
  final SongRepository songRepository;
  final ArtistRepository artistRepository;

  final PlayerState playerState;

  AsyncValue<List<LibraryItemData>> data = AsyncValue.loading();

  LibraryViewModel({
    required this.songRepository,
    required this.playerState,
    required this.artistRepository,
  }) {
    playerState.addListener(notifyListeners);

    // init
    _init();
  }

  @override
  void dispose() {
    playerState.removeListener(notifyListeners);
    super.dispose();
  }

  void _init() async {
    fetchSong();
  }

  Future<void> fetchSong({bool forceFetch = false}) async {
    // 1- Loading state
    data = AsyncValue.loading();
    notifyListeners();

    try {
      // 1- Fetch songs
      List<Song> songs = await songRepository.fetchSongs(forceFetch: forceFetch);

      // 2- Fethc artist
      List<Artist> artists = await artistRepository.fetchArtists(forceFetch: forceFetch);

      // 3- Create the mapping artistid-> artist
      Map<String, Artist> mapArtist = {};
      for (Artist artist in artists) {
        mapArtist[artist.id] = artist;
      }

      List<LibraryItemData> data = songs
          .map(
            (song) =>
                LibraryItemData(song: song, artist: mapArtist[song.artistId]!),
          )
          .toList();

      this.data = AsyncValue.success(data);
    } catch (e) {
      // 3- Fetch is unsucessfull
      data = AsyncValue.error(e);
    }
    notifyListeners();
  }

  bool isSongPlaying(Song song) => playerState.currentSong == song;

  void start(Song song) => playerState.start(song);
  void stop(Song song) => playerState.stop();

  String? _likeError;
  String? get likeError => _likeError;

  Future<void> toggleLike(String songId) async {
    final currentAsyncData = data.data;
    if (currentAsyncData == null) return;

    // create a deep copy of the current list for an easy rollback
    final List<LibraryItemData> previousList = List.from(currentAsyncData);

    // map through the items and only update the one that matches the ID
    final updatedList = currentAsyncData.map((item) {
      if (item.song.id == songId) {
        return item.copyWith(
          song: item.song.copyWith(likes: item.song.likes + 1),
        );
      }
      return item;
    }).toList();

    data = AsyncValue.success(updatedList);
    notifyListeners(); // The heart turns red/count goes up NOW

    try {
      final originalSong = previousList
          .firstWhere((i) => i.song.id == songId)
          .song;
      await songRepository.likeSong(songId, originalSong.likes);
    } catch (e) {
      data = AsyncValue.success(previousList);
      _likeError = "Failed to like song.";
      notifyListeners();
    }
  }

  void clearLikeError() => _likeError = null;
}
