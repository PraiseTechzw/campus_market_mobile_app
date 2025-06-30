import 'package:cloud_firestore/cloud_firestore.dart';

class ChatEntity {
  final String id;
  final List<String> userIds;
  final String lastMessage;
  final DateTime timestamp;

  ChatEntity({
    required this.id,
    required this.userIds,
    required this.lastMessage,
    required this.timestamp,
  });

  factory ChatEntity.fromMap(Map<String, dynamic> map, String id) {
    final timestampRaw = map['timestamp'];
    DateTime ts;
    if (timestampRaw is Timestamp) {
      ts = timestampRaw.toDate();
    } else if (timestampRaw is DateTime) {
      ts = timestampRaw;
    } else {
      ts = DateTime.now();
    }
    return ChatEntity(
      id: id,
      userIds: List<String>.from(map['userIds'] ?? []),
      lastMessage: map['lastMessage'] ?? '',
      timestamp: ts,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userIds': userIds,
      'lastMessage': lastMessage,
      'timestamp': timestamp,
    };
  }
} 