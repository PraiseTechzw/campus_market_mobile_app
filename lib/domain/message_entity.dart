import 'package:cloud_firestore/cloud_firestore.dart';

class MessageEntity {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final String content;
  final String messageType; // text, image, offer, location
  final Map<String, dynamic>? metadata; // for offers, locations, etc.
  final bool isRead;
  final DateTime timestamp;
  final DateTime? readAt;

  MessageEntity({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar = '',
    required this.content,
    this.messageType = 'text',
    this.metadata,
    this.isRead = false,
    required this.timestamp,
    this.readAt,
  });

  factory MessageEntity.fromMap(Map<String, dynamic> map, String id) {
    return MessageEntity(
      id: id,
      chatId: map['chatId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderAvatar: map['senderAvatar'] ?? '',
      content: map['content'] ?? '',
      messageType: map['messageType'] ?? 'text',
      metadata: map['metadata'],
      isRead: map['isRead'] ?? false,
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readAt: (map['readAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'content': content,
      'messageType': messageType,
      'metadata': metadata,
      'isRead': isRead,
      'timestamp': timestamp,
      'readAt': readAt,
    };
  }

  MessageEntity copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    String? content,
    String? messageType,
    Map<String, dynamic>? metadata,
    bool? isRead,
    DateTime? timestamp,
    DateTime? readAt,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      metadata: metadata ?? this.metadata,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp ?? this.timestamp,
      readAt: readAt ?? this.readAt,
    );
  }

  // Helper methods for different message types
  bool get isOffer => messageType == 'offer';
  bool get isLocation => messageType == 'location';
  bool get isImage => messageType == 'image';
  bool get isText => messageType == 'text';

  // Get offer details if this is an offer message
  Map<String, dynamic>? get offerDetails => isOffer ? metadata : null;
  
  // Get location details if this is a location message
  Map<String, dynamic>? get locationDetails => isLocation ? metadata : null;
} 