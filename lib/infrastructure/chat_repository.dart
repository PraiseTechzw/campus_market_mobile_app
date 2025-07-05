import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../domain/chat_entity.dart';
import '../domain/message_entity.dart';
import '../domain/product_entity.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) => ChatRepository());

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Stream of user's chats
  Stream<List<ChatEntity>> getUserChats() {
    final userId = currentUserId;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('chats')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((doc) {
              final data = doc.data();
              return data['buyerId'] == userId || data['sellerId'] == userId;
            })
            .map((doc) => ChatEntity.fromMap(doc.data(), doc.id))
            .toList()
            ..sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime)));
  }

  // Stream of messages for a specific chat
  Stream<List<MessageEntity>> getChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageEntity.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Create a new chat
  Future<String> createChat(ProductEntity product, String sellerId, String sellerName) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    // Check if chat already exists - using a simpler query to avoid composite index
    final existingChats = await _firestore
        .collection('chats')
        .where('productId', isEqualTo: product.id)
        .where('buyerId', isEqualTo: userId)
        .get();

    // Filter in memory to check for seller match
    final existingChat = existingChats.docs.where((doc) {
      final data = doc.data();
      return data['sellerId'] == sellerId && data['isActive'] == true;
    }).firstOrNull;

    if (existingChat != null) {
      return existingChat.id;
    }

    // Get current user data
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final userData = userDoc.data() ?? {};

    // Create new chat
    final chatRef = await _firestore.collection('chats').add({
      'productId': product.id,
      'productName': product.name,
      'productImage': product.imageUrl,
      'productPrice': product.price,
      'buyerId': userId,
      'sellerId': sellerId,
      'buyerName': userData['name'] ?? 'Unknown',
      'sellerName': sellerName,
      'buyerAvatar': userData['selfieUrl'] ?? '',
      'sellerAvatar': '', // Will be updated when seller data is fetched
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessage': '',
      'lastMessageSenderId': '',
      'unreadCount': 0,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return chatRef.id;
  }

  // Create a direct chat between users (for accommodation inquiries)
  Future<String> createDirectChat(String otherUserId, String otherUserName, String initialMessage) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    // Check if chat already exists
    final existingChats = await _firestore
        .collection('chats')
        .where('buyerId', isEqualTo: userId)
        .where('sellerId', isEqualTo: otherUserId)
        .get();

    // Filter in memory to check for active chats
    final existingChat = existingChats.docs.where((doc) {
      final data = doc.data();
      return data['isActive'] == true && data['productId'] == null;
    }).firstOrNull;

    if (existingChat != null) {
      // Send the initial message to existing chat
      await sendMessage(existingChat.id, initialMessage);
      return existingChat.id;
    }

    // Get current user data
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final userData = userDoc.data() ?? {};

    // Create new direct chat
    final chatRef = await _firestore.collection('chats').add({
      'productId': null, // No product for direct chats
      'productName': null,
      'productImage': null,
      'productPrice': null,
      'buyerId': userId,
      'sellerId': otherUserId,
      'buyerName': userData['name'] ?? 'Unknown',
      'sellerName': otherUserName,
      'buyerAvatar': userData['selfieUrl'] ?? '',
      'sellerAvatar': '', // Will be updated when seller data is fetched
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessage': initialMessage,
      'lastMessageSenderId': userId,
      'unreadCount': 1, // Other user has 1 unread message
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Send the initial message
    await sendMessage(chatRef.id, initialMessage);

    return chatRef.id;
  }

  // Send a message
  Future<void> sendMessage(String chatId, String content, {String messageType = 'text', Map<String, dynamic>? metadata}) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    // Get current user data
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final userData = userDoc.data() ?? {};

    // Create message
    final message = {
      'chatId': chatId,
      'senderId': userId,
      'senderName': userData['name'] ?? 'Unknown',
      'senderAvatar': userData['selfieUrl'] ?? '',
      'content': content,
      'messageType': messageType,
      'metadata': metadata,
      'isRead': false,
      'timestamp': FieldValue.serverTimestamp(),
    };

    // Add message to chat
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message);

    // Update chat with last message info
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': content,
      'lastMessageSenderId': userId,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Increment unread count for other user
    final chatDoc = await _firestore.collection('chats').doc(chatId).get();
    final chatData = chatDoc.data();
    if (chatData != null) {
      final otherUserId = chatData['buyerId'] == userId ? chatData['sellerId'] : chatData['buyerId'];
      await _firestore.collection('chats').doc(chatId).update({
        'unreadCount': FieldValue.increment(1),
      });
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatId) async {
    final userId = currentUserId;
    if (userId == null) return;

    // Get unread messages
    final unreadMessages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('senderId', isNotEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    // Mark them as read
    final batch = _firestore.batch();
    for (final doc in unreadMessages.docs) {
      batch.update(doc.reference, {
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    }

    // Reset unread count
    batch.update(_firestore.collection('chats').doc(chatId), {
      'unreadCount': 0,
    });

    await batch.commit();
  }

  // Send an offer
  Future<void> sendOffer(String chatId, double offerAmount, String message) async {
    final metadata = {
      'offerAmount': offerAmount,
      'status': 'pending', // pending, accepted, rejected
      'timestamp': DateTime.now().toIso8601String(),
    };

    await sendMessage(
      chatId,
      message,
      messageType: 'offer',
      metadata: metadata,
    );
  }

  // Send location
  Future<void> sendLocation(String chatId, double latitude, double longitude, String address) async {
    final metadata = {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await sendMessage(
      chatId,
      '📍 $address',
      messageType: 'location',
      metadata: metadata,
    );
  }

  // Accept or reject offer
  Future<void> respondToOffer(String chatId, String messageId, bool accepted) async {
    final messageRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId);

    await messageRef.update({
      'metadata.status': accepted ? 'accepted' : 'rejected',
    });

    // Send response message
    final response = accepted ? '✅ Offer accepted!' : '❌ Offer declined';
    await sendMessage(chatId, response);
  }

  // Delete chat
  Future<void> deleteChat(String chatId) async {
    await _firestore.collection('chats').doc(chatId).update({
      'isActive': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Get chat by ID
  Future<ChatEntity?> getChatById(String chatId) async {
    final doc = await _firestore.collection('chats').doc(chatId).get();
    if (doc.exists) {
      return ChatEntity.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // Get unread count for user
  Stream<int> getUnreadCount() {
    final userId = currentUserId;
    if (userId == null) return Stream.value(0);

    return _firestore
        .collection('chats')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .where((doc) {
              final data = doc.data();
              return data['buyerId'] == userId || data['sellerId'] == userId;
            })
            .fold<int>(0, (sum, doc) => sum + (doc.data()['unreadCount'] as int? ?? 0)));
  }

  // Block a user
  Future<void> blockUser(String userIdToBlock) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    await _firestore.collection('users').doc(userId).update({
      'blockedUsers': FieldValue.arrayUnion([userIdToBlock]),
    });
  }

  // Report a user
  Future<void> reportUser(String reportedUserId, String reason, String details) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    await _firestore.collection('reports').add({
      'reporterId': userId,
      'reportedUserId': reportedUserId,
      'reason': reason,
      'details': details,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Check if user is blocked
  Future<bool> isUserBlocked(String otherUserId) async {
    final userId = currentUserId;
    if (userId == null) return false;

    final userDoc = await _firestore.collection('users').doc(userId).get();
    final userData = userDoc.data();
    final blockedUsers = List<String>.from(userData?['blockedUsers'] ?? []);
    
    return blockedUsers.contains(otherUserId);
  }
}
