import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medecineproject/Screens/ProfillScreenAll/GererCompteScreen.dart';

class UpdateadressScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Updateadressscreen();
}

class _Updateadressscreen extends State<UpdateadressScreen> {
  TextEditingController adresseController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _currentUser;
  String _userAdresse = '';
  Future<void> _showProfile() async {
    try {
      _auth.authStateChanges().listen((User? user) async {
        setState(() {
          _currentUser = user;
        });
        if (user != null) {
          DocumentSnapshot userDoc = await _firestore.collection('utilisateur').doc(user.uid).get();
          setState(() {
            _userAdresse = userDoc['adresse_usr'] ?? '';
            adresseController.text = _userAdresse;

          });

          print('User Name: $_userAdresse');
        } else {
          print('No user is signed in.');
        }
      });
    } on FirebaseAuthException catch (e) {
      print(e);
    }
  }

  Future<void> _updateUserAdresse() async {
    if (_currentUser != null) {
      print("cest vrai");
      try {
        await _firestore.collection('utilisateur').doc(_currentUser!.uid).update({
          'adresse_usr': adresseController.text,
        });
        await _firestore.collection('patient_pt').doc(_currentUser!.uid).update({
          'adresse_pt': adresseController.text,
        });
        _showSuccessFlushbar("l'adreese a ete modifie avec success");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => GererCompteScreen()),
        );
        print('Nom utilisateur mis à jour avec succès');
      } catch (e) {
        print('Erreur lors de la mise à jour du nom utilisateur: $e');
      }
    }
  }
  void _showSuccessFlushbar(String message) {
    Flushbar(
      message: message,
      duration: Duration(seconds: 3),
      backgroundColor: Colors.green,
    )..show(context);
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _showProfile();
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    String labelText = "Adresse";

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.01, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      // Action lorsque l'IconButton est pressé
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GererCompteScreen()),
                      );
                    },
                  ),
                  Text(
                    "Retour",
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              TextField(
                controller: adresseController,
                decoration: InputDecoration(
                  hintText: "Entrer votre adress",
                  labelText: labelText,
                  labelStyle: TextStyle(
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.bold,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
              ),

              SizedBox(height: 20,),

              MouseRegion(
                cursor: SystemMouseCursors.click, // Changer le curseur en main
                child: GestureDetector(
                  onTap: () {
                    _updateUserAdresse();
                  },
                  child: Text(
                    "Modifier l'adresse",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: MediaQuery.of(context).size.width * 0.05,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
