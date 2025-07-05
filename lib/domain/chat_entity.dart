import 'package:cloud_firestore/cloud_firestore.dart';

class ChatEntity {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final double productPrice;
  final String buyerId;
  final String sellerId;
  final String buyerName;
  final String sellerName;
  final String buyerAvatar;
  final String sellerAvatar;
  final DateTime lastMessageTime;
  final String lastMessage;
  final String lastMessageSenderId;
  final int unreadCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatEntity({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.productPrice,
    required this.buyerId,
    required this.sellerId,
    required this.buyerName,
    required this.sellerName,
    this.buyerAvatar = '',
    this.sellerAvatar = '',
    required this.lastMessageTime,
    this.lastMessage = '',
    this.lastMessageSenderId = '',
    this.unreadCount = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatEntity.fromMap(Map<String, dynamic> map, String id) {
    return ChatEntity(
      id: id,
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productImage: map['productImage'] ?? '',
      productPrice: (map['productPrice'] ?? 0).toDouble(),
      buyerId: map['buyerId'] ?? '',
      sellerId: map['sellerId'] ?? '',
      buyerName: map['buyerName'] ?? '',
      sellerName: map['sellerName'] ?? '',
      buyerAvatar: map['buyerAvatar'] ?? '',
      sellerAvatar: map['sellerAvatar'] ?? '',
      lastMessageTime: (map['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageSenderId: map['lastMessageSenderId'] ?? '',
      unreadCount: map['unreadCount'] ?? 0,
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'productPrice': productPrice,
      'buyerId': buyerId,
      'sellerId': sellerId,
      'buyerName': buyerName,
      'sellerName': sellerName,
      'buyerAvatar': buyerAvatar,
      'sellerAvatar': sellerAvatar,
      'lastMessageTime': lastMessageTime,
      'lastMessage': lastMessage,
      'lastMessageSenderId': lastMessageSenderId,
      'unreadCount': unreadCount,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  ChatEntity copyWith({
    String? id,
    String? productId,
    String? productName,
    String? productImage,
    double? productPrice,
    String? buyerId,
    String? sellerId,
    String? buyerName,
    String? sellerName,
    String? buyerAvatar,
    String? sellerAvatar,
    DateTime? lastMessageTime,
    String? lastMessage,
    String? lastMessageSenderId,
    int? unreadCount,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatEntity(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      productPrice: productPrice ?? this.productPrice,
      buyerId: buyerId ?? this.buyerId,
      sellerId: sellerId ?? this.sellerId,
      buyerName: buyerName ?? this.buyerName,
      sellerName: sellerName ?? this.sellerName,
      buyerAvatar: buyerAvatar ?? this.buyerAvatar,
      sellerAvatar: sellerAvatar ?? this.sellerAvatar,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      unreadCount: unreadCount ?? this.unreadCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 