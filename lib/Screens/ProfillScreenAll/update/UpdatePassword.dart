import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medecineproject/Screens/ProfillScreenAll/GererCompteScreen.dart';

class UpdatepasswordScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Updatepasswordscreen();
}

class _Updatepasswordscreen extends State<UpdatepasswordScreen> {
  TextEditingController ancienMotDePasseController = TextEditingController();
  TextEditingController nouveauMotDePasseController = TextEditingController();
  TextEditingController confirmerNouveauMotDePasseController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _errorMessage = '';

  Future<void> _updatePassword() async {
    User? user = _auth.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = 'Aucun utilisateur connecté.';
        _showErrorFlushbar(_errorMessage);

      });
      return;
    }

    if (nouveauMotDePasseController.text != confirmerNouveauMotDePasseController.text) {
      setState(() {
        _errorMessage = 'Les nouveaux mots de passe ne correspondent pas.';
        _showErrorFlushbar(_errorMessage);

      });
      return;
    }

    try {
      // Re-authenticate the user
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: ancienMotDePasseController.text,
      );

      await user.reauthenticateWithCredential(credential);

      // Update the password
      await user.updatePassword(nouveauMotDePasseController.text);

      await user!.reload();

      setState(() {
        _errorMessage = 'Mot de passe mis à jour avec succès.';
        _showSuccessFlushbar(_errorMessage);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => GererCompteScreen()),
        );
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'Une erreur s\'est produite.';
        _showErrorFlushbar(_errorMessage);
      });
    }
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
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    String labelText = "Password";

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
                obscureText: true,

                controller: ancienMotDePasseController,
                decoration: InputDecoration(
                  hintText: "Mot de passe courant",
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(labelText,
                        style: TextStyle(
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Icon(Icons.lock),

                    ],
                  ),
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

              SizedBox(height: 30),

              TextField(
                obscureText: true,
                controller: nouveauMotDePasseController,
                decoration: InputDecoration(

                  hintText: "Nouveau mot de passe",
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


              SizedBox(height: 30),

              TextField(
                obscureText: true,

                controller: confirmerNouveauMotDePasseController,
                decoration: InputDecoration(
                  hintText: "Répéter le nouveau mot de passe",
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
              SizedBox(height: 20,),

              MouseRegion(
                cursor: SystemMouseCursors.click, // Changer le curseur en main
                child: GestureDetector(
                  onTap: () {
                    _updatePassword();
                  },
                  child: Text(
                    "Modifier",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: MediaQuery.of(context).size.width * 0.05,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
              /* MouseRegion(
                cursor: SystemMouseCursors.click, // Changer le curseur en main
                child: GestureDetector(
                  onTap: () {},
                  child: Text(
                    "Modifier le nom",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: MediaQuery.of(context).size.width * 0.05,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )*/
            ],
          ),
        ),
      ),
    );
  }
}
