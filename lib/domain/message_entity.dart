import 'package:cloud_firestore/cloud_firestore.dart';

class MessageEntity {
  final String id;
  final String chatId;
  final String senderId;
  final String? text;
  final String? imageUrl;
  final DateTime timestamp;

  MessageEntity({
    required this.id,
    required this.chatId,
    required this.senderId,
    this.text,
    this.imageUrl,
    required this.timestamp,
  });

  factory MessageEntity.fromMap(Map<String, dynamic> map, String id) {
    final timestampRaw = map['timestamp'];
    DateTime ts;
    if (timestampRaw is Timestamp) {
      ts = timestampRaw.toDate();
    } else if (timestampRaw is DateTime) {
      ts = timestampRaw;
    } else {
      ts = DateTime.now();
    }
    return MessageEntity(
      id: id,
      chatId: map['chatId'] ?? '',
      senderId: map['senderId'] ?? '',
      text: map['text'],
      imageUrl: map['imageUrl'],
      timestamp: ts,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': timestamp,
    };
  }
} 