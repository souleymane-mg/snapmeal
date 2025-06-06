import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'category_button.dart';

class DoctorsCategory extends StatefulWidget {
  final Function(String) onSpecialtySelected;

  DoctorsCategory({required this.onSpecialtySelected});

  @override
  _DoctorsCategoryState createState() => _DoctorsCategoryState();
}

class _DoctorsCategoryState extends State<DoctorsCategory> {
  String? _selectedSpecialty = "All"; // Initialize with "All" as the default selected category

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('medecin_md').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return CircularProgressIndicator();
        }
        List<String> specialties = ['All'];
        specialties.addAll(
          snapshot.data!.docs
              .map((doc) => doc.get('specialite_md') as String)
              .toSet()
              .toList(),
        );

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: specialties.map((specialty) {
              return CategoryButton(
                title: specialty,
                onPressed: () {
                  setState(() {
                    _selectedSpecialty = specialty;
                  });
                  widget.onSpecialtySelected(specialty);
                },
                isSelected: _selectedSpecialty == specialty,
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
