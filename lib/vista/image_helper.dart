import 'dart:typed_data';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
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

// Función para subir imágenes a Firebase Storage (con sobreescritura)
  static Future<String> uploadImageToFirebase(XFile image, String path) async {
    Uint8List imageBytes = await getBytes(image);

    Reference storageReference = FirebaseStorage.instance.ref().child(path);

    UploadTask uploadTask = storageReference.putData(imageBytes);

    TaskSnapshot snapshot = await uploadTask;

    String downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  // Función para eliminar una imagen existente en Firebase Storage
  static Future<void> deleteImageFromFirebase(String path) async {
    Reference storageReference = FirebaseStorage.instance.ref().child(path);
    await storageReference.delete();
  }

  // Función para actualizar una imagen: primero eliminamos la vieja y luego subimos la nueva
  static Future<String> updateImage(XFile newImage, String path) async {
    await deleteImageFromFirebase(path);
    return await uploadImageToFirebase(newImage, path);
  }
}
