import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  String id;
  String senderId;
  String receiverId;
  String message;
  DateTime timestamp;
  String type;
  bool isRead;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    required this.type,
    required this.isRead,
  });

  MessageModel.empty()
      : id = '',
        senderId = '',
        receiverId = '',
        message = '',
        timestamp = DateTime.now(),
        type = 'text',
        isRead = false;

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type,
      'isRead': isRead,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map, String docId) {
    return MessageModel(
      id: docId,
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      message: map['message'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: map['type'] ?? 'text',
      isRead: map['isRead'] ?? false,
    );
  }
}
