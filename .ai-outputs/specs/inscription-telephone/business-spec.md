# Spécification Métier — Inscription simplifiée par téléphone

> **Date :** 2026-06-11 · **Statut :** ✅ Validée utilisateur
> Remplace le parcours décrit dans `.ai-outputs/specs/inscription-refonte/`
> (formulaire unique 6 champs + OTP en fin de parcours).

## 1. Contexte

L'inscription actuelle demande 6 champs sur un seul écran (nom, prénom, téléphone,
email, mot de passe, confirmation) avant la vérification OTP. C'est long, l'email
est superflu pour le marché cible, et le numéro n'est vérifié qu'en fin de parcours.

## 2. Objectif

Remplacer le formulaire unique par un parcours court en 3 étapes où le numéro de
téléphone est vérifié **avant** toute autre saisie : numéro → OTP → (nom + mot de
passe) → compte créé. L'email disparaît de l'inscription.

## 3. Acteurs

Tout nouvel utilisateur, **quel que soit son rôle** : locataire, propriétaire ou
démarcheur (flux unique ; le rôle reste sélectionné en amont via l'onboarding,
comme aujourd'hui).

## 4. Règles Métier

- **Étape 1 — Numéro** : seule saisie = numéro de téléphone. Si le numéro est
  **déjà utilisé**, l'erreur s'affiche ici, **avant** tout envoi d'OTP.
- **Étape 2 — OTP** : code à **4 chiffres** envoyé par SMS. Tentatives et blocage
  **gérés par le backend** (5 max). Renvoi du code avec délais progressifs
  **15s → 20s → 30s → 60s** (bouton grisé pendant le délai).
- **Étape 3 — Identité + mot de passe** (accessible uniquement après OTP vérifié) :
  **nom complet** + **mot de passe à 5 chiffres** (type PIN) + **confirmation**.
  Les deux saisies doivent correspondre.
- **Création du compte** à la validation de l'étape 3, puis entrée dans l'app
  selon le rôle.
- **Plus d'email** à l'inscription. Prénom, email et autres infos se complètent
  plus tard dans le profil.
- Pas de retour en arrière vers l'OTP une fois vérifié ; un retour depuis
  l'étape 3 ramène à la saisie du numéro (nouveau parcours).

## 5. Cas d'Usage Principal

1. Depuis l'onboarding, l'utilisateur choisit son rôle puis « Créer un compte »
2. Il saisit son numéro de téléphone → SMS envoyé
3. Il saisit le code à 4 chiffres → vérifié
4. Il saisit son nom complet, son code PIN (5 chiffres) et le confirme
5. Le compte est créé → il entre dans l'app avec son rôle

## 6. Cas Alternatifs / Limites

- **Numéro déjà utilisé** → erreur à l'étape 1, pas d'OTP envoyé, lien possible
  vers la connexion
- **Code OTP invalide** → message d'erreur, nouvelles tentatives (le backend
  bloque après 5 échecs)
- **Renvoi de code** → respecte les délais progressifs
- **Confirmation PIN différente** → erreur locale, pas d'appel serveur
- **Abandon en cours de parcours** → aucun compte créé

## 7. Contraintes

- Pas de système parallèle : les écrans existants sont remplacés, jamais doublonnés
- Le rôle continue d'arriver depuis l'onboarding (pas de nouvel écran de choix de rôle)
- Les règles OTP (tentatives, blocage) restent côté serveur — le mobile affiche
  les erreurs renvoyées

## 8. Critères d'Acceptation

- [ ] L'inscription ne demande plus d'email ni de prénom
- [ ] Impossible d'atteindre la saisie du mot de passe sans OTP vérifié
- [ ] Numéro déjà utilisé → erreur affichée avant l'envoi du SMS
- [ ] Mot de passe strictement 5 chiffres, avec confirmation obligatoire
- [ ] Renvoi OTP grisé selon les délais 15s → 20s → 30s → 60s
- [ ] Le flux est identique pour locataire, proprio et démarcheur
- [ ] Après création, l'utilisateur entre directement dans l'app avec le bon rôle
