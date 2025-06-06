import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceClientScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Service client'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView( // Wrap the content with SingleChildScrollView
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nous contacter',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins-Bold',
              ),
            ),
            SizedBox(height: 20),
            _buildContactMethod(
              icon: Icons.phone,
              title: 'Téléphone',
              subtitle: 'Appelez-nous au +223 77777777',
              onTap: _makePhoneCall,
            ),
            SizedBox(height: 20),
            _buildContactMethod(
              icon: Icons.email,
              title: 'E-mail',
              subtitle: 'Envoyez-nous un e-mail à support@medicali.com',
              onTap: _sendEmail,
            ),
            SizedBox(height: 20),
            _buildContactMethod(
              icon: Icons.location_on,
              title: 'Adresse',
              subtitle: 'Bamako commune VI , cité unicef , port 20',
              onTap: _openMaps,
            ),
            SizedBox(height: 20),
            _buildContactMethod(
              icon: Icons.message,
              title: 'Formulaire de contact',
              subtitle: 'Remplissez notre formulaire de contact en ligne.',
              onTap: _openContactForm,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactMethod({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
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
              offset: Offset(0, 3),
            ),
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 3,
              blurRadius: 8,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.green),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins-Bold',
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontFamily: 'Poppins-Regular',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _makePhoneCall() async {
    final Uri phoneNumber = Uri.parse('tel:+223 77777777');
    if (await canLaunchUrl(phoneNumber)) {
      await launchUrl(phoneNumber);
    } else {
      throw 'N\'arrive pas à contacter $phoneNumber';
    }
  }

  void _sendEmail() async {
    final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: 'support@medicali.com',
        queryParameters: {
          'subject': 'Support Needed'
        }
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      throw 'N\'arrive pas à envoyer de mail';
    }
  }

  void _openMaps() async {
    final Uri googleMapsUrl = Uri.parse('https://www.google.com/maps/place/TechnoLAB+ISTA+-CITE+UNICEF/@12.5962642,-7.9756208,17.16z/data=!4m14!1m7!3m6!1s0xe51cd8a6b853a0b:0xfb6276042e6ae156!2sCit%C3%A9+des+enfants!8m2!3d12.5974662!4d-7.9733587!16s%2Fg%2F11s04nw2hp!3m5!1s0xe51cf0043214a81:0xfb5078b1660326a3!8m2!3d12.5945149!4d-7.9743576!16s%2Fg%2F11vtb28zp0?entry=ttu');
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else {
      throw 'N\'arrive pas à ouvrir la carte';
    }
  }

  void _openContactForm() async {
    final Uri contactFormUrl = Uri.parse('https://www.medicali.com/contact');
    if (await canLaunchUrl(contactFormUrl)) {
      await launchUrl(contactFormUrl);
    } else {
      throw 'N\'arrive pas à ouvrir le formulaire de contact';
    }
  }
}
