import 'package:flutter/material.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barre supérieure de la page
      appBar: AppBar(
        title: const Text('Maintenance'),
        backgroundColor: const Color(0xFF033D27),
        foregroundColor: Colors.white,
      ),

      // Contenu principal
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône de maintenance
              const Icon(
                Icons.construction_rounded,
                size: 100,
                color: Color(0xFFFFC107),
              ),

              const SizedBox(height: 24),

              // Titre principal
              const Text(
                'Fonctionnalité en maintenance',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF033D27),
                ),
              ),

              const SizedBox(height: 16),

              // Message explicatif
              const Text(
                'Cette fonctionnalité sera bientôt disponible. '
                'Merci pour votre patience.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 32),

              // Bouton pour revenir à la page précédente
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Retour'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF033D27),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
