import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:medecineproject/Screens/LoginScreen.dart';
import 'package:email_validator/email_validator.dart'; // Add this package for email validation

class Registerscreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<Registerscreen> {
  TextEditingController nomController = TextEditingController();
  TextEditingController adresseController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmerPasswordController = TextEditingController();
  TextEditingController telephoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  String? _selectedSexe; // Variable pour stocker le sexe sélectionné

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>(); // Add form key for form validation

  bool _passwordVisible = false; // Variable to toggle password visibility
  bool _confirmPasswordVisible = false; // Variable to toggle confirm password visibility

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return; // Stop registration if form is not valid
    }

    if (passwordController.text != confirmerPasswordController.text) {
      _showErrorFlushbar("Les mots de passe ne correspondent pas");
      return;
    }

    // Show loading spinner
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      await _firestore.collection('utilisateur').doc(userCredential.user!.uid).set({
        'nom_usr': nomController.text,
        'email_usr': emailController.text,
        'adresse_usr': adresseController.text,
        'telephone': telephoneController.text,
        'sexe': _selectedSexe, // Enregistrer le sexe sélectionné
        'role_usr': 'patient',
        'username': nomController.text, // Ajouter le champ username
      });

      await _firestore.collection('patient_pt').doc(userCredential.user!.uid).set({
        'Id_pt': userCredential.user!.uid,
        'Nom_pt': nomController.text,
        'email_pt': emailController.text,
        'adresse_pt': adresseController.text,
        'telephone_pt': telephoneController.text,
        'sexe': _selectedSexe, // Enregistrer le sexe sélectionné
        'username': nomController.text, // Ajouter le champ username
      });

      // Close the loading spinner
      Navigator.of(context).pop();

      _showSuccessDialog();
    } on FirebaseAuthException catch (e) {
      // Close the loading spinner
      Navigator.of(context).pop();
      _showErrorFlushbar(e.message ?? "Une erreur s'est produite");
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
                    Image.asset(
                      'assets/images/autres/gif/verifie.gif', // Chemin du GIF dans les assets
                      width: 80,
                      height: 80,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Compte créé !',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins-Bold',
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Votre compte a été créé avec succès.\nBienvenue parmi nous !',
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
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => Loginscreen()),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 10.0,
                          ),
                          child: Text(
                            'Se connecter',
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1, vertical: 30),
          child: Form(
            key: _formKey, // Assign the form key to the form
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),
                SvgPicture.asset(
                  "assets/images/logos/LogoLoginScreen.svg",
                  height: screenWidth * 0.35,
                ),
                SizedBox(height: 10),
                Text(
                  'Medicali',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.08,
                    color: Color.fromARGB(255, 10, 148, 116),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Inscrivez-vous',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                _buildForm(screenWidth),
                SizedBox(height: 20),
                _inscriptionButton(screenWidth),
                SizedBox(height: 10),
                _buildRegisterLink(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _inputField(
          "Nom complet",
          "Entrez votre nom complet",
          nomController,
          labelStyle: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          icon: Icons.person,
          screenWidth: screenWidth,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Ce champ est requis";
            }
            return null;
          },
        ),
        SizedBox(height: 15),
        _inputField(
          "Adresse Email",
          "Entrez votre adresse email",
          emailController,
          labelStyle: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          icon: Icons.email,
          screenWidth: screenWidth,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Ce champ est requis";
            } else if (!EmailValidator.validate(value)) {
              return "Veuillez entrer une adresse email valide";
            }
            return null;
          },
        ),
        SizedBox(height: 15),
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
            }
            return null;
          },
        ),
        SizedBox(height: 15),
        _inputField(
          "Adresse",
          "Entrez votre adresse",
          adresseController,
          labelStyle: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          icon: Icons.home,
          screenWidth: screenWidth,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Ce champ est requis";
            }
            return null;
          },
        ),
        SizedBox(height: 15),
        _sexeDropdown(screenWidth), // Ajouter le champ de sélection du sexe
        SizedBox(height: 15),
        _passwordInputField(
          "Mot de passe",
          "Entrez votre mot de passe",
          passwordController,
          _passwordVisible,
              () {
            setState(() {
              _passwordVisible = !_passwordVisible;
            });
          },
          labelStyle: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          icon: Icons.lock,
          screenWidth: screenWidth,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Ce champ est requis";
            } else if (value.length < 6) {
              return "Le mot de passe doit avoir au moins 6 caractères";
            }
            return null;
          },
        ),
        SizedBox(height: 15),
        _passwordInputField(
          "Confirmer votre mot de passe",
          "Confirmez votre mot de passe",
          confirmerPasswordController,
          _confirmPasswordVisible,
              () {
            setState(() {
              _confirmPasswordVisible = !_confirmPasswordVisible;
            });
          },
          labelStyle: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          icon: Icons.lock,
          screenWidth: screenWidth,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Ce champ est requis";
            } else if (value != passwordController.text) {
              return "Les mots de passe ne correspondent pas";
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _sexeDropdown(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sexe',
          style: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedSexe,
          hint: Text(
            'Sélectionnez votre sexe',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          items: <String>['Homme', 'Femme']
              .map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedSexe = newValue;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ce champ est requis';
            }
            return null;
          },
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget _inputField(
      String labelText,
      String hintText,
      TextEditingController controller, {
        bool isPassword = false,
        required TextStyle labelStyle,
        IconData? icon,
        required double screenWidth,
        FormFieldValidator<String>? validator,
      }) {
    var border = OutlineInputBorder(
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
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            enabledBorder: border,
            focusedBorder: border,
            prefixIcon: Icon(icon),
          ),
          obscureText: isPassword,
          validator: validator,
        ),
      ],
    );
  }

  Widget _passwordInputField(
      String labelText,
      String hintText,
      TextEditingController controller,
      bool isPasswordVisible,
      VoidCallback onTogglePasswordVisibility, {
        required TextStyle labelStyle,
        IconData? icon,
        required double screenWidth,
        FormFieldValidator<String>? validator,
      }) {
    var border = OutlineInputBorder(
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
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            enabledBorder: border,
            focusedBorder: border,
            prefixIcon: Icon(icon),
            suffixIcon: IconButton(
              icon: Icon(
                isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: onTogglePasswordVisibility,
            ),
          ),
          obscureText: !isPasswordVisible,
          validator: validator,
        ),
      ],
    );
  }

  Widget _inscriptionButton(double screenWidth) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 10, 148, 116),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: screenWidth * 0.20),
      ),
      onPressed: _register,
      child: Text(
        'Inscrivez-vous',
        style: TextStyle(fontSize: screenWidth * 0.056, color: Colors.white),
      ),
    );
  }

  Widget _buildRegisterLink(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Loginscreen()),
        );
      },
      child: Text(
        "Vous avez déjà un compte?",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black,
          fontSize: MediaQuery.of(context).size.width * 0.04,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
