import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/comment_section.dart';
import '../widgets/image_gallery_screen.dart';
import '../widgets/post_content_widget.dart';
import 'auth_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;


class PostScreen extends StatefulWidget {
  final String? departureCode;
  final String? arrivalCode;
  final String? airlineCountry;
  final String? travelClass;
  final DateTime? travelDate;
  final double? rating;
  final String? message;
  final String? postId;
  final List<XFile> imageFiles;

  const PostScreen({
    super.key,
    this.departureCode,
    this.arrivalCode,
    this.airlineCountry,
    this.travelClass,
    this.travelDate,
    this.rating,
    this.message,
    this.postId,
    required this.imageFiles,
  });

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {

  bool _isLiked = false;
  int _likeCount = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(16),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserHeader(),
                const SizedBox(height: 12),
                _buildFlightInfoChips(),
                const SizedBox(height: 12),
                PostContentWidget(message: widget.message!,),
                const SizedBox(height: 12),
                _buildPostImage(),
                const SizedBox(height: 12),
                _buildEngagementRow(widget.postId ?? ""),
                CommentSection(postId: widget.postId!,)

              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildUserHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: (UserController.userData?.photoURL != null &&
              UserController.userData!.photoURL!.isNotEmpty)
              ? NetworkImage(UserController.userData!.photoURL!)
              : null,
          child: (UserController.userData?.photoURL == null ||
              UserController.userData!.photoURL!.isEmpty)
              ? Icon(Icons.person, size: 25)
              : null,
        ),

        const SizedBox(width: 12),

        Expanded(
          child:
          Text(UserController.userData!.displayName!,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        _buildRatingStars(widget.rating!),
      ],
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: [
        const Icon(Icons.star, color: Colors.amber, size: 20),
        const SizedBox(width: 4),
        Text(rating.toStringAsFixed(1),
            style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildFlightInfoChips() {
    return Wrap(
      spacing: 8,
      children: [
        Chip(label: Text(widget.departureCode ?? '')),
        Chip(label: Text(widget.airlineCountry ?? '')),
        Chip(label: Text(widget.travelClass ?? '')),
        Chip(
          label: Text(
            DateFormat('MMM yyyy').format(widget.travelDate!),
          ),
        ),
      ],
    );
  }

  //====================================like + comment count ====================================================

  Widget _buildEngagementRow(String postId) {
    return Row(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isLiked = !_isLiked;
              _likeCount += _isLiked ? 1 : -1;
            });
          },
          child: Row(
            children: [
              Icon(
                _isLiked ? Icons.thumb_up : Icons.thumb_up_off_alt,
                color: _isLiked ? Colors.blue : null,
              ),
              const SizedBox(width: 4),
              Text('$_likeCount Like'),
            ],
          ),
        ),
        const SizedBox(width: 16),
        FutureBuilder<int>(
          future: _getTotalCommentCount(postId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildEngagementItem(Icons.comment_outlined, "...");
            } else if (snapshot.hasError) {
              return _buildEngagementItem(Icons.comment_outlined, "0 Comment");
            } else {
              return _buildEngagementItem(
                Icons.comment_outlined,
                "${snapshot.data} Comment",
              );
            }
          },
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.share_outlined),
          onPressed: _sharePost,
        ),
      ],
    );
  }


  void _sharePost() {
    // Create a shareable message
    final String message = '''
${UserController.userData!.displayName} shared a flight experience:

✈️ ${widget.departureCode} → ${widget.arrivalCode}
⭐ Rating: ${widget.rating?.toStringAsFixed(1)}/5
🛩️ Airline: ${widget.airlineCountry}
🪑 Class: ${widget.travelClass}
📅 Date: ${DateFormat('MMM yyyy').format(widget.travelDate!)}

${widget.message!.isNotEmpty ? widget.message : ''}
''';

    // If there are images, share them too
    if (widget.imageFiles.isNotEmpty) {
      // Convert XFiles to Files and get their paths
      final imagePaths = widget.imageFiles.map((xfile) => xfile.path).toList();

      Share.shareXFiles(

        imagePaths.map((path) => XFile(path)).toList(),
        text: message,
        subject: 'Flight Experience Shared',
      );
    } else {
      Share.share(
        message,
        subject: 'Flight Experience Shared',
      );
    }
  }


  Widget _buildEngagementItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }


  Future<int> _getTotalCommentCount(String postId) async {
    final commentsSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .get();

    int total = commentsSnapshot.docs.length;

    for (var comment in commentsSnapshot.docs) {
      final repliesSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(comment.id)
          .collection('replies')
          .get();

      total += repliesSnapshot.docs.length;
    }

    return total;
  }


  //====================================like + comment count end ====================


  //===============================Image method=================================================

