# Spécification Métier — Refonte du Flux d'Inscription

## 1. Contexte

Le flux d'inscription actuel est fragmenté (2 écrans séparés selon le rôle), trop long (7 champs), sans vérification du numéro de téléphone. Il freine l'entrée des nouveaux utilisateurs et ne garantit pas la validité des numéros enregistrés.

## 2. Objectif

Remplacer les écrans d'inscription existants par un flux unique, simplifié et sécurisé : sélection du rôle → formulaire court → vérification OTP → création du compte.

## 3. Acteurs

Tout nouvel utilisateur de l'application, qu'il soit Locataire, Propriétaire ou Démarcheur.

## 4. Règles Métier

- Le formulaire collecte uniquement : **nom complet**, **numéro de téléphone**, **mot de passe (5 chiffres numériques)**
- Le rôle est sélectionné **avant** d'accéder au formulaire
- L'OTP doit être **vérifié avant** la création du compte
- Le code OTP comporte **4 chiffres**
- L'utilisateur dispose de **5 tentatives max** pour saisir le bon code. Au-delà : blocage
- Le renvoi du code suit des délais progressifs : **15s → 20s → 30s → 60s** entre chaque demande successive
- Le mot de passe est strictement **5 chiffres numériques** (pas de lettres, pas de caractères spéciaux)
- Les informations complémentaires (prénom, email, date de naissance, etc.) sont complétées ultérieurement dans le profil

## 5. Cas d'Usage Principal

1. L'utilisateur clique sur "Sign up" depuis l'écran de login
2. Il choisit son rôle : **Locataire**, **Propriétaire** ou **Démarcheur**
3. Il saisit son **nom complet**, son **numéro de téléphone** et son **mot de passe (5 chiffres)**
4. Il soumet → un SMS avec un code à **4 chiffres** est envoyé
5. Il saisit le code sur l'écran OTP
6. Le code est vérifié → le compte est créé → redirection vers le dashboard selon le rôle

## 6. Cas Alternatifs / Limites

- **Code invalide** : message d'erreur, nouvelle tentative possible (max 5). À la 5ème échec : blocage
- **Renvoi du code** : bouton disponible après délai progressif (15s → 20s → 30s → 60s), grisé pendant le délai
- **Numéro déjà utilisé** : erreur serveur affichée à l'utilisateur

## 7. Contraintes

- Pas de système parallèle : fichiers existants modifiés ou supprimés, jamais doublonnés
- Le DTO existant `UserReq` est conservé — le champ `type` transporte le rôle sélectionné
- Le nom complet est envoyé dans le champ `nom` du DTO (le champ `prenom` reste null à l'inscription)

## 8. Critères d'Acceptation

- [ ] Un seul point d'entrée pour l'inscription (lien depuis l'écran login)
- [ ] L'écran de sélection de rôle présente 3 options : Locataire, Propriétaire, Démarcheur
- [ ] Le formulaire contient exactement 3 champs : nom complet, téléphone, mot de passe
- [ ] Le mot de passe n'accepte que 5 chiffres numériques
- [ ] Un SMS avec code à 4 chiffres est envoyé avant la création du compte
- [ ] L'écran OTP affiche 4 cases de saisie individuelles
- [ ] Le bouton "Renvoyer" est désactivé pendant le délai progressif (15 → 20 → 30 → 60s)
- [ ] Après 5 tentatives échouées, l'écran OTP est bloqué avec message clair
- [ ] Après OTP validé, le compte est créé et l'utilisateur redirigé selon son rôle
- [ ] Les anciens écrans d'inscription (Signup, SignupDemarcheur) sont supprimés
