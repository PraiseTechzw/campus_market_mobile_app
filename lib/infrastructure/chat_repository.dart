import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../domain/chat_entity.dart';
import '../domain/message_entity.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) => ChatRepository());

class ChatRepository {
  final _chats = FirebaseFirestore.instance.collection('chats');
  final _messages = FirebaseFirestore.instance.collection('messages');

  // Fetch all chats for a user
  Stream<List<ChatEntity>> fetchChats(String userId) {
    return _chats.where('userIds', arrayContains: userId).orderBy('timestamp', descending: true).snapshots().map(
      (snap) => snap.docs.map((doc) => ChatEntity.fromMap(doc.data(), doc.id)).toList(),
    );
  }

  // Fetch messages for a chat
  Stream<List<MessageEntity>> fetchMessages(String chatId) {
    return _messages.where('chatId', isEqualTo: chatId).orderBy('timestamp').snapshots().map(
      (snap) => snap.docs.map((doc) => MessageEntity.fromMap(doc.data(), doc.id)).toList(),
    );
  }

  // Send a message
  Future<void> sendMessage(MessageEntity message) async {
    await _messages.add(message.toMap());
    // Update last message in chat
    await _chats.doc(message.chatId).update({
      'lastMessage': message.text ?? '[Image]',
      'timestamp': message.timestamp,
    });
  }

  // Create a chat
  Future<String> createChat(List<String> userIds) async {
    final doc = await _chats.add({
      'userIds': userIds,
      'lastMessage': '',
      'timestamp': DateTime.now(),
    });
    return doc.id;
  }
}
