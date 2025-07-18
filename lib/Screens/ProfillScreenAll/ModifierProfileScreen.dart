import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ModifierProfileScreen extends StatefulWidget {
  @override
  _ModifierProfileScreenState createState() => _ModifierProfileScreenState();
}

class _ModifierProfileScreenState extends State<ModifierProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _vaccinationsController = TextEditingController();
  final TextEditingController _allergiesConnuesController = TextEditingController();
  final TextEditingController _antecedentsMedicauxController = TextEditingController();
  final TextEditingController _emergencyNumberController = TextEditingController(); // Nouveau contrôleur
  File? _image;
  final picker = ImagePicker();
  String? _selectedGroupeSanguin;
  String _defaultPhotoURL = 'https://img.freepik.com/vecteurs-premium/icone-profil-avatar-par-defaut-image-utilisateur-medias-sociaux-icone-avatar-gris-silhouette-profil-vierge-illustration-vectorielle_561158-3467.jpg?w=740'; // URL de l'image par défaut
  String? _photoURL;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userProfile = await FirebaseFirestore.instance
          .collection('utilisateur') // Utilisation de la collection 'utilisateur'
          .doc(user.uid)
          .get();
      if (userProfile.exists) {
        setState(() {
          _nameController.text = userProfile['nom_usr'];
          _usernameController.text = userProfile['username'] ?? '';
          _vaccinationsController.text = userProfile['vaccinations'] ?? '';
          _selectedGroupeSanguin = userProfile['groupe_sanguin'] ?? null;
          _allergiesConnuesController.text = userProfile['allergies_connues'] ?? '';
          _antecedentsMedicauxController.text = userProfile['antecedents_medicaux'] ?? '';
          _emergencyNumberController.text = userProfile['numero_urgence'] != null
              ? userProfile['numero_urgence'].replaceFirst('+223', '')
              : '';
          _photoURL = userProfile['photoURL'] ?? _defaultPhotoURL;
        });
      }
    }
  }

  Future<void> _updateUserProfile() async {
    if (_formKey.currentState!.validate()) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String photoURL = _photoURL ?? _defaultPhotoURL;
        if (_image != null) {
          final storageRef = FirebaseStorage.instance.ref().child('profile_images').child('${user.uid}.jpg');
          await storageRef.putFile(_image!);
          photoURL = await storageRef.getDownloadURL();
        }

        DocumentReference userRef = FirebaseFirestore.instance.collection('utilisateur').doc(user.uid); // Utilisation de la collection 'utilisateur'

        await userRef.set({
          'nom_usr': _nameController.text,
          'username': _usernameController.text,
          'vaccinations': _vaccinationsController.text,
          'groupe_sanguin': _selectedGroupeSanguin,
          'allergies_connues': _allergiesConnuesController.text,
          'antecedents_medicaux': _antecedentsMedicauxController.text,
          'numero_urgence': '+223${_emergencyNumberController.text}', // Sauvegarder le numéro d'urgence avec préfixe
          'photoURL': photoURL,
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profil mis à jour')));
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _deletePhoto() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final storageRef = FirebaseStorage.instance.ref().child('profile_images').child('${user.uid}.jpg');
      try {
        await storageRef.delete();
      } catch (e) {
        // Handle error if the file does not exist
      }
      DocumentReference userRef = FirebaseFirestore.instance.collection('utilisateur').doc(user.uid); // Utilisation de la collection 'utilisateur'
      await userRef.update({'photoURL': _defaultPhotoURL});
      setState(() {
        _photoURL = _defaultPhotoURL;
        _image = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Photo supprimée')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Modifier Profile',
          style: TextStyle(
            fontSize: 22,
            fontFamily: 'Poppins-Medium',
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: screenWidth * 0.15,
                        backgroundImage: _image != null
                            ? FileImage(_image!)
                            : NetworkImage(_photoURL ?? _defaultPhotoURL) as ImageProvider,
                      ),
                    ),
                    if (_photoURL != _defaultPhotoURL)
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: _deletePhoto,
                      ),
                  ],
                ),
                SizedBox(height: screenWidth * 0.05),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nom',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre nom';
                    }
                    return null;
                  },
                ),
                SizedBox(height: screenWidth * 0.05),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Nom d\'utilisateur',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre nom d\'utilisateur';
                    }
                    return null;
                  },
                ),
                SizedBox(height: screenWidth * 0.05),
                TextFormField(
                  controller: _vaccinationsController,
                  decoration: InputDecoration(
                    labelText: 'Vaccinations',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: screenWidth * 0.05),
                _buildGroupeSanguinDropdown(),
                SizedBox(height: screenWidth * 0.05),
                TextFormField(
                  controller: _allergiesConnuesController,
                  decoration: InputDecoration(
                    labelText: 'Allergies connues',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: screenWidth * 0.05),
                TextFormField(
                  controller: _antecedentsMedicauxController,
                  decoration: InputDecoration(
                    labelText: 'Antécédents médicaux importants',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: screenWidth * 0.05),
                TextFormField(
                  controller: _emergencyNumberController, // Champ de texte pour le numéro d'urgence
                  decoration: InputDecoration(
                    labelText: 'Numéro d\'urgence',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un numéro d\'urgence';
                    } else if (value.length != 8) {
                      return 'Le numéro d\'urgence doit comporter 8 chiffres';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  maxLength: 8, // Limiter à 8 chiffres
                ),
                SizedBox(height: screenWidth * 0.05),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 10, 148, 116), // Background color
                    foregroundColor: const Color(0xFFFFFFFF), // Text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Rounded corners
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: screenWidth * 0.03,
                      horizontal: screenWidth * 0.27, // Adjust horizontal padding as needed
                    ),
                  ),
                  onPressed: _updateUserProfile,
                  child: Text(
                    'Mettre à jour',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupeSanguinDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGroupeSanguin,
      hint: Text('Sélectionnez votre groupe sanguin'),
      items: <String>['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
          .map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedGroupeSanguin = newValue;
        });
      },
      decoration: InputDecoration(
        labelText: 'Groupe sanguin',
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
    );
  }
}
