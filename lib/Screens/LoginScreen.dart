import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../BottomBar/BottomBarScreen.dart';
import 'RegisterScreen.dart';
import 'ForgottenPassword.dart';
import '../Screens/ProfillScreenAll/theme_provider.dart'; // Import du ThemeProvider

class Loginscreen extends StatefulWidget {
  const Loginscreen({Key? key}) : super(key: key);

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscureText = true;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

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
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Close the loading spinner
      Navigator.of(context).pop();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => BottomBarScreen()),
            (Route<dynamic> route) => false,
      );
    } on FirebaseAuthException catch (e) {
      // Close the loading spinner
      Navigator.of(context).pop();
      _showErrorFlushbar(e.message ?? "Une erreur s'est produite");
    }
  }

  void _showErrorFlushbar(String message) {
    Flushbar(
      message: message,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.red,
    )..show(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonTextColor = Provider.of<ThemeProvider>(context).getButtonTextColor();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1, vertical: 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                SvgPicture.asset(
                  "assets/images/logos/LogoLoginScreen.svg",
                  height: screenWidth * 0.35,
                ),
                const SizedBox(height: 5),
                Text(
                  'Medicali',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.08,
                    color: const Color.fromARGB(255, 10, 148, 116),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Connectez-vous',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                _buildForm(screenWidth, buttonTextColor),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ForgottenPassword()),
                    );
                  },
                  child: Text(
                    'Mot de passe oublié?',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: buttonTextColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildLoginButton(screenWidth, buttonTextColor),
                const SizedBox(height: 10),
                _buildRegisterLink(context, buttonTextColor),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(double screenWidth, Color buttonTextColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _inputField(
          "Adresse email",
          "Entrez votre adresse email",
          emailController,
          labelStyle: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
            color: buttonTextColor,
          ),
          icon: Icons.email,
          screenWidth: screenWidth,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Ce champ est requis";
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        _inputField(
          "Mot de passe",
          "Entrez votre mot de passe",
          passwordController,
          isPassword: true,
          labelStyle: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
            color: buttonTextColor,
          ),
          icon: Icons.lock,
          screenWidth: screenWidth,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Ce champ est requis";
            }
            return null;
          },
          obscureText: _obscureText,
          toggleVisibility: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ],
    );
  }

  Widget _buildLoginButton(double screenWidth, Color buttonTextColor) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 10, 148, 116),
          foregroundColor: buttonTextColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: screenWidth * 0.27),
        ),
        onPressed: _login,
        child: Text(
          'Connexion',
          style: TextStyle(fontSize: screenWidth * 0.054),
        ),
      ),
    );
  }

  Widget _buildRegisterLink(BuildContext context, Color buttonTextColor) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Registerscreen()),
        );
      },
      child: Text(
        "Vous n'avez pas de compte?",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: buttonTextColor,
          fontSize: MediaQuery.of(context).size.width * 0.04,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _inputField(
      String labelText,
      String hintText,
      TextEditingController controller, {
        bool isPassword = false,
        required TextStyle labelStyle,
        required IconData icon,
        required double screenWidth,
        FormFieldValidator<String>? validator,
        bool obscureText = false,
        VoidCallback? toggleVisibility,
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
            hintStyle: TextStyle(
              color: labelStyle.color,
              fontWeight: FontWeight.bold,
            ),
            enabledBorder: border,
            focusedBorder: border,
            prefixIcon: Icon(icon),
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
              onPressed: toggleVisibility,
            )
                : null,
          ),
          obscureText: obscureText,
          validator: validator,
        ),
      ],
    );
  }
}
