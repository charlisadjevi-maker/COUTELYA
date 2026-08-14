COUTELYA V0.2.2 - Correctifs commandes et paramètres
====================================================

Fichiers à copier à la racine du dépôt GitHub COUTELYA en conservant les dossiers :
- lib/screens/orders_screens.dart
- lib/screens/more_screens.dart
- lib/repositories.dart
- lib/catalogs.dart

Améliorations :
1. Modification d'une commande depuis l'écran « Détail de commande » via l'icône crayon.
2. Le formulaire de modification reprend le client, modèle, tissu, couleur, prix, dates, description et notes.
3. Une avance ne peut jamais dépasser le prix total de la commande (validation interface + garde-fou repository).
4. En modification, le prix total ne peut pas devenir inférieur au montant déjà payé.
5. Les paramètres sont désormais actifs : Mon atelier, sauvegarde/synchronisation, catégories de mesures, catalogues de commandes, langue, sécurité et À propos ouvrent des écrans/actions.
6. L'écran des catalogues affiche les modèles de vêtements, tissus et couleurs utilisés par le formulaire de commande.
7. La synchronisation locale n'affiche plus un bouton désactivé : un contrôle d'état explicatif est accessible.

Après copie : Commit changes. GitHub Actions doit lancer automatiquement un nouveau Build COUTELYA APK.
