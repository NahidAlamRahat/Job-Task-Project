class CommentModel {
  final String userName;
  final String comment;
  final DateTime time;
  int likes;
  List<ReplyModel> replies;

  CommentModel({
    required this.userName,
    required this.comment,
    required this.time,
    this.likes = 0,
    this.replies = const [],
  });
}

class ReplyModel {
  final String userName;
  final String replyText;
  final DateTime time;

  ReplyModel({
    required this.userName,
    required this.replyText,
    required this.time,
  });
}