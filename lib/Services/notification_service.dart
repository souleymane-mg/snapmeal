import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  NotificationService() {
    _initializeNotifications();
    _listenForAnnouncements();
    _listenForAppointments();
    _configureLocalTimeZone();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap
      },
    );
  }

  void _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/London')); // Adjust according to your local timezone
  }

  void _listenForAnnouncements() {
    _firestore.collection('Annonces').snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final announcementData = change.doc.data() as Map<String, dynamic>?;
          if (announcementData != null) {
            _checkAnnouncementTimeAndNotify(announcementData, change.doc.id);
          }
        }
      }
    });
  }

  void _checkAnnouncementTimeAndNotify(Map<String, dynamic> announcementData, String docId) {
    final now = DateTime.now();
    final date = announcementData['date_contenu'];
    final time = announcementData['heure_annonce'];

    final announcementDateTime = DateTime.parse('$date $time');

    if (now.isBefore(announcementDateTime.add(Duration(hours: 1)))) {
      _showAnnouncementNotification(announcementData, docId);
    }
  }

  void _listenForAppointments() {
    _firestore.collection('rdv').snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.modified) {
          final data = change.doc.data() as Map<String, dynamic>?;
          if (data != null) {
            final cancelledBy = data['cancelledBy'];
            final currentUserId = "3bTlavgVRIegtbPtisEAJXqAQiC2"; // Replace with the current user's ID

            if (cancelledBy != null && cancelledBy == currentUserId) {
              _showCancellationNotification(data, change.doc.id);
            } else {
              _scheduleAppointmentNotifications(data, change.doc.id);
            }
          }
        }
      }
    });
  }

  Future<void> _showAnnouncementNotification(Map<String, dynamic> announcementData, String docId) async {
    String imageUrl = announcementData['image_contenu'] ?? '';
    if (imageUrl.isNotEmpty) {
      try {
        final http.Response response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          final Uint8List imageBytes = response.bodyBytes;

          final BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(
            ByteArrayAndroidBitmap(imageBytes),
            largeIcon: ByteArrayAndroidBitmap(imageBytes),
            contentTitle: announcementData['titre_annonce'] ?? 'Nouvelle annonce',
            summaryText: 'par ${announcementData['auteur_post'] ?? 'Auteur inconnu'}',
          );

          final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
            'your_channel_id',
            'your_channel_name',
            channelDescription: 'your_channel_description',
            importance: Importance.max,
            priority: Priority.high,
            styleInformation: bigPictureStyleInformation,
          );

          final NotificationDetails platformChannelSpecifics = NotificationDetails(
            android: androidPlatformChannelSpecifics,
          );

          await _flutterLocalNotificationsPlugin.show(
            0,
            announcementData['titre_annonce'] ?? 'Nouvelle annonce',
            'par ${announcementData['auteur_post'] ?? 'Auteur inconnu'}',
            platformChannelSpecifics,
            payload: docId,
          );
        }
      } catch (e) {
        print('Error loading image: $e');
      }
    }
  }

  Future<void> _showCancellationNotification(Map<String, dynamic> appointmentData, String docId) async {
    final String title = 'Rendez-vous annulé';
    final String body = 'Le rendez-vous avec ${appointmentData['nom_medecin_rdv']} a été annulé.';

    final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: docId,
    );
  }

  Future<void> _scheduleAppointmentNotifications(Map<String, dynamic> appointmentData, String docId) async {
    final dateString = appointmentData['date_rdv'] as String;
    final timeString = '${appointmentData['heure_debut']} - ${appointmentData['heure_fin']}';
    final title = 'Rendez-vous à venir';
    final body = 'Votre rendez-vous avec ${appointmentData['nom_medecin_rdv']} est prévu le $dateString de $timeString.';

    final notificationTimes = [
      Duration(hours: 24), // 24 hours before
      Duration(hours: 12), // 12 hours before
      Duration(hours: 3),  // 3 hours before
      Duration.zero,       // At the time of the appointment
    ];

    for (var duration in notificationTimes) {
      final notificationTime = _getNotificationTime(appointmentData, duration);

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        title,
        body,
        notificationTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'your_channel_id',
            'your_channel_name',
            channelDescription: 'your_channel_description',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidAllowWhileIdle: true,
        payload: docId,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  tz.TZDateTime _getNotificationTime(Map<String, dynamic> appointmentData, Duration offset) {
    final dateString = appointmentData['date_rdv'] as String;
    final timeString = '${appointmentData['heure_debut']} - ${appointmentData['heure_fin']}';

    // Parse the date and time to create a TZDateTime object
    final dateTime = DateTime.parse(dateString); // Adjust this parsing as needed
    final tzDateTime = tz.TZDateTime.from(dateTime, tz.local).subtract(offset);

    return tzDateTime;
  }
}
