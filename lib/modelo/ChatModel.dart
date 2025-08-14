import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  String id;
  List<String> participants;
  String lastMessage;
  DateTime lastMessageTime;
  String lastSenderId;

  ChatModel({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.lastSenderId,
  });

  ChatModel.empty()
      : id = '',
        participants = [],
        lastMessage = '',
        lastMessageTime = DateTime.now(),
        lastSenderId = '';

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'lastSenderId': lastSenderId,
    };
  }

  factory ChatModel.fromMap(Map<String, dynamic> map, String docId) {
    return ChatModel(
      id: docId,
      participants: List<String>.from(map['participants'] ?? []),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime:
          (map['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastSenderId: map['lastSenderId'] ?? '',
    );
  }
}
