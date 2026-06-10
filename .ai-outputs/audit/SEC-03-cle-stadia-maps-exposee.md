# SEC-03 — Clé API Stadia Maps exposée dans le code

> **Axe :** Sécurité · **Sévérité :** 🟠 Élevée · **Effort :** ~1-2h

## Problème

La clé API Stadia Maps est embarquée en dur dans le code :

- `lib/config/map_config.dart:12` :
  ```dart
  static const String _stadiaApiKey = 'd90155af-6b52-49d4-bbf0-1f9f555369a3';
  ```
- Utilisée dans les URLs de tuiles (lignes 16 et 19 du même fichier).

Toute personne qui décompile l'APK (ou lance `strings` sur le binaire) récupère la clé
et peut consommer le quota Stadia Maps au nom du compte du projet.

## Impact

- Utilisation abusive / facturation sur le compte Stadia Maps
- Blocage du service de cartes pour les vrais utilisateurs si le quota est épuisé

## Marche à suivre

1. **Révoquer la clé actuelle** dans le dashboard Stadia Maps (elle doit être considérée
   comme compromise dès maintenant) et en générer une nouvelle.
2. **Restreindre la nouvelle clé** côté Stadia Maps : limitation par bundle ID Android /
   iOS si l'offre le permet, sinon par domaine/référent.
3. **Sortir la clé du code source** — deux options :
   - **Option A (rapide)** : injection à la compilation :
     ```dart
     static const String _stadiaApiKey = String.fromEnvironment('STADIA_KEY');
     ```
     Build : `flutter build apk --dart-define=STADIA_KEY=xxx`. La clé reste dans le
     binaire mais disparaît du dépôt git.
   - **Option B (robuste)** : proxy backend — le Spring Boot expose
     `/api/map/tiles/{z}/{x}/{y}` et ajoute la clé côté serveur. La clé ne quitte
     jamais le serveur. Prévoir un cache de tuiles côté backend pour le quota.
4. **Purger l'historique git si le dépôt est partagé** (la clé y restera sinon) — au
   minimum, considérer l'étape 1 comme suffisante puisque la clé est révoquée.

## Validation

- [ ] L'ancienne clé `d90155af-...` est révoquée (tester : une requête tuile avec elle retourne 401/403)
- [ ] `grep -rn "d90155af" .` ne retourne plus rien dans le code actif
- [ ] La carte s'affiche normalement dans l'app avec la nouvelle configuration
