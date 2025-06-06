import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medecineproject/Screens/AccueilScreenAll/AideScreen/SendUrgenceMessageScreen.dart';

class NumeroUrgence extends StatefulWidget {
  const NumeroUrgence({Key? key}) : super(key: key);

  @override
  _NumeroUrgenceState createState() => _NumeroUrgenceState();
}

class _NumeroUrgenceState extends State<NumeroUrgence> {
  final TextEditingController telephoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final String accountSid = 'AC147d321a64d39c7d43a109b7a9399176';
  final String authToken = '49f12571f236805e3303af1adc4331d6';
  final String twilioNumber = '+19142144730';

  @override
  void initState() {
    super.initState();
    _checkEmergencyNumber();
  }

  Future<void> _checkEmergencyNumber() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userProfile = await FirebaseFirestore.instance
          .collection('utilisateur')
          .doc(user.uid)
          .get();
      if (userProfile.exists && userProfile['numero_urgence'] != null) {
        String emergencyNumber = userProfile['numero_urgence'];
        String nomUsr = userProfile['nom_usr'];
        String sexe = userProfile['sexe'];
        String titre = sexe == 'Homme' ? 'MR' : 'MDM';
        _sendEmergencySms(emergencyNumber, titre, nomUsr);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SendUrgenceMessageScreen()),
        );
      }
    }
  }

  Future<void> _sendEmergencySms(String number, String titre, String nomUsr) async {
    final uri = Uri.https('api.twilio.com', '/2010-04-01/Accounts/$accountSid/Messages.json');

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Basic ' + base64Encode(utf8.encode('$accountSid:$authToken')),
      },
      body: {
        'From': twilioNumber,
        'To': number,
        'Body': 'URGENCE!! $titre $nomUsr a besoin d\'aide !! Veuillez aller à son secours',
      },
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message d\'urgence envoyé')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Échec de l\'envoi du message d\'urgence')),
      );
    }
  }

  Future<void> _saveEmergencyNumber() async {
    if (_formKey.currentState!.validate()) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String emergencyNumber = '+223${telephoneController.text}';
        await FirebaseFirestore.instance
            .collection('utilisateur')
            .doc(user.uid)
            .set({'numero_urgence': emergencyNumber}, SetOptions(merge: true));

        DocumentSnapshot userProfile = await FirebaseFirestore.instance
            .collection('utilisateur')
            .doc(user.uid)
            .get();
        String nomUsr = userProfile['nom_usr'];
        String sexe = userProfile['sexe'];
        String titre = sexe == 'HOMME' ? 'MR' : 'MDM';

        _sendEmergencySms(emergencyNumber, titre, nomUsr);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Numéro d\'urgence'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1, vertical: 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                _inputField(
                  "Numéro de téléphone",
                  "Entrez votre numéro de téléphone",
                  telephoneController,
                  labelStyle: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  icon: Icons.phone,
                  screenWidth: screenWidth,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Ce champ est requis";
                    } else if (value.length != 8) {
                      return "Le numéro doit comporter 8 chiffres";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _saveEmergencyNumber,
                  child: const Text(
                    'Enregistrer',
                    style: TextStyle(color: Colors.teal),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(
      String labelText,
      String hintText,
      TextEditingController controller, {
        required TextStyle labelStyle,
        required IconData icon,
        required double screenWidth,
        FormFieldValidator<String>? validator,
      }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.black),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: labelStyle,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            enabledBorder: border,
            focusedBorder: border,
            prefixIcon: Icon(icon),
          ),
          keyboardType: TextInputType.phone,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
          validator: validator,
          maxLength: 8, // Limiter à 8 chiffres
        ),
      ],
    );
  }
}
