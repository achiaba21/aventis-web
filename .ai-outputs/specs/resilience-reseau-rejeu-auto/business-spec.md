# 📋 Spécification Métier — Résilience réseau « file d'attente + rejeu automatique »

> Statut : ✅ Validée par l'utilisateur le 2026-05-30
> Feature : `resilience-reseau-rejeu-auto`

## 1. Contexte
Aujourd'hui, lorsqu'un chargement de données échoue faute de réseau, l'utilisateur reste bloqué sur un écran d'erreur « mort » : même quand la connexion revient, rien ne se recharge — il faut fermer et relancer l'app. Friction majeure pour une app utilisée en mobilité (réseau instable).

## 2. Objectif
Tout chargement de données qui échoue **pour cause réseau** est mis en attente, puis **rejoué automatiquement et silencieusement dès que la connexion au serveur revient** — sans action utilisateur, sans redémarrage.

## 3. Acteurs
Tous les utilisateurs (locataire, propriétaire, démarcheur). Système transverse.

## 4. Règles Métier
- **R1 — Source de vérité connectivité** : l'état connecté/déconnecté provient EXCLUSIVEMENT du socket serveur existant (`websocket_service.dart`, `stateStream`). Pas de package tiers (pas de connectivity_plus). Le passage du socket à « connecté » déclenche le rejeu.
- **R2 — Distinction des erreurs** : distinguer une **erreur réseau** (mise en file + rejeu) d'une **erreur métier** (4xx/5xx applicatif — message classique, pas de rejeu). Seules les erreurs réseau sont rejouées.
- **R3 — Rejeu 100 % automatique** : aucun bouton « Réessayer ». Au retour réseau, tout ce qui était en attente se relance tout seul.
- **R4 — Affichage hors-ligne** : pendant la coupure, afficher les dernières données connues (cache Hive) + un bandeau global discret « Hors ligne / Reconnexion… ». Si aucun cache, état vide informatif. Jamais d'écran bloquant.
- **R5 — Couverture maximale** : mécanisme générique appliqué à TOUS les chargements de données serveur (annonces, carte, réservations, favoris, notifications, conversations, comptabilité…).
- **R6 — Pas de doublons** : une même demande déjà en attente n'est pas empilée plusieurs fois ; le rejeu ne déclenche pas de chargements redondants.
- **R7 — Périmètre lectures** : seules les lectures (GET) sont concernées en v1.

## 5. Cas d'Usage Principal
1. L'utilisateur ouvre un écran ; le chargement échoue (pas de réseau).
2. L'écran affiche le cache (ou état vide) + bandeau « Hors ligne ».
3. La demande de chargement est mise en file.
4. La connexion serveur revient (socket → connecté).
5. Les chargements en attente sont rejoués automatiquement ; bandeau disparaît ; données fraîches affichées.

## 6. Cas Alternatifs / Limites
- Erreur métier (non réseau) : pas de mise en file, message d'erreur classique.
- Cache disponible : consultation normale pendant la coupure.
- Coupures successives : bandeau et file mis à jour à chaque transition.
- HORS périmètre v1 : créations/modifications hors-ligne (réservation, annonce, message) + gestion de conflits → v2.

## 7. Contraintes
- Réutiliser le socket existant comme détecteur de connectivité (imposé).
- Réutiliser le cache Hive et le pattern BLoC existants.
- Aucune régression sur le comportement online actuel.

## 8. Critères d'Acceptation
- [ ] Couper puis rétablir le réseau SANS redémarrer → données chargées automatiquement.
- [ ] Bandeau « Hors ligne / Reconnexion… » visible pendant la coupure, disparaît au retour.
- [ ] Données en cache consultables hors-ligne.
- [ ] Erreur métier (ex. 404) non rejouée en boucle.
- [ ] Aucune action manuelle requise.
- [ ] Comportement online normal inchangé.

## 9. Décisions utilisateur (figées)
| Sujet | Décision |
|-------|----------|
| Affichage offline | Bannière + données en cache |
| Rejeu | 100 % automatique (aucun bouton) |
| Périmètre données | Tous les chargements de données |
| Écritures offline | HORS périmètre v1 (lectures seules) |
| Connectivité | Socket serveur existant uniquement |
