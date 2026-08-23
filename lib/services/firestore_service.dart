import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Save a chat message to the 'chats' collection.
  static Future<void> saveChatMessage(
      String userId, String userMessage, String botReply) async {
    try {
      await _firestore.collection('chats').add({
        'userId': userId,
        'userMessage': userMessage,
        'botReply': botReply,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Log and swallow — chat flow must not break for Firestore failures.
      // ignore: avoid_print
      print('Failed to save chat message: $e');
    }
  }

  /// Returns a stream of chat documents for the given user sorted by timestamp.
  static Stream<QuerySnapshot> getChatHistory(String userId) {
    return _firestore
        .collection('chats')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp')
        .snapshots();
  }

  /// Save or update user profile data under collection 'users' and doc = userId
  /// with merge=true so existing fields are preserved.
  static Future<void> saveUserProfile(
      String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).set(data, SetOptions(merge: true));
    } catch (e) {
      // ignore: avoid_print
      print('Failed to save user profile: $e');
      rethrow; // caller may want to know about profile save failures
    }
  }
}
