# Spécification Métier — Carte Interactive Démarcheur

**Feature :** `demarcheur-carte-interactive`
**Statut :** ✅ Validé par l'utilisateur (2026-05-28)
**Auteur BA :** Agent Business Analyst

---

## 1. Contexte

Le démarcheur dispose aujourd'hui d'une carte minimaliste (`ListingMapView`) qui affiche statiquement ses logements partenaires, sans recherche géographique, sans feedback d'état, sans pattern Yango. La carte du locataire a été enrichie d'une chaîne complète (MapBloc, endpoints backend, InteractiveMapPicker, MapSearchBar, overlays, bandeau zone) et l'ambition initiale couvrait les deux rôles. Il faut maintenant **brancher le démarcheur sur cette chaîne mutualisée**.

## 2. Objectif

Apporter au démarcheur la **même UX de carte interactive** que le locataire (pattern Yango + recherche + filtres backend + feedback d'état), **scopée à son réseau partenaires** (filtrage déjà géré côté serveur via l'authentification).

## 3. Acteurs

- **Démarcheur** authentifié — utilisateur principal de la carte
- **Backend Asfar** — gère le filtrage par réseau partenaires en fonction du token

## 4. Règles Métier

- 🔐 **Scope serveur** : l'endpoint `/api/map/appartements/filtered` retourne automatiquement uniquement les **logements partenaires** du démarcheur authentifié. Aucun filtrage côté Flutter.
- 🎯 **Pattern Yango** : marker central fixe (cercle accent au centre) + carte qui glisse sous le doigt. Le centre définit la zone de recherche.
- 📍 **Pins prix individuels** : chaque logement partenaire dans le rayon de recherche apparaît avec son pin prix (`MapPricePin`), identique au locataire.
- 👆 **Tap pin → détail logement** : réutilisation du **mécanisme d'affichage détail déjà existant** côté démarcheur (page de logement accessible aussi depuis la liste).
- 🔍 **Recherche textuelle** : barre de recherche (`MapSearchBar`) avec geocoding via `/api/map/search` pour recentrer la carte rapidement (ex: "Cocody").
- 🎚️ **Filtres locaux conservés** : les filtres actuels (pièces / partenaire / zone) restent **frontend** comme aujourd'hui. Pas d'ajout des filtres locataire (prix / dates / capacité / commodités).
- 🚫 **Pas de real-location** : le démarcheur ne réservant pas pour lui-même, l'endpoint `/api/map/appartements/{id}/real-location` n'est **pas branché**.
- 🔄 **Toggle carte/liste préservé** : conserve la bascule existante dans `DemarcheurListingsScreen`. La carte ne remplace pas la liste.

## 5. Cas d'Usage Principal

1. Le démarcheur ouvre `DemarcheurListingsScreen` et bascule en mode carte
2. La carte se charge centrée sur sa position (ou position par défaut) — overlay loading visible
3. Le backend renvoie les logements partenaires dans le rayon → pins prix affichés
4. Bandeau bas (`MapZoneBanner`) indique : "X partenaires dans cette zone"
5. Le démarcheur **déplace la carte** (pattern Yango) → debounce 300ms → reload automatique des logements de la nouvelle zone
6. Le démarcheur **tape un pin** → ouverture du détail logement (page existante)
7. Le démarcheur **tape la search bar** → geocode "Cocody" → carte recentre + reload zone
8. Les filtres locaux actuels (pièces/partenaire/zone) restent appliqués sur les résultats

## 6. Cas Alternatifs / Limites

- **Aucun partenaire dans la zone** → `MapEmptyOverlay` (« Aucun logement partenaire ici »)
- **Erreur réseau** → `MapErrorOverlay` avec bouton Retry
- **Recherche textuelle infructueuse** → message inline dans la search bar
- **Géolocalisation refusée** → fallback sur position par défaut (Abidjan)
- **Démarcheur sans aucun partenaire** → carte vide + état spécifique (à valider en archi)

## 7. Contraintes

- ⚙️ **Réutilisation** : utiliser au maximum les composants partagés (`InteractiveMapPicker`, `MapSearchBar`, `MapZoneBanner`, 3 overlays, `MapView`, `MapPricePin`)
- 🧩 **SOLID** : conformément aux `SOLID_GUIDELINES.md` du projet, créer un **BLoC dédié `DemarcheurMapBloc`** plutôt que de réutiliser `MapBloc` avec flag (séparation par rôle)
- 🔌 **Backend déjà prêt** : aucun changement d'endpoint côté serveur — le scoping est implicite à l'authentification
- 📱 **Performance** : debounce 300ms sur les déplacements (comme locataire)
- 🎨 **Cohérence visuelle** : même charte que la carte locataire (accent orange, tuiles OSM, animations)

## 8. Critères d'Acceptation

- [ ] Le démarcheur voit ses logements partenaires sur une carte interactive avec pattern Yango
- [ ] Pins prix individuels visibles, tap → page détail existante
- [ ] Barre de recherche fonctionnelle (geocoding via `/api/map/search`)
- [ ] Déplacement de carte → debounce 300ms → reload zone automatique
- [ ] Bandeau bas affiche le nombre de partenaires dans la zone
- [ ] Overlays loading / error / empty visibles selon l'état
- [ ] Filtres existants (pièces / partenaire / zone) continuent de fonctionner sur la nouvelle carte
- [ ] Toggle carte/liste préservé dans `DemarcheurListingsScreen`
- [ ] Aucun appel à `/real-location` n'est effectué
- [ ] Le code respecte SOLID (BLoC `DemarcheurMapBloc` dédié)
