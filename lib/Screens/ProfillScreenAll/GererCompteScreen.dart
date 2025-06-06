import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'update/UpdateAdress.dart';
import 'update/UpdateEmail.dart';
import 'update/UpdatePassword.dart';

class GererCompteScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => GererCompteScreenState();
}

class GererCompteScreenState extends State<GererCompteScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController adresseController = TextEditingController();
  TextEditingController passwordController = TextEditingController(text: '*********');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;
  String _userAdresse = '';
  String _userEmail = '';

  Future<void> _showProfile() async {
    try {
      _auth.authStateChanges().listen((User? user) async {
        setState(() {
          _currentUser = user;
        });
        if (user != null) {
          await _currentUser!.reload();
          setState(() {
            _currentUser = _auth.currentUser;
          });

          DocumentSnapshot userDoc = await _firestore.collection('utilisateur').doc(user.uid).get();
          setState(() {
            _userAdresse = userDoc['adresse_usr'] ?? '';
            _userEmail = user.email ?? '';

            emailController.text = _userEmail;
            adresseController.text = _userAdresse;
          });
          print('User UID: ${user.uid}');
          print('User Email: ${user.email}');
        } else {
          print('No user is signed in.');
        }
      });
    } on FirebaseAuthException catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _showProfile();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gérer le compte',
          style: TextStyle(
            fontSize: 24,
            fontFamily: 'Poppins-Medium',
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
              ),
              SizedBox(height: 30),
              _buildForm(screenWidth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm(double screenWidth) {
    return Column(
      children: [
        _inputField(
          "Email",
          emailController,
          "",
          screenWidth: screenWidth,
        ),
        SizedBox(height: 20),
        _inputField(
          "Adresse",
          adresseController,
          "facultative",
          screenWidth: screenWidth,
        ),
        SizedBox(height: 20),
        _inputField(
          "Password",
          passwordController,
          "",
          isPassword: true,
          icon: true,
          screenWidth: screenWidth,
        ),
      ],
    );
  }

  Widget _inputField(
      String labelText,
      TextEditingController controller,
      String hintText, {
        bool isPassword = false,
        bool icon = false,
        required double screenWidth,
      }) {
    var border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: Colors.grey),
    );

    return Column(
      children: [
        Container(
          height: 50,
          width: screenWidth * 0.99,
          child: GestureDetector(
            onTap: () {
              if (labelText == "Email") {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => UpdateemailSreen()),
                );
              } else if (labelText == "Adresse") {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => UpdateadressScreen()),
                );
              } else if (labelText == "Password") {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => UpdatepasswordScreen()),
                );
              }
            },
            child: AbsorbPointer(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        labelText,
                        style: TextStyle(
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      if (icon) Icon(Icons.lock),
                    ],
                  ),
                  hintText: hintText,
                  border: border,
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  suffixIcon: IconButton(
                    icon: Icon(Icons.arrow_forward_ios),
                    onPressed: () {},
                  ),
                  enabledBorder: border,
                  focusedBorder: border,
                ),
                obscureText: isPassword,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
