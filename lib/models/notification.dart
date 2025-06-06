import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String userId;
  final String message;
  final DateTime timestamp;

  AppNotification({
    required this.id,
    required this.userId,
    required this.message,
    required this.timestamp,
  });

  factory AppNotification.fromMap(Map<String, dynamic> data, String documentId) {
    return AppNotification(
      id: documentId,
      userId: data['userId'],
      message: data['message'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}
