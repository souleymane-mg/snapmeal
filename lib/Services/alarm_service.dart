import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AlarmService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AudioPlayer audioPlayer = AudioPlayer();
  final String _sharedPreferencesKey = 'rappels';

  AlarmService() {
    _initializeNotifications();
    _loadAlarms();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'your_channel_id', // id
      'your_channel_name', // name
      description: 'your_channel_description', // description
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

    print('Notifications initialized and channel created');
  }

  void _loadAlarms() async {
    // Charger les rappels depuis Firestore
    final querySnapshot = await _firestore.collection('Rappels').get();
    for (var doc in querySnapshot.docs) {
      final rappel = doc.data();
      _scheduleAlarmFromMap(rappel);
    }

    // Charger les rappels depuis SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? rappelsString = prefs.getString(_sharedPreferencesKey);
    if (rappelsString != null) {
      final List<dynamic> rappelsList = jsonDecode(rappelsString);
      for (var rappel in rappelsList) {
        _scheduleAlarmFromMap(rappel);
      }
    }
  }

  void _scheduleAlarmFromMap(Map<String, dynamic> rappel) {
    final DateTime date = DateTime.parse(rappel['date']);
    final TimeOfDay time = _parseTime(rappel['time']);
    final String? repetition = rappel['repetition'];
    final String? audioPath = rappel['audioPath'];

    print('Scheduling alarm for ${rappel['name']} at $date $time');
    _scheduleAlarm(date, time, repetition, audioPath);
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  void _scheduleAlarm(DateTime date, TimeOfDay time, String? repetition, String? audioPath) async {
    try {
      final tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Rappel de médicament',
        'Il est temps de prendre votre médicament!',
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'your_channel_id',
            'your_channel_name',
            channelDescription: 'your_channel_description',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true, // Activer le son par défaut
            sound: RawResourceAndroidNotificationSound('default_alarm'), // Nom du fichier sonore dans le répertoire `res/raw`
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: repetition != null ? DateTimeComponents.dayOfWeekAndTime : DateTimeComponents.time,
        payload: audioPath ?? '',
      );
      print('Alarm scheduled for $scheduledDate with payload $audioPath');
    } catch (e) {
      print('Error scheduling alarm: $e');
    }
  }

  Future<void> addRappel(Map<String, dynamic> rappel) async {
    // Enregistrer dans Firestore
    await _firestore.collection('Rappels').add(rappel);

    // Enregistrer dans SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? rappelsString = prefs.getString(_sharedPreferencesKey);
    final List<dynamic> rappelsList = rappelsString != null ? jsonDecode(rappelsString) : [];
    rappelsList.add(rappel);
    prefs.setString(_sharedPreferencesKey, jsonEncode(rappelsList));
  }

  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    final String? payload = response.payload;
    print('Notification received with payload: $payload');
    if (payload != null && payload.isNotEmpty) {
      _playAudio(payload);
    } else {
      _playDefaultAlarm();
    }
  }

  void _playAudio(String path) {
    print('Playing audio from path: $path');
    audioPlayer.play(DeviceFileSource(path));
  }

  void _playDefaultAlarm() {
    print('Playing default alarm');
    audioPlayer.play(AssetSource('sounds/default_alarm1.mp3')); // Assurez-vous que ce fichier existe dans votre dossier assets
  }
}
