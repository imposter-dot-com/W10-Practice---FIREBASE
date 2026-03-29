import '../../model/comment/comment.dart';

class CommentDto {
  static const String artistIdKey = 'artistId';
  static const String textKey = 'text';
  static const String createAtKey = 'createdAt';

  static Comment fromJson(String id, Map<String, dynamic> json){
    return Comment(
      id: id,
      artistId:  json[artistIdKey] as String,
      text: json[textKey] as String,
      createdAt: DateTime.parse(json[createAtKey] as String),
    );
  }

  Map<String, dynamic> toJson(Comment c) => {
    artistIdKey: c.artistId,
    textKey: c.text,
    createAtKey: c.createdAt.toIso8601String(),
  };
}