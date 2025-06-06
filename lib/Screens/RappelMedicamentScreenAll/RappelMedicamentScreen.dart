import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/medication.dart';
import 'AddMedicationScreen.dart';
import 'DetailMedicamentSelectionner.dart';

class RappelMedicamentScreen extends StatefulWidget {
  @override
  _RappelMedicamentScreenState createState() => _RappelMedicamentScreenState();
}

class _RappelMedicamentScreenState extends State<RappelMedicamentScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Journal de rappels',
          style: TextStyle(
            fontSize: 24,
            fontFamily: 'Poppins-SemiBold',
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('Rappels')
            .where('userId', isEqualTo: _auth.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final medications = snapshot.data!.docs.map((doc) {
            return Medication.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

          if (medications.isEmpty) {
            return Center(child: Text('Aucun rappel de médicament'));
          }
          return ListView.builder(
            itemCount: medications.length,
            itemBuilder: (context, index) {
              final medication = medications[index];
              return GestureDetector(
                onLongPress: () {
                  _showOptions(context, medication);
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: Image.asset(_getCategoryImagePath(medication.category)),
                      title: Text(
                        medication.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF00916E)),
                      ),
                      subtitle: _buildSubtitle(context, medication),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailMedicamentSelectionner(medication: medication),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddMedicationScreen()),
            );
          },
          child: Icon(Icons.add, color: Colors.white),
          backgroundColor: Color(0xFF00916E),
        ),
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context, Medication medication) {
    if (medication.repetition == 'Jamais') {
      return Text(
        'Date: ${medication.date.day}/${medication.date.month}/${medication.date.year}\n'
            'Heure: ${medication.time.format(context)}',
      );
    } else {
      return Text(
        'Répétition: ${medication.repetition}\n'
            'Heure: ${medication.time.hour}:${medication.time.minute}',
      );
    }
  }

  void _showOptions(BuildContext context, Medication medication) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Modifier'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddMedicationScreen(medication: medication),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Supprimer'),
              onTap: () {
                Navigator.pop(context); // Ferme le bottom sheet
                _confirmDelete(context, medication);
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Medication medication) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Voulez-vous vraiment supprimer ce médicament ?'),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
              },
            ),
            TextButton(
              child: Text('Supprimer'),
              onPressed: () async {
                await FirebaseFirestore.instance.collection('Rappels').doc(medication.id).delete();
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Médicament supprimé avec succès !')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  String _getCategoryImagePath(String category) {
    switch (category) {
      case 'Comprimé':
        return 'assets/images/autres/categorieMedicament/comprime.png';
      case 'Sirop':
        return 'assets/images/autres/categorieMedicament/sirop.png';
      case 'Injection':
        return 'assets/images/autres/categorieMedicament/injection.png';
      case 'Pommade':
        return 'assets/images/autres/categorieMedicament/pommade.png';
      default:
        return 'assets/images/default.png';
    }
  }
}
