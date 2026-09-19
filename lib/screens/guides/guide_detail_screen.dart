import 'package:flutter/material.dart';
import '../../models/guide.dart';
import 'package:url_launcher/url_launcher.dart';

class GuideDetailScreen extends StatelessWidget {
  final Guide guide;

  const GuideDetailScreen({super.key, required this.guide});

  // =====================================================
  // FONCTION POUR OUVRIR WHATSAPP
  // =====================================================

  Future<void> _ouvrirWhatsApp() async {
    // Numéro WhatsApp au format international.
    // Nous utilisons le numéro qui a fonctionné pendant le test.
    const numero = '224620300000';

    // Création du lien WhatsApp.
    final url = Uri.parse('https://wa.me/$numero');

    // Ouverture du lien dans le navigateur.
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  // =====================================================
  // FONCTION POUR OUVRIR L'APPLICATION E-MAIL
  // =====================================================

  Future<void> _ouvrirEmail() async {
    // Récupère l'adresse e-mail enregistrée dans Firebase.
    final email = guide.email.trim();

    // Vérifie si une adresse e-mail existe.
    if (email.isEmpty) {
      return;
    }

    // Création du lien e-mail.
    final url = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'Demande de visite avec ${guide.nom}',
        'body': 'Bonjour, je souhaite obtenir des informations.',
      },
    );

    // Ouverture de l'application e-mail.
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  // =====================================================
  // CONSTRUCTION DE LA PAGE
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // =================================================
      // BARRE SUPÉRIEURE
      // =================================================
      appBar: AppBar(
        // Bouton de retour.
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),

        // Titre de la page.
        title: const Text(
          'Détails du guide',
          style: TextStyle(
            color: Color(0xFF033D27),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF033D27),
        elevation: 0,
      ),

      // =================================================
      // CONTENU PRINCIPAL
      // =================================================
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =================================================
            // IMAGE DU GUIDE
            // =================================================
            Padding(
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  guide.image,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,

                  // Image de remplacement en cas d'erreur.
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 250,
                      color: const Color(0xFFE8F2EE),
                      child: const Center(
                        child: Icon(
                          Icons.person,
                          size: 70,
                          color: Color(0xFF033D27),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // =================================================
            // INFORMATIONS PRINCIPALES
            // =================================================
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom du guide.
                  Text(
                    guide.nom,
                    style: const TextStyle(
                      color: Color(0xFF033D27),
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Type de professionnel.
                  const Text(
                    'Guide touristique',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Localisation du guide.
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Color(0xFF033D27),
                        size: 18,
                      ),

                      const SizedBox(width: 6),

                      Expanded(
                        child: Text(
                          '${guide.localite}, ${guide.region}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // =================================================
                  // NOTE DU GUIDE
                  // =================================================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFFFFC107),
                          size: 22,
                        ),

                        const SizedBox(width: 8),

                        Text(
                          guide.note.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF033D27),
                          ),
                        ),

                        const SizedBox(width: 5),

                        Text(
                          '(${guide.nombreAvis} avis)',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // =================================================
                  // INFORMATIONS DU GUIDE
                  // =================================================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F7F3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informations du guide',
                          style: TextStyle(
                            color: Color(0xFF033D27),
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Spécialité du guide.
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.explore_outlined,
                              color: Color(0xFF033D27),
                              size: 20,
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                'Spécialité : ${guide.specialite}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Catégorie du guide.
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.category_outlined,
                              color: Color(0xFF033D27),
                              size: 20,
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                'Catégorie : ${guide.categorie}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Numéro WhatsApp.
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.phone_outlined,
                              color: Color(0xFF033D27),
                              size: 20,
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                'WhatsApp : ${guide.whatsapp}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Adresse e-mail.
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.email_outlined,
                              color: Color(0xFF033D27),
                              size: 20,
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                'E-mail : ${guide.email}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // =================================================
                  // DESCRIPTION DU GUIDE
                  // =================================================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F7F3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Color(0xFF033D27),
                              size: 22,
                            ),

                            const SizedBox(width: 8),

                            const Expanded(
                              child: Text(
                                'À propos de ce guide',
                                style: TextStyle(
                                  color: Color(0xFF033D27),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Description affichée une seule fois.
                        Text(
                          guide.description.isEmpty
                              ? 'Aucune description disponible.'
                              : guide.description,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // =================================================
                  // SECTION CONTACT
                  // =================================================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F7F3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Contacter le guide',
                          style: TextStyle(
                            color: Color(0xFF033D27),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // =================================================
                        // BOUTON WHATSAPP
                        // =================================================
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _ouvrirWhatsApp,

                            // Icône téléphone.
                            icon: const Icon(Icons.phone),

                            label: const Text('Contacter sur WhatsApp'),

                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF033D27),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // =================================================
                        // BOUTON E-MAIL
                        // =================================================
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _ouvrirEmail,

                            icon: const Icon(Icons.email_outlined),

                            label: const Text('Envoyer un e-mail'),

                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF033D27),

                              side: const BorderSide(color: Color(0xFF033D27)),

                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
