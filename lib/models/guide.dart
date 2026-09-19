/// Modèle représentant un guide touristique de GuineaGo.
class Guide {
  // Identifiant unique du guide dans Firebase.
  final String id;

  // Nom complet du guide.
  final String nom;

  // Localité où le guide exerce.
  final String localite;

  // Région du guide.
  final String region;

  // Chemin de la photo du guide.
  final String image;

  // Note moyenne du guide.
  final double note;

  // Nombre d'avis reçus.
  final int nombreAvis;

  // Catégorie principale du guide.
  final String categorie;

  // Spécialité du guide.
  final String specialite;

  // Présentation du guide.
  final String description;

  // Numéro WhatsApp du guide.
  final String whatsapp;

  // Adresse e-mail du guide.
  final String email;

  /// Constructeur du modèle Guide.
  Guide({
    required this.id,
    required this.nom,
    required this.localite,
    required this.region,
    required this.image,
    required this.note,
    required this.nombreAvis,
    required this.categorie,
    required this.specialite,
    required this.description,
    required this.whatsapp,
    required this.email,
  });

  /// Convertit les données Firebase en objet Guide.
  factory Guide.fromMap(String id, Map<String, dynamic> data) {
    return Guide(
      id: id,
      nom: data['nom'] ?? '',
      localite: data['localite'] ?? '',
      region: data['region'] ?? '',
      image: data['image'] ?? '',
      note: (data['note'] ?? 0).toDouble(),
      nombreAvis: data['nombreAvis'] ?? 0,
      categorie: data['categorie'] ?? '',
      specialite: data['specialite'] ?? '',
      description: data['description'] ?? '',

      // Récupération du numéro WhatsApp.
      whatsapp: data['whatsapp'] ?? '',

      // Récupération de l'adresse e-mail.
      email: data['email'] ?? '',
    );
  }

  /// Convertit l'objet Guide en données Firebase.
  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'localite': localite,
      'region': region,
      'image': image,
      'note': note,
      'nombreAvis': nombreAvis,
      'categorie': categorie,
      'specialite': specialite,
      'description': description,

      // Enregistrement du numéro WhatsApp.
      'whatsapp': whatsapp,

      // Enregistrement de l'adresse e-mail.
      'email': email,
    };
  }
}
