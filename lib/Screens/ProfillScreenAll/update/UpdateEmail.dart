import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medecineproject/Screens/ProfillScreenAll/GererCompteScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../LoginScreen.dart';

class UpdateemailSreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _UpdateemailScreen();

}

class _UpdateemailScreen extends State<UpdateemailSreen>{
  TextEditingController emailController = TextEditingController();
  TextEditingController emailConfirmeController = TextEditingController();
  TextEditingController passwordlController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _currentUser;
  String _userEmail = '';
  String _authEmail = '';
  String _errorMessage = '';

  Future<void> _showProfile() async {
    try {
      _auth.authStateChanges().listen((User? user) async {
        setState(() {
          _currentUser = user;
          _authEmail = user!.email!;
        });
        if (user != null) {
          DocumentSnapshot userDoc = await _firestore.collection('utilisateur').doc(user.uid).get();
          setState(() {
            _userEmail = userDoc['email_usr'] ?? '';
            //emailController.text = _authEmail;

          });
//  print('testttttttttt');
          print('Userrr email: $_userEmail');
          print('User email vari: $_authEmail ');

        } else {
          print('No user is signed in.');
        }
      });
    } on FirebaseAuthException catch (e) {
      print(e);
    }
  }

  Future<void> _updateUserEmail() async {
    if (_currentUser != null) {
      try {
        // Re-authenticate the user
        AuthCredential credential = EmailAuthProvider.credential(
          email:_authEmail ,
          password: passwordlController.text,
        );
        await _currentUser!.reauthenticateWithCredential(credential);

        // Update the email in Firebase Auth
        await _currentUser!.verifyBeforeUpdateEmail(emailController.text);
    //    _showSuccessFlushbar("Un email de vérification a été envoyé. Veuillez vérifier votre email.");
        // Update the email in Firestore
        await _firestore.collection('utilisateur').doc(_currentUser!.uid).update({
          'email_usr': emailController.text,
        });
        await _firestore.collection('patient_pt').doc(_currentUser!.uid).update({
          'email_pt': emailController.text,
        });
        _showSuccessDialog();

        // Update the email in Firestore
      //  await _firestore.collection('utilisateur').doc(_currentUser!.uid).update({
      //    'email_usr': emailController.text,
      //  });
     //   await _firestore.collection('patient_pt').doc(_currentUser!.uid).update({
     //     'email_pt': emailController.text,
     //   });
       // _showSuccessFlushbar("L'email a été modifié avec succès");
      } catch (e) {
        print('Erreur lors de la mise à jour de l\'email utilisateur: $e');
      }
    }
  }
  Future<void> _logout() async {
    await _auth.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Loginscreen()),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Color(0xFF7CDFC7), // Updated color
                      size: 80,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Email Modifié !',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins-Bold',
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Un lien de validation a été envoyer sur le nouveau Email .\n Veuillez le vérifier et le valider ! !',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontFamily: 'Poppins-Regular',
                      ),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF7CDFC7), // Updated color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          _logout();

                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 10.0,
                          ),
                          child: Text(
                            'OK',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Poppins-SemiBold',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
  void _showErrorFlushbar(String message) {
    Flushbar(
      message: message,
      duration: Duration(seconds: 3),
      backgroundColor: Colors.red,
    )..show(context);
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
    //_showSuccessDialog();
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    String labelText = "Email";
    String labelText2 = "Confirmer l'email";

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
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Saisissez le nouveau email',
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

              TextField(
                controller: emailConfirmeController,
                decoration: InputDecoration(
                  hintText: 'Confirmer le nouveau email',
                  labelText: labelText2,
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

              TextField(
                obscureText: true,
                controller: passwordlController,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  hintText: "Saisissez votre mot de passe pour connfirmer",
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
                    if (emailController.text.isEmpty || emailConfirmeController.text.isEmpty || passwordlController.text.isEmpty) {
                      _errorMessage = 'Remplissez le champ manquant';
                      _showErrorFlushbar(_errorMessage);
                    } else if (emailController.text != emailConfirmeController.text) {
                      _errorMessage = 'Les emails ne sont pas identiques';
                      _showErrorFlushbar(_errorMessage);
                    } else {
                      _updateUserEmail();
                    }

                  },
                  child: Text(
                    "Modifier l'adress mail'",
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