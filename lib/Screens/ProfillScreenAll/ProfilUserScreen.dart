import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:medecineproject/Screens/LoginScreen.dart';
import 'CustomConfirmationDialog.dart';
import 'SettingsScreen.dart';
import 'ModifierProfileScreen.dart';
import 'GererCompteScreen.dart';
import 'NotificationSettingsScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'FavoritesScreen.dart';
import 'package:provider/provider.dart';
import '../ProfillScreenAll/theme_provider.dart';

class ProfilUserScreen extends StatefulWidget {
  @override
  _ProfilUserScreenState createState() => _ProfilUserScreenState();
}

class _ProfilUserScreenState extends State<ProfilUserScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  File? _selectedImage;
  final picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  String _defaultPhotoURL = 'https://www.nicepng.com/png/detail/933-9332131_profile-picture-default-png.png';
  String? _photoURL;
  DateTime? _creationTime;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userProfile = await FirebaseFirestore.instance
          .collection('utilisateur')
          .doc(user.uid)
          .get();
      if (userProfile.exists) {
        setState(() {
          _nameController.text = userProfile['nom_usr'] ?? 'Nom non défini';
          _usernameController.text = userProfile['username'] ?? 'Nom d\'utilisateur non défini';
          _photoURL = userProfile['photoURL'] ?? _defaultPhotoURL;
          _creationTime = (userProfile['creationtime'] as Timestamp).toDate();
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
      }
    });
  }

  Future<void> _uploadImage() async {
    if (_selectedImage != null) {
      User? user = _auth.currentUser;
      if (user != null) {
        try {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('profile_images')
              .child('${user.uid}.jpg');
          await storageRef.putFile(_selectedImage!);
          final photoURL = await storageRef.getDownloadURL();

          await FirebaseFirestore.instance
              .collection('utilisateur')
              .doc(user.uid)
              .update({
            'photoURL': photoURL,
          });

          setState(() {
            _photoURL = photoURL;
            _selectedImage = null;
          });

          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Photo mise à jour')));
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Erreur lors de la mise à jour de la photo')));
        }
      }
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
  }

  void _showLogoutConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return CustomConfirmationDialog(
          onConfirm: () async {
            await _logout();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => Loginscreen()),
                  (Route<dynamic> route) => false,
            );
          },
        );
      },
      isScrollControlled: true,
    );
  }

  Widget buildCompteOption(BuildContext context, String title, Widget screen) {
    final buttonTextColor = Provider.of<ThemeProvider>(context).getButtonTextColor();
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: buttonTextColor,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: buttonTextColor,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    final isStabilized = width >= 460 && height >= 600;
    final stableWidth = isStabilized ? 460.0 : width;
    final stableHeight = isStabilized ? 600.0 : height;
    final buttonTextColor = Provider.of<ThemeProvider>(context).getButtonTextColor();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil',
          style: TextStyle(
            fontSize: 24,
            fontFamily: 'Poppins-SemiBold',
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: stableWidth * 0.05),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: stableHeight * 0.05),
              FutureBuilder<void>(
                future: _loadUserProfile(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: stableWidth * 0.2,
                            backgroundImage: _selectedImage != null
                                ? FileImage(_selectedImage!)
                                : NetworkImage(_photoURL ?? _defaultPhotoURL) as ImageProvider,
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _nameController.text,
                                  style: TextStyle(
                                    fontSize: stableWidth * 0.07,
                                    color: Colors.teal,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                GestureDetector(
                                  onTap: _pickImage,
                                  child: Text(
                                    'Changer Photo',
                                    style: TextStyle(
                                      fontSize: stableWidth * 0.05,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Depuis ${DateFormat('MM/yyyy').format(DateTime.now())}', // Assuming you want to display current date, adjust as necessary
                                  style: TextStyle(
                                    fontSize: stableWidth * 0.04,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: stableHeight * 0.07),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FavoritesScreen()),
                  );
                },
                child: _buildImageSection(
                  imagePath: 'assets/images/autres/profil_Images/favoris.png',
                  text: 'Vos Favoris',
                  width: stableWidth,
                  leftPadding: stableWidth * 0.1,
                  textColor: buttonTextColor,
                ),
              ),
              _buildImageSection(
                imagePath: 'assets/images/autres/profil_Images/payement.png',
                text: 'Payement',
                width: stableWidth,
                leftPadding: stableWidth * 0.1,
                textColor: buttonTextColor,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NotificationSettingsScreen()),
                  );
                },
                child: _buildImageSection(
                  imagePath: 'assets/images/autres/profil_Images/notification.png',
                  text: 'Gestion De Notification',
                  width: stableWidth,
                  leftPadding: stableWidth * 0.1,
                  textColor: buttonTextColor,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsScreen()),
                  );
                },
                child: _buildImageSection(
                  imagePath: 'assets/images/autres/profil_Images/parametre.png',
                  text: 'Paramètre',
                  width: stableWidth,
                  leftPadding: stableWidth * 0.1,
                  textColor: buttonTextColor,
                ),
              ),
              GestureDetector(
                onTap: () => _showLogoutConfirmation(context),
                child: _buildImageSection(
                  imagePath: 'assets/images/autres/profil_Images/déconnexion.png',
                  text: 'Déconnexion',
                  width: stableWidth,
                  leftPadding: stableWidth * 0.1,
                  textColor: buttonTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection({
    required String imagePath,
    required String text,
    required double width,
    required double leftPadding,
    required Color textColor,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        top: 20.0,
        left: leftPadding,
      ),
      child: Row(
        children: [
          Image.asset(
            imagePath,
            width: width * 0.1,
            height: width * 0.1,
            fit: BoxFit.cover,
          ),
          const SizedBox(width: 30),
          Text(
            text,
            style: TextStyle(fontSize: 20, color: textColor),
          ),
        ],
      ),
    );
  }
}