// For Firebase
/*

  Widget _buildPostImage() {
    if (widget.imageUrls.isEmpty) return Container();

    return Column(
      children: [
        if (widget.imageUrls.length == 1)
          GestureDetector(
            onTap: () => _openImageGallery(0),
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.imageUrls[0],
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.error),
                ),
              ),
            ),
          ),

        // 2 Images - Side by Side
        if (widget.imageUrls.length == 2)
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _openImageGallery(0),
                  child: AspectRatio(
                    aspectRatio: 245 / 492,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.imageUrls[0],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _openImageGallery(1),
                  child: AspectRatio(
                    aspectRatio: 245 / 492,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.imageUrls[1],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

        // 3 image - One large vertical image on the left,
        // two stacked smaller images on the right
        if (widget.imageUrls.length == 3)
          Row(
            children: [
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () => _openImageGallery(0),
                  child: AspectRatio(
                    aspectRatio: 332 / 500,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.imageUrls[0],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _openImageGallery(1),
                      child: AspectRatio(
                        aspectRatio: 166 / 249,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            widget.imageUrls[1],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _openImageGallery(2),
                      child: AspectRatio(
                        aspectRatio: 166 / 249,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            widget.imageUrls[2],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

        // 4 Images - Grid 2x2
        if (widget.imageUrls.length == 4)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _openImageGallery(index),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.imageUrls[index],
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),

        // 5+ images: 2 large on top, 3 small on bottom
        if (widget.imageUrls.length >= 5)
          Column(
            children: [
              //Top row: Two square images
              Row(
                children: [
                  for (int i = 0; i < 2; i++)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: i == 0 ? 8 : 0),
                        child: GestureDetector(
                          onTap: () => _openImageGallery(i),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Image.network(
                                widget.imageUrls[i],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 8),

              //Bottom row: Three small square images
              Row(
                children: List.generate(3, (index) {
                  int imgIndex = index + 2;
                  bool isLast = imgIndex == 4 && widget.imageUrls.length > 5;

                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: index < 2 ? 8 : 0),
                      child: GestureDetector(
                        onTap: () => _openImageGallery(imgIndex),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  widget.imageUrls[imgIndex],
                                  fit: BoxFit.cover,
                                ),
                                if (isLast)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black45,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '+${widget.imageUrls.length - 5}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
      ],
    );
  }




  void _openImageGallery(int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageGalleryScreen(
          imageUrls: widget.imageUrls, // প্যারামিটার নাম পরিবর্তন
          initialIndex: initialIndex,
        ),
      ),
    );
  }
*/


  //manual
  Widget _buildPostImage() {
    if (widget.imageFiles.isEmpty) return Container();

    return Column(
      children: [
        // 1 Image
        if (widget.imageFiles.length == 1)
          GestureDetector(
            onTap: () => _openImageGallery(0),
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(widget.imageFiles[0].path),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

        // 2 Images
        if (widget.imageFiles.length == 2)
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _openImageGallery(0),
                  child: AspectRatio(
                    aspectRatio: 245 / 492,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(widget.imageFiles[0].path),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _openImageGallery(1),
                  child: AspectRatio(
                    aspectRatio: 245 / 492,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(widget.imageFiles[1].path),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

        // 3 Images
        if (widget.imageFiles.length == 3)
          Row(
            children: [
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () => _openImageGallery(0),
                  child: AspectRatio(
                    aspectRatio: 332 / 500,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(widget.imageFiles[0].path),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _openImageGallery(1),
                      child: AspectRatio(
                        aspectRatio: 166 / 249,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(widget.imageFiles[1].path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _openImageGallery(2),
                      child: AspectRatio(
                        aspectRatio: 166 / 249,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(widget.imageFiles[2].path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

        // 4 Images
        if (widget.imageFiles.length == 4)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _openImageGallery(index),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(widget.imageFiles[index].path),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),

        // 5+ Images
        if (widget.imageFiles.length >= 5)
          Column(
            children: [
              Row(
                children: [
                  for (int i = 0; i < 2; i++)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: i == 0 ? 8 : 0),
                        child: GestureDetector(
                          onTap: () => _openImageGallery(i),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Image.file(
                                File(widget.imageFiles[i].path),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(3, (index) {
                  int imgIndex = index + 2;
                  bool isLast = imgIndex == 4 && widget.imageFiles.length > 5;

                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: index < 2 ? 8 : 0),
                      child: GestureDetector(
                        onTap: () => _openImageGallery(imgIndex),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(
                                  File(widget.imageFiles[imgIndex].path),
                                  fit: BoxFit.cover,
                                ),
                                if (isLast)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black45,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '+${widget.imageFiles.length - 5}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
      ],
    );
  }


  void _openImageGallery(int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ImageGalleryScreen(
              imageFiles: widget.imageFiles,
              initialIndex: initialIndex,
            ),
      ),
    );
  }


//===================================image method end==================================================

}





