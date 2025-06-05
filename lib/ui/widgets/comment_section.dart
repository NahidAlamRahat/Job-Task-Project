import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:job_task/ui/screen/auth_screen.dart';

class CommentSection extends StatefulWidget {
  final String postId;

  const CommentSection({super.key, required this.postId});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();
  String? replyingToCommentId;

  Future<void> addComment(String text, String user) async {
    if (text
        .trim()
        .isEmpty) return;
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .add({
      'text': text,
      'user': user,
      'likes': 0,
      'timestamp': FieldValue.serverTimestamp(),
    });
    _commentController.clear();
  }

  Future<void> addReply(String commentId, String text, String user) async {
    if (text
        .trim()
        .isEmpty) return;
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .doc(commentId)
        .collection('replies')
        .add({
      'text': text,
      'user': user,
      'timestamp': FieldValue.serverTimestamp(),
    });
    _replyController.clear();
    setState(() {
      replyingToCommentId = null;
    });
  }

  Widget commentInputField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: replyingToCommentId == null
                ? _commentController
                : _replyController,
            decoration: InputDecoration(
              hintText: replyingToCommentId == null
                  ? 'Write a comment...'
                  : 'Write a reply...',
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: () {
            if (replyingToCommentId == null) {
              addComment(_commentController.text,
                  UserController.userData!.displayName!);
            } else {
              addReply(replyingToCommentId!, _replyController.text,
                  UserController.userData!.displayName!);
            }
          },
        ),
      ],
    );
  }

  Widget buildReplies(String commentId) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .orderBy('timestamp')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final replies = snapshot.data!.docs;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: replies.map((reply) {
            return Padding(
              padding: const EdgeInsets.only(left: 32.0, top: 4),
              child: Text("↳ ${reply['user']}: ${reply['text']}"),
            );
          }).toList(),
        );
      },
    );
  }

  Widget buildCommentList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .orderBy('timestamp')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final comments = snapshot.data!.docs;
        return ListView.builder(
          itemCount: comments.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final comment = comments[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text("${comment['user']}: ${comment['text']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.favorite_border),
                        onPressed: () {
                          // Add like functionality here
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.reply),
                        onPressed: () {
                          setState(() {
                            replyingToCommentId = comment.id;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                buildReplies(comment.id),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildCommentList(),
        const SizedBox(height: 8),
        commentInputField(),
      ],
    );
  }
}