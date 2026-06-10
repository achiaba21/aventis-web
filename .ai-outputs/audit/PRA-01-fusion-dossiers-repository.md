# PRA-01 — Fusion des deux dossiers repository

> **Axe :** Praticité · **Sévérité :** 🟡 Moyenne (confusion structurelle) · **Effort :** ~2h

## Problème

Deux dossiers coexistent pour le même rôle architectural :

- `lib/repository/` — 2 fichiers : `charge_data_manager.dart`, `compte_repository.dart`
  (ce dernier est un simple wrapper de `CompteApiService`, **sans cache**)
- `lib/service/repository/` — les vrais repositories cache-first :
  `appartement_repository.dart`, `charge_repository.dart`, `reservation_repository.dart`

Au moment d'ajouter un nouveau repository, impossible de savoir lequel des deux dossiers
fait foi — le pattern diverge déjà (avec/sans cache Hive).

## Impact

- Confusion à chaque nouvelle feature touchant la couche données
- Risque de créer un 3ᵉ pattern divergent

## Marche à suivre

1. **Décréter `lib/service/repository/` comme emplacement canonique** (c'est là que
   vivent les repositories actifs avec cache).
2. **Déplacer** `lib/repository/compte_repository.dart` → `lib/service/repository/compte_repository.dart`.
3. **Statuer sur `charge_data_manager.dart`** : vérifier s'il fait doublon avec
   `lib/service/repository/charge_repository.dart` ; si oui, fusionner, sinon le
   déplacer aussi.
4. **Mettre à jour les imports** (principalement `lib/bloc/compte_bloc/compte_bloc.dart`) :
   ```bash
   grep -rn "repository/compte_repository\|charge_data_manager" lib/
   ```
5. **Supprimer le dossier `lib/repository/`** une fois vide.
6. **Documenter la convention** dans le CLAUDE.md du projet ou un README de
   `lib/service/repository/` : « tout repository vit ici ; il encapsule un service API
   et, si pertinent, un cache Hive via StorageService ».

## Validation

- [ ] `lib/repository/` n'existe plus
- [ ] `flutter analyze` sans erreur d'import
- [ ] L'app compile et l'écran compte fonctionne comme avant
