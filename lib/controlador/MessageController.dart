import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessageController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String chatsCollection = 'chats';
  final String usersCollection = 'cliente';

  // Generar ID de chat único basado en IDs de usuario
  String generateChatId(String userId1, String userId2) {
    return userId1.hashCode <= userId2.hashCode
        ? '${userId1}_$userId2'
        : '${userId2}_$userId1';
  }

  // Obtener todos los usuarios (contactos)
  Stream<QuerySnapshot> getContacts() {
    return firestore.collection(usersCollection).snapshots();
  }

  // Obtener chats del usuario actual
  Stream<QuerySnapshot> getUserChats(String userId) {
    return firestore
        .collection(chatsCollection)
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  // Enviar mensaje
  Future<String?> sendMessage({
    required String receiverId,
    required String message,
    String type = 'text',
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      final chatId = generateChatId(currentUser.uid, receiverId);

      // Crear el mensaje
      final messageData = {
        'senderId': currentUser.uid,
        'receiverId': receiverId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'type': type,
        'isRead': false,
      };

      // Agregar mensaje a la subcolección
      final messageRef = await firestore
          .collection(chatsCollection)
          .doc(chatId)
          .collection('messages')
          .add(messageData);

      // Actualizar información del chat principal
      await firestore.collection(chatsCollection).doc(chatId).set({
        'participants': [currentUser.uid, receiverId],
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastSenderId': currentUser.uid,
      }, SetOptions(merge: true));

      print('✅ Mensaje enviado correctamente');
      return messageRef.id;
    } catch (e) {
      print('❌ Error enviando mensaje: $e');
      return null;
    }
  }

  // Marcar mensajes como leídos
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      final messages = await firestore
          .collection(chatsCollection)
          .doc(chatId)
          .collection('messages')
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = firestore.batch();
      for (var doc in messages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      print('Error marcando mensajes como leídos: $e');
    }
  }
}
