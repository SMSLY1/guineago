import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/guide.dart';

/// Service permettant de récupérer les guides depuis Firestore.
class GuideService {
  // Connexion à la base de données Firestore.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Récupère tous les guides touristiques.
  Future<List<Guide>> recupererGuides() async {
    // Récupération de la collection "guides".
    final resultat = await _firestore.collection('guides').get();

    // Conversion des documents Firebase en objets Guide.
    return resultat.docs.map((document) {
      return Guide.fromMap(document.id, document.data());
    }).toList();
  }
}
