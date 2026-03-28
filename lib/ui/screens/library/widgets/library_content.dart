import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/theme.dart';
import '../../../utils/async_value.dart';
import '../view_model/library_item_data.dart';
import 'library_item_tile.dart';
import '../view_model/library_view_model.dart';

class LibraryContent extends StatelessWidget {
  const LibraryContent({super.key});

  @override
  Widget build(BuildContext context) {

    LibraryViewModel mv = context.watch<LibraryViewModel>();

    if (mv.likeError != null) {

      final errorMessage = mv.likeError;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage!), 
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 2),
          ),
        );
        mv.clearLikeError(); 
        
      });
    }

    AsyncValue<List<LibraryItemData>> asyncValue = mv.data;

    Widget content;
    switch (asyncValue.state) {
      case AsyncValueState.loading:
        content = Center(child: CircularProgressIndicator());
        break;
      case AsyncValueState.error:
        content = Center(
          child: Text(
            'error = ${asyncValue.error!}',
            style: TextStyle(color: Colors.red),
          ),
        );

      case AsyncValueState.success:
        List<LibraryItemData> data = asyncValue.data!;
        content = ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) => LibraryItemTile(
            data: data[index],
            isPlaying: mv.isSongPlaying(data[index].song),
            onTap: () {
              mv.start(data[index].song);
            },
            onLike: () => mv.toggleLike(data[index].song.id),
          ),
        );
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 16),
          Text("Library", style: AppTextStyles.heading),
          SizedBox(height: 50),

          Expanded(child: content),
        ],
      ),
    );
  }
}
