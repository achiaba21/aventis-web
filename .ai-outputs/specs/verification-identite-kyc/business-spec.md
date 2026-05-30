# 📋 Spécification Métier — Vérification d'identité (KYC)

> Statut : en attente de validation utilisateur — 2026-05-30
> Feature : `verification-identite-kyc`

## 1. Contexte
Le backend expose un système KYC : un Propriétaire ou un Démarcheur envoie une pièce justificative (photo), un admin l'approuve/rejette. L'utilisateur est « vérifié » dès qu'au moins un document est au statut `VERIFIER`. Certaines actions sensibles (ex. demande de partenariat) sont bloquées par le serveur tant qu'aucun document n'est vérifié. Côté mobile, l'entrée « Vérification d'identité » du profil est aujourd'hui un placeholder statique.

## 2. Objectif
Permettre à un Propriétaire/Démarcheur d'envoyer une pièce d'identité, de suivre son statut, et de refléter partout dans l'app son état « vérifié / en attente / à renvoyer », avec rafraîchissement automatique au verdict admin.

## 3. Acteurs
- **Propriétaire** et **Démarcheur** : peuvent envoyer et consulter leurs documents.
- **Locataire** : ne peut pas envoyer (le serveur le refuse) → l'entrée KYC ne lui est pas proposée.

## 4. Règles Métier
- **R1** : seuls Propriétaire et Démarcheur envoient des documents.
- **R2** : « vérifié » = au moins un document `VERIFIER` (pas d'endpoint dédié → déduit de la liste).
- **R3** : statuts par document — `EN_ATTENTE` (modération), `VERIFIER` (approuvé), `REFUSER` (rejeté, avec motif).
- **R4** : envois illimités ; chaque envoi crée un document distinct (uuid).
- **R5** : après un rejet, pas de réédition : l'utilisateur **renvoie un nouveau** document ; l'ancien reste `REFUSER` (historique conservé et affiché).
- **R6** : fichier = **photo uniquement** en v1 (galerie ou caméra), `image/*`, max 5 Mo. (PDF accepté par le backend mais reporté.)
- **R7** : `titre` obligatoire, choisi dans une **liste prédéfinie** (CNI, Passeport, Permis de conduire, Carte consulaire, + « Autre »).
- **R8** : au verdict admin, le serveur envoie une notification (titre « Identité vérifiée » / « Document refusé ») → l'app rafraîchit l'écran KYC.
- **R9** : si une action sensible est bloquée faute de vérification, afficher une **bannière/message** renvoyant vers l'écran KYC.

## 5. Cas d'Usage Principal
1. L'utilisateur (proprio/démarcheur) ouvre Profil → « Vérification d'identité ».
2. L'écran affiche son statut global + l'historique de ses documents.
3. Il appuie « Envoyer une pièce », choisit un titre (liste) et une photo (galerie/caméra).
4. Upload → le document apparaît en `EN_ATTENTE` (badge).
5. L'admin approuve → notif reçue → l'écran se rafraîchit → statut `VERIFIER`, l'utilisateur est « vérifié » partout.

## 6. Cas Alternatifs / Limites
- **Rejet** : document `REFUSER` avec motif affiché + bouton « Renvoyer une pièce ».
- **Erreurs upload** (messages backend) : fichier vide, > 5 Mo, type non supporté, titre manquant, rôle non autorisé → message clair à l'utilisateur.
- **Hors ligne** : l'upload échoue proprement (réseau) ; la liste se recharge au retour (résilience réseau déjà en place).
- **Locataire** : entrée KYC non affichée.
- HORS périmètre v1 : PDF, endpoints admin, ré-édition d'un document refusé.

## 7. Contraintes
- Réutiliser `DioRequest` (Bearer auto + `postFormData`), `image_picker`, le canal `NotificationBloc`/WebSocket, et les atomes UI existants.
- URL fichier : `${domain}/${path}`.
- Respecter SOLID (nouveau code) + 10 règles Flutter.

## 8. Critères d'Acceptation
- [ ] Un proprio/démarcheur peut envoyer une photo avec un titre → document `EN_ATTENTE` visible.
- [ ] La liste affiche tous les documents avec statut ; motif visible si `REFUSER`.
- [ ] Le statut « vérifié » est déduit (≥ 1 `VERIFIER`) et reflété dans le profil.
- [ ] À l'approbation/rejet (notif), l'écran KYC se rafraîchit automatiquement.
- [ ] Après un refus, un bouton permet de renvoyer un nouveau document.
- [ ] Les erreurs backend sont affichées clairement.
- [ ] Une action bloquée faute de vérification renvoie vers l'écran KYC.
- [ ] Le locataire ne voit pas l'entrée KYC.

## 9. Décisions utilisateur (figées)
| Sujet | Décision |
|-------|----------|
| Types de fichier v1 | Photo seule (galerie + caméra) |
| Saisie du titre | Liste prédéfinie (+ « Autre ») |
| Incitation à se vérifier | Profil + bannière sur action bloquée |
| Affichage liste | Tout l'historique (tous statuts + motif) |
