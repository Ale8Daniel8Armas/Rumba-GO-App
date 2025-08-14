import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../modelo/ReviewModel.dart';

class ReviewController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String collection = 'reviews';

  // Opciones de categorías
  final List<Map<String, dynamic>> musicOptions = [
    {'label': 'Rock', 'selected': false},
    {'label': 'Pop', 'selected': false},
    {'label': 'Música Nacional', 'selected': false},
    {'label': 'Salsa', 'selected': false},
    {'label': 'Electrónica', 'selected': false},
    {'label': 'Jazz', 'selected': false},
    {'label': 'Cumbia', 'selected': false},
    {'label': 'Caribe', 'selected': false},
    {'label': 'Clásica', 'selected': false},
    {'label': 'Reggaetón', 'selected': false},
    {'label': 'Rap', 'selected': false},
  ];

  final List<Map<String, dynamic>> ambienceOptions = [
    {'label': 'Tranquilo', 'selected': false},
    {'label': 'Animado', 'selected': false},
    {'label': 'Elegante', 'selected': false},
    {'label': 'Informal', 'selected': false},
    {'label': 'Romántico', 'selected': false},
    {'label': 'Familiar', 'selected': false},
  ];

  final List<Map<String, dynamic>> drinksOptions = [
    {'label': 'Cerveza', 'selected': false},
    {'label': 'Cócteles', 'selected': false},
    {'label': 'Whisky', 'selected': false},
    {'label': 'Tequila', 'selected': false},
    {'label': 'Vino', 'selected': false},
    {'label': 'Café', 'selected': false},
    {'label': 'Sin alcohol', 'selected': false},
    {'label': 'Gin', 'selected': false},
  ];

  Future<String?> agregarReview(
    ReviewModel review, {
    List<XFile>? imagenes,
  }) async {
    try {
      final errores = validarFormulario(review);
      if (errores.isNotEmpty) {
        throw Exception(errores.join('\n'));
      }

      final data = Map<String, dynamic>.from(review.toMap());

      data['createdAt'] = FieldValue.serverTimestamp();

      if (review.fecha.trim().isNotEmpty) {
        try {
          final dt = DateFormat('dd/MM/yyyy').parse(review.fecha.trim());
          data['fecha_ts'] = Timestamp.fromDate(dt);
        } catch (_) {
          // si no se puede parsear, lo omitimos
        }
      }

      final docRef = await _firestore.collection(collection).add(data);

      if (imagenes != null && imagenes.isNotEmpty) {
        final urls = await subirImagenesReview(imagenes, docRef.id);
        if (urls.isNotEmpty) {
          await docRef.update({
            'fotosUrls': FieldValue.arrayUnion(urls),
          });
        }
      }

      print('✅ Reseña agregada correctamente con ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error al agregar reseña: $e');
      return null;
    }
  }

  Future<List<String>> subirImagenesReview(
      List<XFile> imagenes, String reviewId) async {
    final List<String> urls = [];

    for (int i = 0; i < imagenes.length; i++) {
      try {
        Uint8List bytes = await imagenes[i].readAsBytes();
        final String path = 'reviews/$reviewId/foto_$i.jpg';

        final ref = _storage.ref().child(path);
        final uploadTask = ref.putData(bytes);
        final snapshot = await uploadTask;
        final downloadURL = await snapshot.ref.getDownloadURL();

        urls.add(downloadURL);
        print('✅ Imagen subida: $downloadURL');
      } catch (e) {
        print('❌ Error al subir imagen $i: $e');
      }
    }

    return urls;
  }

  Future<List<ReviewModel>> obtenerReviewsPorLocal(String lugar_nombre) async {
    try {
      final snapshot = await _firestore
          .collection(collection)
          .where('lugar_nombre', isEqualTo: lugar_nombre)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      try {
        final snapshot = await _firestore
            .collection(collection)
            .where('lugar_nombre', isEqualTo: lugar_nombre)
            .get();

        return snapshot.docs
            .map((doc) => ReviewModel.fromMap(doc.data()))
            .toList();
      } catch (e2) {
        print('❌ Error al obtener reseñas: $e2');
        return [];
      }
    }
  }

  Future<List<ReviewModel>> obtenerReviewsPorUsuario(
      String usuario_nombre) async {
    try {
      final snapshot = await _firestore
          .collection(collection)
          .where('usuario_nombre', isEqualTo: usuario_nombre)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      try {
        final snapshot = await _firestore
            .collection(collection)
            .where('usuario_nombre', isEqualTo: usuario_nombre)
            .get();

        return snapshot.docs
            .map((doc) => ReviewModel.fromMap(doc.data()))
            .toList();
      } catch (e2) {
        print('❌ Error al obtener reseñas del usuario: $e2');
        return [];
      }
    }
  }

  Future<double> calcularPromedioCalificacion(String lugar_nombre) async {
    try {
      final reviews = await obtenerReviewsPorLocal(lugar_nombre);
      if (reviews.isEmpty) return 0.0;

      final total =
          reviews.fold<double>(0.0, (sum, item) => sum + (item.calificacion));
      return total / reviews.length;
    } catch (e) {
      print('❌ Error al calcular promedio: $e');
      return 0.0;
    }
  }

  Future<void> actualizarReview(String reviewId, ReviewModel review) async {
    try {
      await _firestore
          .collection(collection)
          .doc(reviewId)
          .update(review.toMap());
      print('✅ Reseña actualizada correctamente');
    } catch (e) {
      print('❌ Error al actualizar reseña: $e');
    }
  }

  Future<void> eliminarReview(String reviewId) async {
    try {
      await _firestore.collection(collection).doc(reviewId).delete();
      print('✅ Reseña eliminada correctamente');
    } catch (e) {
      print('❌ Error al eliminar reseña: $e');
    }
  }

  List<String> validarFormulario(ReviewModel review) {
    final errores = <String>[];

    if (review.usuario_nombre.trim().isEmpty) {
      errores.add('El nombre de usuario es obligatorio.');
    }
    if (review.lugar_nombre.trim().isEmpty) {
      errores.add('El nombre del lugar es obligatorio.');
    }
    if (review.calificacion < 1 || review.calificacion > 5) {
      errores.add('La calificación debe estar entre 1 y 5.');
    }
    if (review.comentario.trim().isEmpty) {
      errores.add('El comentario no puede estar vacío.');
    }
    if (review.categoriasMusicales.isEmpty) {
      errores.add('Selecciona al menos un tipo de música.');
    }
    if (review.categoriasAmbiente.isEmpty) {
      errores.add('Selecciona al menos un tipo de ambiente.');
    }
    if (review.categoriasBebidas.isEmpty) {
      errores.add('Selecciona al menos una bebida.');
    }

    return errores;
  }

  List<String> obtenerEtiquetasSeleccionadas(
      List<Map<String, dynamic>> opciones) {
    return opciones
        .where((o) => o['selected'] == true)
        .map((o) => (o['label'] as String))
        .toList();
  }

  Future<List<ReviewModel>> getAllReviews() async {
    try {
      final qs = await _firestore
          .collection(collection)
          .orderBy('createdAt', descending: true)
          .get();

      return qs.docs.map((d) => ReviewModel.fromMap(d.data())).toList();
    } catch (e) {
      final qs = await _firestore.collection(collection).get();
      return qs.docs.map((d) => ReviewModel.fromMap(d.data())).toList();
    }
  }
}
