import 'package:flutter/material.dart';

class GuideScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Guide d\'utilisation'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Bienvenue sur l\'application de gestion de votre Santé ',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins-Bold',
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: 'Medicali',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins-Bold',
                      color: Colors.green, // Couleur verte pour "Medicali"
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            _buildGuideSection(
              'Gestion des rendez-vous hospitaliers',
              'Planifiez et gérez vos rendez-vous hospitaliers en toute simplicité. Vous pouvez créer, modifier et annuler des rendez-vous directement depuis l\'application. '
                  'Des notifications vous rappelleront vos rendez-vous à venir pour ne jamais en manquer un.',
            ),
            SizedBox(height: 20),
            _buildGuideSection(
              'Recherche de pharmacies',
              'Trouvez des pharmacies à proximité en fonction de votre position actuelle. Utilisez la fonctionnalité de géolocalisation pour afficher une liste de pharmacies proches, avec leurs horaires d\'ouverture et leurs coordonnées.',
            ),
            SizedBox(height: 20),
            _buildGuideSection(
              'Rappels de médicaments',
              'Recevez des rappels pour prendre vos médicaments à temps. Configurez des notifications pour chaque médicament avec l\'heure et la fréquence de prise. Vous pouvez également marquer les médicaments comme pris directement depuis la notification.',
            ),
            SizedBox(height: 20),
            _buildGuideSection(
              'Autres fonctionnalités',
              'Vous pouvez également recevoir des newsletters, appeler directement les services d\'ambulance ou envoyer un SOS à une personne de confiance.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideSection(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins-Bold',
          ),
        ),
        SizedBox(height: 10),
        Text(
          description,
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Poppins-Regular',
          ),
        ),
      ],
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: GuideScreen(),
  ));
}
