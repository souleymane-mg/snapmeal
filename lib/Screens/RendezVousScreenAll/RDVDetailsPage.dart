import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class RDVDetailsPage extends StatelessWidget {
  final String documentId;

  const RDVDetailsPage({required this.documentId});

  Future<void> _launchMapsUrl(BuildContext context, String doctorId) async {
    // Vérifier les permissions de localisation
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Autorisation de localisation refusée.')));
        return;
      }
    }

    // Vérifier si les services de localisation sont activés
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Les services de localisation sont désactivés.')));
      return;
    }

    // Récupérer la localisation actuelle du patient
    Position position;
    try {
      position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Impossible de récupérer la position actuelle.')));
      return;
    }

    // Récupérer la localisation du médecin depuis la collection medecin_md
    DocumentSnapshot doctorSnapshot = await FirebaseFirestore.instance.collection('medecin_md').doc(doctorId).get();
    if (!doctorSnapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : Médecin non trouvé.')));
      return;
    }

    Map<String, dynamic>? doctorData = doctorSnapshot.data() as Map<String, dynamic>?;
    if (doctorData == null || !doctorData.containsKey('localisation_lieu')) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : Localisation du médecin non trouvée.')));
      return;
    }

    String destinationUrl = doctorData['localisation_lieu'];
    LatLng? destinationLatLng = _extractLatLngFromUrl(destinationUrl);

    if (destinationLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : Impossible d\'extraire les coordonnées de la localisation du médecin.')));
      return;
    }

    String googleMapsUrl = "https://www.google.com/maps/dir/?api=1&origin=${position.latitude},${position.longitude}&destination=${destinationLatLng.latitude},${destinationLatLng.longitude}&travelmode=driving";

    print("Navigating to URL: $googleMapsUrl"); // Pour vérifier l'URL formée

    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Impossible d\'ouvrir l\'URL de Google Maps.')));
    }
  }

  LatLng? _extractLatLngFromUrl(String url) {
    // Parse l'URL pour extraire les coordonnées
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;

    for (int i = 0; i < segments.length; i++) {
      if (segments[i].contains('@')) {
        final coords = segments[i].split('@').last.split(',');
        if (coords.length >= 2) {
          final lat = double.tryParse(coords[0]);
          final lng = double.tryParse(coords[1]);
          if (lat != null && lng != null) {
            return LatLng(lat, lng);
          }
        }
      }
    }
    return null;
  }

  void _showLocationInfo(BuildContext context, Map<String, dynamic> rdvData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (rdvData['type_consultation'] == 'clinique') ...[
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: AssetImage('assets/images/autres/Image_rdv/hopital.png'), // Chemin vers l'image de l'hôpital
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Votre rendez-vous aura lieu à la clinique. Veuillez suivre l\'itinéraire ci-dessous pour vous y rendre.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: Icon(Icons.directions, size: 24),
                  label: Text('Obtenir l\'itinéraire'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _launchMapsUrl(context, rdvData['id_medecin_rdv']);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Couleur du bouton
                    foregroundColor: Colors.white, // Couleur de l'icône et du texte
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                ),
              ] else ...[
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: AssetImage('assets/images/autres/Image_rdv/maison.png'), // Chemin vers l'image de la maison
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Le médecin vous contactera pour plus de détails.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails du RDV'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('rdv').doc(documentId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print("Error fetching document: ${snapshot.error}");
            return Center(child: Text('Une erreur est survenue.'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            print("No data found for documentId: $documentId");
            return Center(child: Text('Aucun détail trouvé.'));
          }
          var rdvData = snapshot.data!.data() as Map<String, dynamic>?;
          if (rdvData == null) {
            print("Invalid data for documentId: $documentId");
            return Center(child: Text('Données invalides.'));
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'CODE DE RENDEZ-VOUS',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    rdvData['rdv_code'].toString(),
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Ceci est votre code de rendez-vous. Il vous sera demandé lors de votre rencontre avec votre professionnel de la santé pour attester qu’il s\'agit bien de la personne avec laquelle il a rendez-vous.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _showLocationInfo(context, rdvData),
                  child: Text('Information sur le lieu du rendez-vous'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, // Couleur standard de la page
                    foregroundColor: Colors.white, // Couleur du texte
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
