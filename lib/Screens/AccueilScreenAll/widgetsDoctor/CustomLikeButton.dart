import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomLikeButton extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String doctorPhotoURL;
  final bool isInitiallyLiked;

  const CustomLikeButton({
    Key? key,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.doctorPhotoURL,
    required this.isInitiallyLiked,
  }) : super(key: key);

  @override
  _CustomLikeButtonState createState() => _CustomLikeButtonState();
}

class _CustomLikeButtonState extends State<CustomLikeButton> {
  late bool isLiked;

  @override
  void initState() {
    super.initState();
    isLiked = widget.isInitiallyLiked;
    _checkIfLiked();
  }

  Future<void> _checkIfLiked() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot favSnapshot = await FirebaseFirestore.instance
          .collection('user_favorites')
          .doc(user.uid)
          .collection('favorites')
          .doc(widget.doctorId)
          .get();

      if (favSnapshot.exists) {
        setState(() {
          isLiked = true;
        });
      } else {
        setState(() {
          isLiked = false;
        });
      }
    }
  }

  Future<bool> onLikeButtonTapped(bool isCurrentlyLiked) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return !isCurrentlyLiked; // Ne changez pas l'état du bouton si l'utilisateur n'est pas connecté
    }

    final docRef = FirebaseFirestore.instance
        .collection('user_favorites')
        .doc(user.uid)
        .collection('favorites')
        .doc(widget.doctorId);

    if (isCurrentlyLiked) {
      // Retirer des favoris
      await docRef.delete();
    } else {
      // Ajouter aux favoris
      await docRef.set({
        'id': widget.doctorId,
        'name': widget.doctorName,
        'specialty': widget.doctorSpecialty,
        'photoURL': widget.doctorPhotoURL,
      });
    }

    return !isCurrentlyLiked;
  }

  @override
  Widget build(BuildContext context) {
    return LikeButton(
      isLiked: isLiked,
      circleColor: const CircleColor(start: Color(0xff00ddff), end: Color(0xff0099cc)),
      bubblesColor: const BubblesColor(
        dotPrimaryColor: Colors.pink,
        dotSecondaryColor: Colors.white,
      ),
      likeBuilder: (bool isLiked) {
        return Icon(
          Icons.favorite,
          color: isLiked ? Colors.red : Colors.grey,
        );
      },
      onTap: onLikeButtonTapped,
    );
  }
}