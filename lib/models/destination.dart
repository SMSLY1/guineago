/// Modèle représentant une destination touristique de GuineaGo.
class Destination {
  // Identifiant unique de la destination dans Firestore.
  final String id;

  // Nom de la destination.
  final String nom;

  // Région administrative.
  final String region;

  // Localité ou ville.
  final String localite;

  // Catégorie : Nature, Culture, Aventure ou Histoire.
  final String categorie;

  // Description de la destination.
  final String description;

  // URL de l'image de la destination.
  final String image;

  // Informations pratiques pour le visiteur.
  final String informationsPratiques;

  // Informations liées à l'écotourisme.
  final String ecotourisme;

  /// Constructeur du modèle.
  const Destination({
    required this.id,
    required this.nom,
    required this.region,
    required this.localite,
    required this.categorie,
    required this.description,
    required this.image,
    required this.informationsPratiques,
    required this.ecotourisme,
  });

  /// Transforme un document Firestore en objet Destination.
  factory Destination.fromMap(String id, Map<String, dynamic> data) {
    return Destination(
      id: id,
      nom: data['nom'] ?? '',
      region: data['region'] ?? '',
      localite: data['localite'] ?? '',
      categorie: data['categorie'] ?? '',
      description: data['description'] ?? '',
      image: data['image'] ?? '',
      informationsPratiques: data['informationsPratiques'] ?? '',
      ecotourisme: data['ecotourisme'] ?? '',
    );
  }

  /// Transforme une Destination en données utilisables par Firestore.
  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'region': region,
      'localite': localite,
      'categorie': categorie,
      'description': description,
      'image': image,
      'informationsPratiques': informationsPratiques,
      'ecotourisme': ecotourisme,
    };
  }
}
