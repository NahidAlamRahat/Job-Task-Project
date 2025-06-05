import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PostContentWidget extends StatefulWidget {
  final String message;

  const PostContentWidget({Key? key, required this.message}) : super(key: key);

  @override
  State<PostContentWidget> createState() => _PostContentWidgetState();
}

class _PostContentWidgetState extends State<PostContentWidget> {
  bool _isExpanded = false;
  final int _maxLines = 3;

  @override
  Widget build(BuildContext context) {
    return _buildPostContent();
  }

  Widget _buildPostContent() {
    final textSpan = TextSpan(text: widget.message);
    final textPainter = TextPainter(
      text: textSpan,
      maxLines: _maxLines,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: MediaQuery.of(context).size.width);

    final isOverflowing = textPainter.didExceedMaxLines;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.message,
          maxLines: _isExpanded ? null : _maxLines,
          overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: TextStyle(color: Colors.black87),
        ),
        if (isOverflowing)
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Text(
              _isExpanded ? "See Less" : "See More",
              style: TextStyle(color: Colors.blue),
            ),
          ),
      ],
    );
  }
}
