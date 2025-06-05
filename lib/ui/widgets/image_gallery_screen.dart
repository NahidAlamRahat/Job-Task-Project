import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageGalleryScreen extends StatelessWidget {
  // final List<String> imageUrls;
  final List<XFile> imageFiles;

  final int initialIndex;

  const ImageGalleryScreen({
    super.key,
    // required this.imageUrls,
    required this.imageFiles,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: imageFiles.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            child: Center(
              child:

              //For Firebase
              /*Image.network(
                imageUrls[index],
                fit: BoxFit.contain,
              ),*/


              Image.file(
                File(imageFiles[index].path),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
              ),

            ),
          );
        },
      ),
    );
  }
}