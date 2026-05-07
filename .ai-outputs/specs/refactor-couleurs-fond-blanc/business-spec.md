# 📋 Spécification Métier — Refactor couleurs & bascule fond blanc

**Feature** : `refactor-couleurs-fond-blanc`
**Date** : 2026-04-18
**Statut** : ✅ Validé par l'utilisateur

---

## 1. Contexte

L'application Asfar utilise aujourd'hui un thème sombre (fond `#1D1D1D`) avec un orange vif `#FFA02A` comme couleur principale. Le fichier `lib/service/providers/style.dart` est censé centraliser toutes les couleurs, mais **170+ fichiers contiennent des couleurs hardcodées** (`Color(0xFF...)`, `Colors.xxx`) qui contournent cette centralisation.

Cette dette technique empêche toute évolution visuelle cohérente : impossible de changer le thème sans toucher manuellement des centaines de fichiers.

## 2. Objectif

Transformer l'app vers une identité visuelle **claire et sobre** :
- Fond **blanc** en définitif (le mode sombre est abandonné)
- **Noir et blanc** comme couleurs dominantes (primaire/secondaire)
- **Orange** relégué au rôle d'**accent tertiaire** (touches ponctuelles)

Simultanément : garantir qu'**un seul fichier** pilote toutes les couleurs de l'app, sans aucune fuite résiduelle.

## 3. Acteurs

- **Utilisateurs finaux** (3 rôles : locataire, propriétaire, démarcheur) — perçoivent la nouvelle identité visuelle
- **Équipe de développement** — bénéficie d'une source unique pour toute future évolution graphique

## 4. Règles Métier

- **R1 — Hiérarchie des couleurs** : Blanc (fond) → Noir (texte/éléments principaux) → Orange (accent ponctuel : CTA, badges, éléments actifs)
- **R2 — Source unique** : aucune couleur ne doit être définie ailleurs que dans le fichier centralisé — les références à ce fichier sont la seule façon de colorer un élément
- **R3 — Lisibilité** : tous les textes, icônes et éléments interactifs doivent respecter un contraste suffisant sur fond blanc (accessibilité)
- **R4 — Cohérence transversale** : les palettes dépendantes (couleurs calendrier, couleurs d'appartements, avatars de messages) doivent être adaptées pour rester lisibles et esthétiques sur le nouveau fond clair
- **R5 — Pas de régression visuelle** : aucun écran ne doit devenir illisible ou incohérent après la bascule

## 5. Cas d'Usage Principal

1. L'utilisateur ouvre l'application
2. Il voit l'ensemble des écrans en thème clair (fond blanc, texte noir, accent orange)
3. Tous les éléments restent parfaitement lisibles et cohérents entre eux
4. L'expérience est homogène sur les 3 rôles (locataire, propriétaire, démarcheur)

## 6. Cas Alternatifs / Limites

- **Composants dépendant de la couleur du fond** (ombres, overlays, badges, icônes) : doivent être inversés pour rester visibles
- **Palettes de couleurs multiples** (calendrier avec 20 couleurs distinctes par appartement, avatars de messages à 8 couleurs) : revues pour rester lisibles sur blanc
- **Images, graphiques fl_chart, cartes OSM** : vérifier que les superpositions restent lisibles
- **États d'erreur/succès/warning** : conservent leur code couleur (rouge/vert/orange) mais adaptés si nécessaire pour le contraste

## 7. Contraintes

- **Scope transversal** : ~170 fichiers touchés (bascule en un seul bloc, pas de mode dark/light coexistants)
- **Pas d'option utilisateur de bascule** : le mode sombre est définitivement retiré
- **Conservation de la marque** : l'orange `#FFA02A` reste l'accent (mais en usage tertiaire)
- **Non-régression fonctionnelle** : aucune logique métier ne doit être impactée (changement purement visuel)

## 8. Critères d'Acceptation

- [ ] **C1** — Le fond principal de tous les écrans est blanc
- [ ] **C2** — Les textes principaux sont en noir (ou gris très foncé) lisibles sans effort
- [ ] **C3** — L'orange apparaît uniquement sur les éléments d'accent (boutons primaires, badges actifs, éléments sélectionnés)
- [ ] **C4** — Plus aucun `Color(0xFF...)` ou `Colors.xxx` n'est utilisé directement dans le code (hors du fichier centralisé)
- [ ] **C5** — Toutes les couleurs dérivées (surfaces, ombres, textes secondaires, inactifs) sont cohérentes avec le fond blanc
- [ ] **C6** — Les palettes calendrier (20 couleurs d'appartements) et avatars messages (8 couleurs) sont adaptées et restent esthétiques sur fond blanc
- [ ] **C7** — Aucun élément d'interface ne devient invisible (ex: ombres blanches, texte blanc sur blanc, icônes claires)
- [ ] **C8** — La barre de statut (statusbar) affiche des icônes sombres (lisibles sur fond clair)
- [ ] **C9** — Les 3 rôles (locataire, propriétaire, démarcheur) sont homogènes dans le nouveau thème
- [ ] **C10** — Le fichier unique des couleurs expose une API claire (noms sémantiques, sans doublons ni typos)
