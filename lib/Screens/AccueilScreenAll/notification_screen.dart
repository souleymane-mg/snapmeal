import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/notification.dart' as model;


class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getUserNotifications(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Erreur : ${snapshot.error}');
            return Center(child: Text('Une erreur est survenue'));
          }

          if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          List<model.AppNotification> notifications = snapshot.data!.docs.map((doc) {
            print('Notification data: ${doc.data()}'); // Ajouter une impression pour vérifier les données
            return model.AppNotification.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

          if (notifications.isEmpty) {
            return Center(child: Text('Aucune notification trouvée.'));
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              model.AppNotification notification = notifications[index];
              return ListTile(
                title: Text(notification.message),
                subtitle: Text(notification.timestamp.toString()),
              );
            },
          );
        },
      ),
    );
  }

  Stream<QuerySnapshot> _getUserNotifications() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .snapshots();
    } else {
      return Stream.empty();
    }
  }
}
