# Mise à jour du dépôt vers COUTELYA V0.2

1. Décompresser `COUTELYA_V0_2_GITHUB_READY.zip`.
2. Ouvrir le dépôt GitHub `charlisadjevi-maker/COUTELYA`.
3. Remplacer/copier en priorité :
   - `lib/`
   - `assets/`
   - `pubspec.yaml`
   - `analysis_options.yaml`
   - `.github/workflows/android-apk.yml`
   - `supabase/schema.sql`
   - `README.md`
4. Faire `Commit changes`.
5. Ouvrir l'onglet `Actions`.
6. Suivre `Build COUTELYA V0.2 APK`.
7. Quand le workflow est vert, télécharger l'Artifact `coutelya-v0.2-apk-...`.

## Important
Le workflow génère le dossier Android automatiquement s'il n'existe pas.
La base SQLite passe en version 2 et conserve les clients déjà créés dans la V0.1.
