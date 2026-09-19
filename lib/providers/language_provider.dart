import 'package:flutter/material.dart';

/// Gère la langue actuellement utilisée dans GuineaGo.
///
/// Pour la V1, nous supportons :
/// - FR : Français
/// - EN : English
class LanguageProvider extends ChangeNotifier {
  // Langue utilisée au démarrage de l'application.
  String _langue = 'FR';

  /// Retourne la langue actuellement sélectionnée.
  String get langue => _langue;

  /// Change la langue de l'application.
  void changerLangue(String nouvelleLangue) {
    // Vérifie que la langue demandée est bien supportée.
    if (nouvelleLangue != 'FR' && nouvelleLangue != 'EN') {
      return;
    }

    // Évite de reconstruire l'application si la langue
    // sélectionnée est déjà la langue actuelle.
    if (_langue == nouvelleLangue) {
      return;
    }

    // Met à jour la langue.
    _langue = nouvelleLangue;

    // Informe les widgets que la langue a changé.
    notifyListeners();
  }
}
