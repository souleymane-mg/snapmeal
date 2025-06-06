import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'doctor_list.dart';
import 'widgetsDoctor/doctors_category.dart';

class DoctorsScreen extends StatefulWidget {
  @override
  _DoctorScreenState createState() => _DoctorScreenState();
}

class _DoctorScreenState extends State<DoctorsScreen> {
  String selectedSpecialty = 'All';
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Agents de santé',
            style: TextStyle(
              fontSize: 22,
              fontFamily: 'Poppins-Medium',
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: Column(
          children: [
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child:
              TextField(
                decoration: InputDecoration(
                  labelText: 'Rechercher un spécialiste de la santé ',
                  hintText: 'Type nom ou specialité',
                  prefixIcon: Icon(Icons.search, color: Color(0xff4338CA)),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                ),
                onChanged: (value) {
                  setState(() {
                    searchText = value.toLowerCase();
                  });
                },
              ),
            ),
            DoctorsCategory(
              onSpecialtySelected: (specialty) {
                setState(() {
                  selectedSpecialty = specialty;
                });
              },
            ),
            SizedBox(height: 20),
            Expanded(
              child: DoctorList(
                selectedSpecialty: selectedSpecialty,
                searchText: searchText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
