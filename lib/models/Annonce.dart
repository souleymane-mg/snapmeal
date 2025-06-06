import 'package:cloud_firestore/cloud_firestore.dart';

class Annonce {
  String auteurPost;
  String contenuAnnonce;
  String dateContenu;
  String heureAnnonce;
  String imageContenu;
  String titreAnnonce;

  Annonce({
    required this.auteurPost,
    required this.contenuAnnonce,
    required this.dateContenu,
    required this.heureAnnonce,
    required this.imageContenu,
    required this.titreAnnonce,
  });

  factory Annonce.fromDocument(DocumentSnapshot doc) {
    return Annonce(
      auteurPost: doc['auteur_post'],
      contenuAnnonce: doc['contenu_annonce'],
      dateContenu: doc['date_contenu'],
      heureAnnonce: doc['heure_annonce'],
      imageContenu: doc['image_contenu'],
      titreAnnonce: doc['titre_annonce'],
    );
  }
}
