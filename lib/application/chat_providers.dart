import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../infrastructure/chat_repository.dart';
import '../domain/chat_entity.dart';
import '../domain/message_entity.dart';
import '../domain/product_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Provider for chat repository
final chatRepositoryProvider = Provider<ChatRepository>((ref) => ChatRepository());

// Provider for user's chats
final userChatsProvider = StreamProvider<List<ChatEntity>>((ref) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.getUserChats();
});

// Provider for chat messages
final chatMessagesProvider = StreamProvider.family<List<MessageEntity>, String>((ref, chatId) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.getChatMessages(chatId);
});

// Provider for unread message count
final unreadCountProvider = StreamProvider<int>((ref) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.getUnreadCount();
});

// Provider for specific chat
final chatProvider = FutureProvider.family<ChatEntity?, String>((ref, chatId) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.getChatById(chatId);
});

// Provider for creating a new chat
final createChatProvider = FutureProvider.family<String, Map<String, dynamic>>((ref, data) {
  final repo = ref.watch(chatRepositoryProvider);
  final product = data['product'] as ProductEntity;
  final sellerId = data['sellerId'] as String;
  final sellerName = data['sellerName'] as String;
  return repo.createChat(product, sellerId, sellerName);
});

// Provider for sending a message
final sendMessageProvider = FutureProvider.family<void, Map<String, dynamic>>((ref, data) {
  final repo = ref.watch(chatRepositoryProvider);
  final chatId = data['chatId'] as String;
  final content = data['content'] as String;
  final messageType = data['messageType'] as String? ?? 'text';
  final metadata = data['metadata'] as Map<String, dynamic>?;
  return repo.sendMessage(chatId, content, messageType: messageType, metadata: metadata);
});

// Provider for marking messages as read
final markMessagesAsReadProvider = FutureProvider.family<void, String>((ref, chatId) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.markMessagesAsRead(chatId);
});

// Provider for sending an offer
final sendOfferProvider = FutureProvider.family<void, Map<String, dynamic>>((ref, data) {
  final repo = ref.watch(chatRepositoryProvider);
  final chatId = data['chatId'] as String;
  final offerAmount = data['offerAmount'] as double;
  final message = data['message'] as String;
  return repo.sendOffer(chatId, offerAmount, message);
});

// Provider for sending location
final sendLocationProvider = FutureProvider.family<void, Map<String, dynamic>>((ref, data) {
  final repo = ref.watch(chatRepositoryProvider);
  final chatId = data['chatId'] as String;
  final latitude = data['latitude'] as double;
  final longitude = data['longitude'] as double;
  final address = data['address'] as String;
  return repo.sendLocation(chatId, latitude, longitude, address);
});

// Provider for responding to offers
final respondToOfferProvider = FutureProvider.family<void, Map<String, dynamic>>((ref, data) {
  final repo = ref.watch(chatRepositoryProvider);
  final chatId = data['chatId'] as String;
  final messageId = data['messageId'] as String;
  final accepted = data['accepted'] as bool;
  return repo.respondToOffer(chatId, messageId, accepted);
});

// Provider for deleting a chat
final deleteChatProvider = FutureProvider.family<void, String>((ref, chatId) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.deleteChat(chatId);
});

// Provider for current user ID
final currentUserIdProvider = Provider<String?>((ref) {
  return FirebaseAuth.instance.currentUser?.uid;
});

// Provider for checking if user is in a chat
final isUserInChatProvider = Provider.family<bool, ChatEntity>((ref, chat) {
  final currentUserId = ref.watch(currentUserIdProvider);
  if (currentUserId == null) return false;
  return chat.buyerId == currentUserId || chat.sellerId == currentUserId;
});

// Provider for getting the other user's info in a chat
final otherUserInfoProvider = Provider.family<Map<String, String>, ChatEntity>((ref, chat) {
  final currentUserId = ref.watch(currentUserIdProvider);
  if (currentUserId == null) return {};
  
  if (chat.buyerId == currentUserId) {
    return {
      'id': chat.sellerId,
      'name': chat.sellerName,
      'avatar': chat.sellerAvatar,
    };
  } else {
    return {
      'id': chat.buyerId,
      'name': chat.buyerName,
      'avatar': chat.buyerAvatar,
    };
  }
});

// Provider for blocking a user
final blockUserProvider = FutureProvider.family<void, String>((ref, userIdToBlock) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.blockUser(userIdToBlock);
});

// Provider for reporting a user
final reportUserProvider = FutureProvider.family<void, Map<String, String>>((ref, data) {
  final repo = ref.watch(chatRepositoryProvider);
  final reportedUserId = data['reportedUserId']!;
  final reason = data['reason']!;
  final details = data['details']!;
  return repo.reportUser(reportedUserId, reason, details);
});

// Provider for checking if user is blocked
final isUserBlockedProvider = FutureProvider.family<bool, String>((ref, otherUserId) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.isUserBlocked(otherUserId);
}); 