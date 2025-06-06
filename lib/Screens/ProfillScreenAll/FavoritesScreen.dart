import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../AccueilScreenAll/modelDoctor/doctor.dart';
import 'package:medecineproject/Screens/AccueilScreenAll/MakingAppointment.dart' as making;
import '../AccueilScreenAll/widgetsDoctor/CustomLikeButton.dart'; // Import de votre classe CustomLikeButton

class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Favoris',
            style: TextStyle(
              fontSize: 28,
              fontFamily: 'Poppins-meduims',
            ),
          ),
        ),
        body: Center(
          child: Text('Veuillez vous connecter pour voir vos favoris.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favoris',
          style: TextStyle(
            fontSize: 28,
            fontFamily: 'Poppins-meduims',
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('user_favorites')
            .doc(user.uid)
            .collection('favorites')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Une erreur est survenue.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Aucun favori.'));
          }

          List<Doctor> favorites = snapshot.data!.docs.map((doc) {
            return Doctor(
              id: doc['id'],
              name: doc['name'],
              specialty: doc['specialty'],
              rating: 0.0,
              photoURL: doc['photoURL'],
            );
          }).toList();

          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              Doctor doctor = favorites[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 4,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => making.MakingAppointment(doctor: doctor),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(doctor.photoURL),
                          ),
                          SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctor.name,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                doctor.specialty,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          Spacer(),
                          CustomLikeButton(
                            doctorId: doctor.id,
                            doctorName: doctor.name,
                            doctorSpecialty: doctor.specialty,
                            doctorPhotoURL: doctor.photoURL,
                            isInitiallyLiked: true, // On considère que ce médecin est déjà liké car il est dans les favoris
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
