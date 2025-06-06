import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _filterIndex = 0;

  final List<String> _filterOptions = [
    "Tous",
    "Terminé"
  ];

  Future<List<DocumentSnapshot>> _fetchHistory() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    Query query = FirebaseFirestore.instance
        .collection('rdv')
        .where('id_pt_rdv', isEqualTo: user.uid);

    if (_filterIndex == 1) {
      query = query.where('confirmationEnvoyee', isEqualTo: true);
    }

    QuerySnapshot historySnapshot = await query.get();
    List<DocumentSnapshot> history = historySnapshot.docs;

    history = history.where((appointment) {
      String date = appointment['date_rdv'];
      String endTime = appointment['heure_fin'];
      return isAppointmentPast(date, endTime);
    }).toList();

    return history;
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

  Future<void> _unarchiveAppointment(DocumentSnapshot appointment) async {
    DocumentReference rdvRef = FirebaseFirestore.instance.collection('rdv').doc(appointment.id);

    await rdvRef.update({'status': 'validé'});

    setState(() {});
  }

  void _showUnarchiveConfirmationDialog(BuildContext context, DocumentSnapshot appointment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Êtes-vous sûr de vouloir désarchiver ce rendez-vous ?'),
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
                _unarchiveAppointment(appointment);
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
          "Archive",
          style: TextStyle(
            fontSize: 24,
            fontFamily: 'Poppins-SemiBold',
          ),
        ),
      ),
      body: Column(
        children: [
          Center(
            child: Container(
              padding: EdgeInsets.all(5),
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: Color(0xFFF4F6FA),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                children: List.generate(_filterOptions.length, (index) {
                  return _buildFilterButton(index, _filterOptions[index], Color(0xFF00916E));
                }),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<DocumentSnapshot>>(
              future: _fetchHistory(),
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

                List<DocumentSnapshot> history = snapshot.data!;

                return ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot appointment = history[index];
                    String nomMedecin = appointment['nom_medecin_rdv'];
                    String idService = appointment['id_service_rdv'];
                    String photoURL_medecin = appointment['photoURL_medecin'];
                    String idCreneau = appointment['date_creneau'];
                    List<String> parts = idCreneau.split(' : ');
                    String dateCreneau = parts[0];
                    String timeCreneau = parts[1];

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "À propos du médecin",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 15),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Text(
                                      "Dr. $nomMedecin",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text("$idService"),
                                    trailing: CircleAvatar(
                                      radius: 25,
                                      backgroundImage: NetworkImage("$photoURL_medecin"),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 15),
                                    child: Divider(
                                      thickness: 1,
                                      height: 20,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_month,
                                            color: Colors.black54,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            "$dateCreneau : $timeCreneau",
                                            style: TextStyle(
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      _showUnarchiveConfirmationDialog(context, appointment);
                                    },
                                    child: Text('Désarchiver'),
                                  ),
                                  SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(int index, String text, Color activeColor) {
    return InkWell(
      onTap: () {
        setState(() {
          _filterIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 25),
        decoration: BoxDecoration(
          color: _filterIndex == index ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: _filterIndex == index ? Colors.white : Colors.black38,
          ),
        ),
      ),
    );
  }
}
