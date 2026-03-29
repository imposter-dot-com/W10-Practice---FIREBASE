import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../model/artist/artist.dart';
import '../../../../../model/comment/comment.dart';
import '../../../utils/async_value.dart';
import '../../../widgets/comment/comment_tile.dart';
import '../../artists/view_model/artists_view_model.dart';
import '../../library/view_model/library_item_data.dart';
import '../../library/widgets/library_item_tile.dart';

class ArtistDetailContent extends StatefulWidget {
  final Artist artist;
  const ArtistDetailContent({super.key, required this.artist});

  @override
  State<ArtistDetailContent> createState() => _ArtistDetailContentState();
}

class _ArtistDetailContentState extends State<ArtistDetailContent> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _openCommentSheet(BuildContext context, ArtistsViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20, bottom: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Leave a comment',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 12),
              TextField(
                controller: _commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Write something about ${widget.artist.name}…',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: vm.isPostingComment
                    ? null
                    : () async {
                        await vm.addComment(
                          widget.artist.id,
                          _commentController.text,
                        );
                        if (vm.commentError == null && ctx.mounted) {
                          _commentController.clear();
                          Navigator.pop(ctx);
                        } else if (vm.commentError != null && ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(content: Text(vm.commentError!)),
                          );
                          vm.clearCommentError();
                        }
                      },
                child: vm.isPostingComment
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Post Comment'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ArtistsViewModel>();


    return Scaffold(
      appBar: AppBar(title: Text(widget.artist.name)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCommentSheet(context, vm),
        icon: const Icon(Icons.comment),
        label: const Text('Comment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      NetworkImage(widget.artist.imageUrl.toString()),
                ),
                const SizedBox(height: 12),
                Text(widget.artist.name,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w500)),
                Text(widget.artist.genre,
                    style: TextStyle(color: Colors.grey[600])),
              ]),
            ),

            const SizedBox(height: 30),

            // Songs section
            const Text('Songs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            _buildSongs(vm),

            const SizedBox(height: 30),

            // Comments section
            const Text('Comments',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            _buildComments(vm.commentsValue),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSongs(ArtistsViewModel vm) {
    switch (vm.songsValue.state) {
      case AsyncValueState.loading:
        return const Center(child: CircularProgressIndicator());
      case AsyncValueState.error:
        return Text('Error: ${vm.songsValue.error}',
            style: const TextStyle(color: Colors.red));
      case AsyncValueState.success:
        final songs = vm.songsValue.data!;
        if (songs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('No songs yet for this artist.'),
            ),
          );
        }
        return Column(
          children: songs
              .map((s) => LibraryItemTile(
                    data: LibraryItemData(song: s, artist: widget.artist),
                    isPlaying: false,
                    onTap: () {},
                    onLike: () {},
                  ))
              .toList(),
        );
    }
  }

  Widget _buildComments(AsyncValue<List<Comment>> asyncComments) {
    switch (asyncComments.state) {
      case AsyncValueState.loading:
        return const Center(child: CircularProgressIndicator());
      case AsyncValueState.error:
        return Text('Error: ${asyncComments.error}',
            style: const TextStyle(color: Colors.red));
      case AsyncValueState.success:
        final comments = asyncComments.data!;
        if (comments.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('No comments yet. Be the first!'),
            ),
          );
        }
        return Column(
          children: comments.map((c) => CommentTile(comment: c)).toList(),
        );
    }
  }
}