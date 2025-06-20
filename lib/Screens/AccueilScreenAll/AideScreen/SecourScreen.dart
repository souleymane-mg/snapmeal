import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher

import '../PharmaciesScreen/SendPositionScreen.dart'; // Import the SendPositionScreen
import 'NumeroUrgence.dart'; // Import the NumeroUrgence screen

class SecourScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Contactez les secours',
          style: TextStyle(
              fontSize: 24,
              fontFamily: 'Poppins-Medium',
              color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 65.0), // Horizontal padding only
        child: Column(
          children: [
            SizedBox(height: 70), // Space between the top and the first card
            _buildCard(
              context,
              Image.asset(
                'assets/Icons/telephone.png',
                height: 120.0, // Increased image height
                width: 90.0, // Increased image width
              ),
              'Appelé une ambulance',
              'N\'hésitez pas à appelé une ambulance pour vous ou pour autrui',
              _makePhoneCall, // Call function to make a phone call
            ),
            SizedBox(height: 30), // Space between the first and second card
            _buildCard(
              context,
              Image.asset(
                'assets/Icons/PointExclamation.png',
                height: 120.0, // Increased image height
                width: 90.0, // Increased image width
              ),
              'SOS',
              'Envoyer sa position à une pour signaler une situation de danger',
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NumeroUrgence()), // Navigate to NumeroUrgence
                );
              },
            ),
            SizedBox(height: 70), // Space between the second card and the bottom
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, Widget icon, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 10,
              offset: Offset(0, 3), // changes position of shadow
            ),
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 3,
              blurRadius: 8,
              offset: Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          children: [
            icon,
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft, // Align title to the left
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins-Bold', // Apply the bold font
                ),
              ),
            ),
            SizedBox(height: 5),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontFamily: 'Poppins-Regular', // Apply the regular font
              ),
              textAlign: TextAlign.left, // Left-align subtitle text
            ),
          ],
        ),
      ),
    );
  }

  // Function to make a phone call
  void _makePhoneCall() async {
    const phoneNumber = 'tel:80331';
    if (await canLaunch(phoneNumber)) {
      await launch(phoneNumber);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }
}
