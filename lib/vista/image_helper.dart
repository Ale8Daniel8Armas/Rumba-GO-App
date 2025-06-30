import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageHelper {
  static Future<Uint8List> getBytes(XFile image) async {
    return await image.readAsBytes();
  }

  static Widget buildImageWidget(XFile? image,
      {double width = 80, double height = 80, BoxFit fit = BoxFit.cover}) {
    if (image == null) return Container(width: width, height: height);

    return FutureBuilder<Uint8List>(
      future: getBytes(image),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              snapshot.data!,
              width: width,
              height: height,
              fit: fit,
            ),
          );
        }
        return Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
