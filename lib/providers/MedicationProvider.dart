import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medication.dart';

class MedicationProvider with ChangeNotifier {
  List<Medication> _medications = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _userId = "exampleUserId"; // Utilisateur ID à modifier selon votre logique

  List<Medication> get medications => _medications;

  MedicationProvider() {
    _loadMedications();
  }

  void addMedication(Medication medication) async {
    DocumentReference docRef = await _firestore.collection('Rappels').add(medication.toMap());
    medication.id = docRef.id; // Assigner l'ID Firestore au médicament
    _medications.add(medication);
    notifyListeners();
  }

  void removeMedication(Medication medication) async {
    await _firestore.collection('Rappels').doc(medication.id).delete();
    _medications.remove(medication);
    notifyListeners();
  }

  void updateMedication(Medication oldMedication, Medication newMedication) async {
    int index = _medications.indexOf(oldMedication);
    if (index != -1) {
      await _firestore.collection('Rappels').doc(newMedication.id).update(newMedication.toMap());
      _medications[index] = newMedication;
      notifyListeners();
    }
  }

  Future<void> _loadMedications() async {
    QuerySnapshot querySnapshot = await _firestore.collection('Rappels').get();
    _medications = querySnapshot.docs.map((doc) {
      return Medication.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
    notifyListeners();
  }
}

