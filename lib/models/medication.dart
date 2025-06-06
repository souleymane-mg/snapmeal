import 'package:flutter/material.dart';

class Medication {
  String id;
  String name;
  String category;
  DateTime date;
  TimeOfDay time;
  String repetition;
  String notes;
  String? audioPath;
  String userId; // Ajout du champ userId

  Medication({
    required this.id,
    required this.name,
    required this.category,
    required this.date,
    required this.time,
    required this.repetition,
    required this.notes,
    this.audioPath,
    required this.userId, // Initialisation du champ userId
  });

  // Convert Medication object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'date': date.toIso8601String(),
      'time': '${time.hour}:${time.minute}',
      'repetition': repetition,
      'notes': notes,
      'audioPath': audioPath,
      'userId': userId, // Ajout du champ userId à la map
    };
  }

  // Create Medication object from a map
  factory Medication.fromMap(Map<String, dynamic> map, String documentId) {
    final timeParts = map['time'].split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    return Medication(
      id: documentId,
      name: map['name'],
      category: map['category'],
      date: DateTime.parse(map['date']),
      time: TimeOfDay(hour: hour, minute: minute),
      repetition: map['repetition'],
      notes: map['notes'],
      audioPath: map['audioPath'],
      userId: map['userId'], // Ajout de l'initialisation du champ userId
    );
  }

  // Convert Medication object to JSON
  Map<String, dynamic> toJson() {
    return toMap();
  }

  // Create Medication object from JSON
  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication.fromMap(json, json['id']);
  }
}

