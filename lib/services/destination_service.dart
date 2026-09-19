import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/destination.dart';

/// Service permettant de récupérer les destinations depuis Firestore.
class DestinationService {
  // Instance de Firestore utilisée pour communiquer avec la base de données.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Récupère toutes les destinations disponibles.
  Future<List<Destination>> recupererDestinations() async {
    // Récupère les documents de la collection "destinations".
    final resultat = await _firestore.collection('destinations').get();

    // Transforme chaque document Firestore en objet Destination.
    return resultat.docs.map((document) {
      return Destination.fromMap(document.id, document.data());
    }).toList();
  }
}
