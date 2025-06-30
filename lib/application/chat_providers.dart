import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../infrastructure/chat_repository.dart';
import '../domain/chat_entity.dart';
import '../domain/message_entity.dart';

// Provider for chat list stream
final chatListProvider = StreamProvider.family<List<ChatEntity>, String>((ref, userId) {
  return ref.watch(chatRepositoryProvider).fetchChats(userId);
});

// Provider for message list stream
final messageListProvider = StreamProvider.family<List<MessageEntity>, String>((ref, chatId) {
  return ref.watch(chatRepositoryProvider).fetchMessages(chatId);
});

// Provider for sending a message
final sendMessageProvider = FutureProvider.family<void, MessageEntity>((ref, message) async {
  await ref.watch(chatRepositoryProvider).sendMessage(message);
}); 