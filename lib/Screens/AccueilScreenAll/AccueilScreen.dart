import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'AideScreen/AideSreen.dart';
import 'AideScreen/SecourScreen.dart';
import 'Annonces/Annoucement.dart';
import 'DoctorsScreen.dart';
import 'PharmaciesScreen/PharmacyMapScreen.dart';
import 'package:flutter/material.dart'; // Assurez-vous que ce fichier ne déclare pas 'User'

class AccueilScreen extends StatelessWidget {

  @override

  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Accueil",
          style: TextStyle(
            fontSize: 24,
            fontFamily: 'Poppins-SemiBold',
          ),
        ),
        actions: [
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher un médecin, des médicaments, des articles...',
                  prefixIcon: Icon(Icons.search, color: Color(0xff4338CA)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              SizedBox(height: screenHeight * 0.010,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildIconButton(context, 'assets/images/autres/ImagesAccueil/Doctor.png', 'Docteur',  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DoctorsScreen()),
                    );
                  }),
                  _buildIconButton(context, 'assets/images/autres/ImagesAccueil/Pharmacy.png', 'Pharmacie', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PharmacyMapScreen()),
                    );
                  }),
                  _buildIconButton(context, 'assets/images/autres/ImagesAccueil/Ambulance.png', 'Ambulance', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SecourScreen()),
                    );
                  }),
                  _buildIconButton(context, 'assets/images/autres/ImagesAccueil/carbon_help.png', 'Aide', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AideScreen()),
                    );
                  }),
                ],
              ),
              SizedBox(height: screenHeight * 0.010,),
              CarouselSlider(
                options: CarouselOptions(

                  height: screenHeight * 0.25,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  aspectRatio: 4/3,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enableInfiniteScroll: true,
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  viewportFraction: 0.8, // Augmenter la largeur des items du carrousel
                ),
                items: [
                  _buildCarouselItem(context, 'Protection précoce pour ', 'la santé de votre famille', 'assets/images/autres/ImagesAccueil/med.jpg'),
                  _buildCarouselItem(context, 'Conseils de santé', 'pour toute la famille', 'assets/images/autres/ImagesAccueil/enceinte.jpg'),
                  _buildCarouselItem(context, 'Consultations rapides', 'avec des spécialistes', 'assets/images/autres/ImagesAccueil/dentiste.jpg'),
                ],
              ),
              SizedBox(height: screenHeight * 0.05,),
              _buildSectionTitle(context, 'Docteurs', 'Voir plus ➔', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DoctorsScreen()),
                );
              }),
              SizedBox(height: screenHeight * 0.02,),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('medecin_md').limit(5).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Something went wrong');
                    }

                    if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          children: List.generate(
                            5,
                                (index) => _buildDoctorCardPlaceholder(context),
                          ),
                        ),
                      );
                    }

                    return Row(
                      children: snapshot.data!.docs.map((doc) {
                        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

                        String name = data['nom_md'] ?? '';
                        String specialty = data['specialite_md'] ?? '';
                        String photoURL = data['photoURL'] ?? 'https://via.placeholder.com/150'; // Utiliser photoURL
                        return _buildDoctorCard(context, name, specialty, photoURL, 5.0, '');
                      }).toList(),
                    );
                  },
                ),
              ),
              SizedBox(height: screenHeight * 0.05,),
              _buildSectionTitle(context, 'Articles santé', 'Voir plus ➔', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AnnonceScreen()),
                );
              }),
              SizedBox(height: 10),
              _buildHealthArticle(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(BuildContext context, String imagePath, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(imagePath),
            ),
          ),
          SizedBox(height: 10),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, String action, VoidCallback onPressed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: onPressed,
          child: Text(action),
        ),
      ],
    );
  }

  Widget _buildDoctorCard(BuildContext context, String name, String specialty, String photoURL, double rating, String telephone) {
    return GestureDetector(
      onTap: () {
        print('Card tapped: $name');
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7, // Largeur proportionnelle à l'écran
        margin: EdgeInsets.only(right: 10),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(photoURL),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    specialty,
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 5),
                  Text(
                    telephone,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthArticle() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFF00916E).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.article,
                    color: Color(0xFF00916E),
                    size: 24,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Article sur la santé',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        'Cet article fournit des conseils de santé essentiels pour toute la famille.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselItem(BuildContext context, String title, String subtitle, String imagePath) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8, // Largeur proportionnelle à l'écran
      margin: EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.5),
              Colors.black.withOpacity(0.0),
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorCardPlaceholder(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7, // Largeur proportionnelle à l'écran
      margin: EdgeInsets.only(right: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Container(
            height: 20,
            width: 150,
            color: Colors.white,
          ),
          SizedBox(height: 8),
          Container(
            height: 20,
            width: 100,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
