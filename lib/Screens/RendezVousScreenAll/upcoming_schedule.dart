import 'package:flutter/material.dart';
import 'RDVDetailsPage.dart';

class UpcomingSchedule extends StatelessWidget {
  final String status;
  final String idCreneau;
  final String idService;
  final String nomMedecin;
  final String typeConsultation;
  final String photoURL_medecin;
  final String documentId;
  final String? dateCreneauAnnule;

  final VoidCallback onCancel;

  const UpcomingSchedule({
    required this.status,
    required this.idCreneau,
    required this.idService,
    required this.nomMedecin,
    required this.typeConsultation,
    required this.photoURL_medecin,
    required this.onCancel,
    required this.documentId,
    this.dateCreneauAnnule,
  });

  @override
  Widget build(BuildContext context) {
    List<String> parts = idCreneau.split(' : ');
    String dateCreneau = parts[0];
    String timeCreneau = parts[1];

    // Utiliser dateCreneauAnnule si status est annulé
    if (status == "Annulé" && dateCreneauAnnule != null) {
      List<String> annuleParts = dateCreneauAnnule!.split(' : ');
      dateCreneau = annuleParts[0];
      timeCreneau = annuleParts[1];
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
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
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: status == "Annulé"
                                  ? Colors.red
                                  : status == "Confirmée"
                                  ? Colors.blue
                                  : Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            status,
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  if (status == "À venir")
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: onCancel,
                          child: Container(
                            width: 150,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Color(0xFFF4F6FA),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                "Annuler",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RDVDetailsPage(
                                    documentId: documentId), // Passez l'identifiant du document ici
                              ),
                            );
                          },
                          child: Container(
                            width: 150,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Color(0xFF00916E),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                "Détails rdv",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
