import 'package:flutter/foundation.dart';

import '../services/local_storage_service.dart';

/// Gestionnaire global des destinations favorites de GuineaGo.
class FavoritesProvider extends ChangeNotifier {
  final LocalStorageService _localStorageService = LocalStorageService();

  // Ensemble des identifiants des destinations favorites.
  Set<String> _favoris = {};

  // Permet aux écrans de consulter les favoris.
  Set<String> get favoris => _favoris;

  /// Charge les favoris sauvegardés sur le téléphone.
  Future<void> chargerFavoris() async {
    final favorisSauvegardes = await _localStorageService.recupererFavoris();

    _favoris = favorisSauvegardes.toSet();

    notifyListeners();
  }

  /// Vérifie si une destination est favorite.
  bool estFavori(String destinationId) {
    return _favoris.contains(destinationId);
  }

  /// Ajoute ou retire une destination des favoris.
  Future<void> basculerFavori(String destinationId) async {
    if (_favoris.contains(destinationId)) {
      _favoris.remove(destinationId);
    } else {
      _favoris.add(destinationId);
    }

    await _localStorageService.sauvegarderFavoris(_favoris.toList());

    // Actualise tous les écrans connectés au Provider.
    notifyListeners();
  }

  /// Retire une destination des favoris.
  Future<void> retirerFavori(String destinationId) async {
    _favoris.remove(destinationId);

    await _localStorageService.sauvegarderFavoris(_favoris.toList());

    notifyListeners();
  }
}
