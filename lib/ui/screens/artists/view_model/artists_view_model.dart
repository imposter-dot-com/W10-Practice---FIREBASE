import 'package:firebase_2/model/comment/comment.dart';
import 'package:firebase_2/model/songs/song.dart';
import 'package:flutter/material.dart';
import '../../../../../data/repositories/artist/artist_repository.dart';
import '../../../../../model/artist/artist.dart';
import '../../../utils/async_value.dart';

class ArtistsViewModel extends ChangeNotifier {
  final ArtistRepository artistRepository;

  AsyncValue<List<Artist>> artistsValue = AsyncValue.loading();

  AsyncValue<List<Song>> songsValue = AsyncValue.loading();
  AsyncValue<List<Comment>> commentsValue = AsyncValue.loading();
  bool isPostingComment = false;
  String? commentError;

  ArtistsViewModel({required this.artistRepository}) {
    _init();
  }

  void _init() async {
    fetchArtists();
  }

  void fetchArtists({bool forceFetch = false}) async {
    // 1- Loading state
    artistsValue = AsyncValue.loading();
    notifyListeners();

    try {
      // 2- Fetch is successfull
      List<Artist> artists = await artistRepository.fetchArtists(
        forceFetch: forceFetch,
      );
      artistsValue = AsyncValue.success(artists);
    } catch (e) {
      // 3- Fetch is unsucessfull
      artistsValue = AsyncValue.error(e);
    }
    notifyListeners();
  }

  Future<void> fetchArtistData(String artistId) async {
    songsValue = AsyncValue.loading();
    commentsValue = AsyncValue.loading();
    notifyListeners();

    try {
      final songs = await artistRepository.fetchArtistSongs(artistId);
      songsValue = AsyncValue.success(songs);
    } catch (e) {
      songsValue = AsyncValue.error(e);
    }

    try {
      final comments = await artistRepository.fetchArtistComments(artistId);
      commentsValue = AsyncValue.success(comments);
    } catch (e) {
      commentsValue = AsyncValue.error(e);
    }

    notifyListeners();
  }

  Future<void> addComment(String artistId, String text) async {
    if (text.isEmpty) {
      commentError = 'Please enter your comment';
      notifyListeners();
      return;
    }

    isPostingComment = true;
    commentError = null;
    notifyListeners();

    try {
      await artistRepository.postComment(artistId, text);
      final updatedComments = await artistRepository.fetchArtistComments(
        artistId,
      );
      commentsValue = AsyncValue.success(updatedComments);
    } catch (e) {
      commentError = 'Failed to post the comment. Please try again';
    }

    isPostingComment = false;
    notifyListeners();
  }

  void clearCommentError() {
    commentError = null;
  }
}
  