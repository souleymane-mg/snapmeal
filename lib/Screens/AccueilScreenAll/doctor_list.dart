import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'widgetsDoctor/doctor_card.dart';
import 'modelDoctor/doctor.dart';
import 'package:shimmer/shimmer.dart';

class DoctorList extends StatelessWidget {
  final String selectedSpecialty;
  final String searchText;

  DoctorList({required this.selectedSpecialty, required this.searchText});

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> stream;
    if (selectedSpecialty == "All") {
      stream = FirebaseFirestore.instance.collection('medecin_md').snapshots();
    } else {
      stream = FirebaseFirestore.instance.collection('medecin_md')
          .where('specialite_md', isEqualTo: selectedSpecialty)
          .snapshots();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
          return buildShimmerEffect();
        }

        List<Doctor> doctors = snapshot.data!.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          String id = doc.id;
          String name = data['nom_md'] ?? '';
          String specialty = data['specialite_md'] ?? '';
          String photoURL = data['photoURL'] ?? '';
          return Doctor(
            id: id,
            name: name,
            specialty: specialty,
            photoURL: photoURL,
            rating: 5.0,
          );
        }).toList();

        if (searchText.isNotEmpty) {
          doctors = doctors.where((doc) =>
          doc.name.toLowerCase().contains(searchText.toLowerCase()) ||
              doc.specialty.toLowerCase().contains(searchText.toLowerCase())
          ).toList();
        }

        if (doctors.isEmpty) {
          return Center(child: Text("No doctors found"));
        }

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: doctors.length,
          itemBuilder: (context, index) {
            return DoctorCard(doctor: doctors[index]);
          },
        );
      },
    );
  }

  Widget buildShimmerEffect() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 16,
                    color: Colors.white,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Container(
                    height: 14,
                    color: Colors.white,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4),
                      Container(
                        width: 70,
                        height: 14,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
