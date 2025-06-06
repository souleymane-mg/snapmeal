const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendNotificationOnNewAnnonce = functions.firestore
  .document('Annonces/{annonceId}')
  .onCreate(async (snap, context) => {
    const newAnnonce = snap.data();

    // Préparer le payload de la notification
    const payload = {
      notification: {
        title: newAnnonce.titre_annonce,
        body: newAnnonce.contenu_annonce,
        imageUrl: newAnnonce.image_contenu, // Ajoutez cette ligne si vous voulez afficher une image
      },
    };

    // Envoyer la notification à tous les utilisateurs (ou un sujet spécifique)
    try {
      await admin.messaging().sendToTopic('all', payload);
      console.log('Notification envoyée avec succès');
    } catch (error) {
      console.error('Erreur lors de l\'envoi de la notification:', error);
    }
  });
