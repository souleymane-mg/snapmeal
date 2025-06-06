import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'upcoming_schedule.dart';
import 'ArchiveRdv.dart';

class ScheduleScreen extends StatefulWidget {
  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _buttonIndex = 0;

  final List<String> _appointments = [
    "À venir",
    "Annulé",
    "Confirmée"
  ];

  Future<List<DocumentSnapshot>> _fetchUserAppointments() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    Query query = FirebaseFirestore.instance
        .collection('rdv')
        .where('id_pt_rdv', isEqualTo: user.uid);

    if (_buttonIndex == 1) {
      query = query.where('status', isEqualTo: 'annulé');
    } else if (_buttonIndex == 2) {
      query = query.where('confirmationEnvoyee', isEqualTo: true);
    } else {
      query = query.where('status', isEqualTo: 'validé');
    }

    QuerySnapshot appointmentsSnapshot = await query.get();
    List<DocumentSnapshot> appointments = appointmentsSnapshot.docs;

    appointments = appointments.where((appointment) {
      String date = appointment['date_rdv'];
      String endTime = appointment['heure_fin'];
      return !isAppointmentPast(date, endTime);
    }).toList();

    return appointments;
  }

  bool isAppointmentPast(String date, String time) {
    DateTime appointmentDateTime;
    if (date.contains('/')) {
      appointmentDateTime = DateFormat('dd/MM/yyyy HH:mm').parse('$date $time');
    } else {
      return false;
    }
    DateTime currentDateTime = DateTime.now();
    return currentDateTime.isAfter(appointmentDateTime);
  }

  Future<void> _cancelAppointment(DocumentSnapshot appointment) async {
    String creneauId = appointment['date_creneau_rdv'].split(' : ').last;

    WriteBatch batch = FirebaseFirestore.instance.batch();

    DocumentReference creneauRef = FirebaseFirestore.instance.collection('creneaux').doc(creneauId);
    DocumentReference rdvRef = FirebaseFirestore.instance.collection('rdv').doc(appointment.id);

    // Mise à jour des champs
    batch.update(creneauRef, {'isAvailable': true});
    batch.update(rdvRef, {
      'status': 'annulé',
      'cancelledBy': FirebaseAuth.instance.currentUser?.uid // Ajouter l'ID de l'utilisateur qui annule
    });

    await batch.commit();

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': user.uid,
        'message': 'Votre rendez-vous avec ${appointment['nom_medecin_rdv']} a été annulé.',
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    setState(() {
      _buttonIndex = 1;
    });
  }

  void _showCancelConfirmationDialog(BuildContext context, DocumentSnapshot appointment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Êtes-vous sûr de vouloir annuler ce rendez-vous ?'),
          actions: [
            TextButton(
              child: Text('Non'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Oui'),
              onPressed: () {
                Navigator.of(context).pop();
                _cancelAppointment(appointment);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Calendrier",
          style: TextStyle(
            fontSize: 24,
            fontFamily: 'Poppins-SemiBold',
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Center(
                child: Container(
                  padding: EdgeInsets.all(5),
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Color(0xFFF4F6FA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    children: [
                      _buildTabButton(0, "À venir", Color(0xFF00916E)),
                      _buildTabButton(1, "Annulé", Color(0xFF00916E)),
                      _buildTabButton(2, "Terminé", Color(0xFF00916E)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              FutureBuilder<List<DocumentSnapshot>>(
                future: _fetchUserAppointments(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Erreur : ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Aucun rendez-vous trouvé.'));
                  }

                  List<DocumentSnapshot> appointments = snapshot.data!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: appointments.map((appointment) {
                      String idCreneau = appointment['date_creneau'];
                      String idService = appointment['id_service_rdv'];
                      String nomMedecin = appointment['nom_medecin_rdv'];
                      String typeConsultation = appointment['type_consultation'];
                      String photoURL_medecin = appointment['photoURL_medecin'];

                      return UpcomingSchedule(
                        status: _buttonIndex == 0 ? "À venir" : _buttonIndex == 1 ? "Annulé" : "Confirmée",
                        onCancel: () => _showCancelConfirmationDialog(context, appointment),
                        idCreneau: idCreneau,
                        idService: idService,
                        nomMedecin: nomMedecin,
                        typeConsultation: typeConsultation,
                        photoURL_medecin: photoURL_medecin,
                        documentId: appointment.id,
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String text, Color activeColor) {
    return InkWell(
      onTap: () {
        setState(() {
          _buttonIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 25),
        decoration: BoxDecoration(
          color: _buttonIndex == index ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: _buttonIndex == index ? Colors.white : Colors.black38,
          ),
        ),
      ),
    );
  }
}
