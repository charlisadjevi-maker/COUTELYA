# COUTELYA — Starter MVP Flutter

**COUTELYA** est une application mobile de gestion d'atelier de couture.
Signature : **Votre atelier, simplement.**

Ce starter couvre le socle technique du MVP :
- Flutter / Material 3
- stockage local SQLite (`sqflite`)
- architecture offline-first par repositories
- initialisation Supabase optionnelle par `--dart-define`
- écrans MVP : tableau de bord, clients, commandes, livraisons, plus
- schéma PostgreSQL/Supabase avec RLS pour un atelier mono-propriétaire
- statuts de synchronisation (`pending`, `synced`, `error`)

## 1. Pré-requis

- Flutter stable récent
- Android Studio ou VS Code avec Flutter/Dart
- Android SDK
- Un projet Supabase (facultatif pour démarrer en local)

## 2. Création du projet Flutter

Ce paquet contient le dossier `lib/` et les fichiers de configuration métier.
Créez d'abord le squelette natif Flutter puis copiez les fichiers :

```bash
flutter create --org com.coutelya coutelya
cd coutelya
```

Copiez ensuite dans le projet :
- `pubspec.yaml`
- le dossier `lib/`
- le dossier `supabase/`

Puis :

```bash
flutter pub get
flutter run
```

## 3. Lancer uniquement en local

Aucune clé Cloud n'est nécessaire.

```bash
flutter run
```

L'application utilisera SQLite sur le téléphone.

## 4. Activer Supabase

Créez le schéma avec `supabase/schema.sql`, puis lancez l'application avec :

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://VOTRE-PROJET.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=VOTRE_CLE_PUBLIQUE
```

N'utilisez jamais une clé `service_role` dans l'application mobile.

## 5. Architecture

```text
lib/
├── app.dart
├── main.dart
├── core/
│   ├── config/
│   ├── database/
│   ├── sync/
│   └── theme/
├── models/
├── repositories/
└── screens/
```

Principe :

```text
UI
 ↓
Repository  ← source unique de vérité
 ↙      ↘
SQLite     Supabase
local      cloud
```

Les écritures sont d'abord enregistrées localement avec `sync_status=pending`.
La synchronisation Cloud est ensuite déclenchée lorsque le réseau est disponible.

## 6. Prochain lot conseillé

1. Authentification réelle Supabase.
2. Création de l'atelier à la première connexion.
3. Synchronisation bidirectionnelle complète.
4. Écran Mesures.
5. Paiements.
6. Notifications de livraison.
7. Verrouillage des fonctions Pro.
8. Tests unitaires et tests d'intégration.

## Compilation automatique GitHub Actions

Le dépôt contient `.github/workflows/android-apk.yml`.
À chaque push sur `main`/`master`, GitHub Actions génère un APK release et le publie comme artifact téléchargeable.
Voir `docs/GITHUB_APK.md`.
