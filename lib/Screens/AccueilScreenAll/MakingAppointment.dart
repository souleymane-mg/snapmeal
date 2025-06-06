import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../AccueilScreenAll/modelDoctor/doctor.dart';
import 'dart:math';
import '../AccueilScreenAll/widgetsDoctor/CustomLikeButton.dart'; // Import de votre classe CustomLikeButton

class MakingAppointment extends StatefulWidget {
  final Doctor doctor;

  MakingAppointment({required this.doctor});

  @override
  _MakingAppointmentState createState() => _MakingAppointmentState();
}

class _MakingAppointmentState extends State<MakingAppointment> {
  String? selectedTimeSlot;
  String? selectedAppointmentType;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'fr_FR';
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot favSnapshot = await FirebaseFirestore.instance
          .collection('user_favorites')
          .doc(user.uid)
          .collection('favorites')
          .doc(widget.doctor.id)
          .get();

      if (favSnapshot.exists) {
        setState(() {
          isFavorite = true;
        });
      }
    }
  }

  Future<String> _getUserName(String userId) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('patient_pt')
        .doc(userId)
        .get();

    if (userDoc.exists) {
      return userDoc['Nom_pt'] as String? ?? 'Nom inconnu';
    } else {
      return 'Nom inconnu';
    }
  }

  String _generateAppointmentCode() {
    var rng = Random();
    return (rng.nextInt(900000) + 100000).toString();
  }

  Future<void> _bookAppointment(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Aucun utilisateur connecté.')),
      );
      return;
    }

    if (selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez sélectionner un créneau horaire.')),
      );
      return;
    }

    if (selectedAppointmentType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez sélectionner le type de consultation.')),
      );
      return;
    }

    String doctorName = widget.doctor.name;
    String doctorPhotoURL = widget.doctor.photoURL;

    String userName = await _getUserName(user.uid);

    List<String> parts = selectedTimeSlot!.split(' : ');
    String date = parts[0];
    String times = parts[1];
    List<String> timeParts = times.split(' - ');
    String startTime = timeParts[0];
    String endTime = timeParts[1];
    String creneauId = parts[2];

    String appointmentCode = _generateAppointmentCode();

    // Mettre à jour la disponibilité du créneau sélectionné à false
    await FirebaseFirestore.instance.collection('creneaux').doc(creneauId).update({'isAvailable': false});

    await FirebaseFirestore.instance.collection('rdv').add({
      'id_pt_rdv': user.uid,
      'id_service_rdv': widget.doctor.specialty,
      'date_rdv': date,
      'heure_debut': startTime,
      'heure_fin': endTime,
      'id_medecin_rdv': widget.doctor.id,
      'nom_medecin_rdv': doctorName,
      'photoURL_medecin': doctorPhotoURL,
      'confirmationEnvoyee': false,
      'date_creneau_rdv': '$date : $startTime - $endTime : $creneauId',
      'date_creneau': '$date : $startTime - $endTime : $creneauId',
      'type_consultation': selectedAppointmentType,
      'nom_patient': userName,
      'status': 'validé',
      'rdv_code': appointmentCode
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Rendez-vous enregistré avec succès !')),
    );

    Navigator.pop(context);
  }

  bool _isDateInCurrentWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));

    return date.isAfter(startOfWeek) && date.isBefore(endOfWeek.add(Duration(days: 1)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choisir un créneau'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(widget.doctor.photoURL),
                    ),
                    SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.doctor.name,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.doctor.specialty,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    Spacer(),
                    CustomLikeButton(
                      doctorId: widget.doctor.id,
                      doctorName: widget.doctor.name,
                      doctorSpecialty: widget.doctor.specialty,
                      doctorPhotoURL: widget.doctor.photoURL,
                      isInitiallyLiked: isFavorite,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Créneaux disponibles',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('creneaux')
                  .where('id_medecin_creneau', isEqualTo: widget.doctor.id)
                  .where('isAvailable', isEqualTo: true) // Filtrer par disponibilité
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Une erreur est survenue'));
                }

                if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                List<Map<String, dynamic>> timeSlots = snapshot.data!.docs.map((doc) {
                  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                  return {
                    'id': doc.id,
                    'date': data['date_creneau'],
                    'start': data['heureDebut'],
                    'end': data['heureFin'],
                    'isAvailable': data['isAvailable']
                  };
                }).toList();

                // Trier les créneaux par date et heure du plus récent au plus lointain
                timeSlots.sort((a, b) {
                  DateTime dateA = DateFormat('yyyy-MM-dd').parse(a['date']);
                  DateTime dateB = DateFormat('yyyy-MM-dd').parse(b['date']);
                  int dateComparison = dateA.compareTo(dateB);
                  if (dateComparison != 0) return dateComparison;
                  return a['start'].compareTo(b['start']);
                });

                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: _filterBookedTimeSlots(timeSlots),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    List<Map<String, dynamic>> availableSlots = snapshot.data!;

                    if (availableSlots.isEmpty) {
                      return Center(child: Text("Aucun créneau horaire disponible"));
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: availableSlots.length,
                          itemBuilder: (context, index) {
                            final slot = availableSlots[index];
                            DateTime slotDate = DateFormat('yyyy-MM-dd').parse(slot['date']);
                            String formattedDate;
                            if (_isDateInCurrentWeek(slotDate)) {
                              formattedDate = DateFormat('EEEE').format(slotDate); // Afficher le jour de la semaine
                            } else {
                              formattedDate = DateFormat('dd/MM/yyyy').format(slotDate); // Afficher la date complète
                            }
                            final timeSlotText = '$formattedDate : ${slot['start']} - ${slot['end']}';
                            return RadioListTile<String>(
                              title: Text(timeSlotText),
                              value: '$formattedDate : ${slot['start']} - ${slot['end']} : ${slot['id']}',
                              groupValue: selectedTimeSlot,
                              onChanged: (value) {
                                setState(() {
                                  selectedTimeSlot = value;
                                });
                              },
                            );
                          },
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Type de consultation',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
                        ),
                        SizedBox(height: 10),
                        RadioListTile<String>(
                          title: Text('Consultation à domicile'),
                          value: 'domicile',
                          groupValue: selectedAppointmentType,
                          onChanged: (value) {
                            setState(() {
                              selectedAppointmentType = value;
                            });
                          },
                        ),
                        RadioListTile<String>(
                          title: Text('Consultation à la clinique'),
                          value: 'clinique',
                          groupValue: selectedAppointmentType,
                          onChanged: (value) {
                            setState(() {
                              selectedAppointmentType = value;
                            });
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 30.0),
                    child: Text(
                      'Annuler',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _bookAppointment(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 30.0),
                    child: Text(
                      'Valider',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _filterBookedTimeSlots(List<Map<String, dynamic>> timeSlots) async {
    // Supprimer les créneaux dépassés
    await _removePastTimeSlots(timeSlots);

    // Re-filtrer les créneaux après suppression des créneaux dépassés
    QuerySnapshot bookedSlotsSnapshot = await FirebaseFirestore.instance.collection('rdv').get();
    List<String> bookedSlots = bookedSlotsSnapshot.docs.map((doc) {
      return doc['date_creneau_rdv'] as String;
    }).toList();

    return timeSlots.where((slot) {
      final timeSlotText = '${slot['date']} : ${slot['start']} - ${slot['end']} : ${slot['id']}';
      return !bookedSlots.contains(timeSlotText);
    }).toList();
  }

  Future<void> _removePastTimeSlots(List<Map<String, dynamic>> timeSlots) async {
    DateTime now = DateTime.now();

    for (var slot in timeSlots) {
      DateTime slotDate = DateFormat('yyyy-MM-dd').parse(slot['date']);
      TimeOfDay startTime = TimeOfDay(
        hour: int.parse(slot['start'].split(':')[0]),
        minute: int.parse(slot['start'].split(':')[1]),
      );
      DateTime slotStartDateTime = DateTime(slotDate.year, slotDate.month, slotDate.day, startTime.hour, startTime.minute);

      if (slotStartDateTime.isBefore(now)) {
        // Le créneau est dépassé, le supprimer
        await FirebaseFirestore.instance.collection('creneaux').doc(slot['id']).delete();
      }
    }
  }
}