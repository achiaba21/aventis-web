# SEC-05 — Validation d'expiration du JWT et révocation au logout

> **Axe :** Sécurité · **Sévérité :** 🟡 Moyenne · **Effort :** ~½ journée (+ backend pour la révocation)

## Problème

1. **`validateToken()` ne valide rien** — `lib/service/auth/auth_manager.dart:76-87` :
   ```dart
   Future<bool> validateToken() async {
     final token = StorageService.instance.getToken();
     if (token == null || token.isEmpty) return false;
     // Vous pouvez ajouter ici une validation plus sophistiquée
     return true; // ← jamais de vérification d'expiration
   }
   ```
   Un token expiré est considéré valide jusqu'au premier 401 serveur → écran d'accueil
   chargé puis éjection brutale vers le login.

2. **Le logout est uniquement local** — `auth_manager.dart:58-74` supprime le token du
   device mais n'appelle aucun endpoint de révocation. Un token volé avant le logout
   reste utilisable jusqu'à son expiration naturelle.

## Impact

- UX dégradée (session "zombie" puis éjection au premier appel API)
- Fenêtre d'exploitation d'un token volé même après déconnexion volontaire

## Marche à suivre

1. **Ajouter la dépendance** :
   ```yaml
   jwt_decoder: ^2.0.1
   ```
2. **Compléter `validateToken()`** :
   ```dart
   if (JwtDecoder.isExpired(token)) {
     await logout();
     return false;
   }
   return true;
   ```
   Optionnel : considérer le token expiré quelques minutes avant l'`exp` réelle
   (marge d'horloge).
3. **Brancher la vérification au démarrage** (splash / router de rôle) pour rediriger
   directement vers le login au lieu d'attendre un 401.
4. **Backend** : créer `POST /auth/logout` qui blackliste le JWT (ou invalide la session).
5. **Côté app** : dans `logout()`, appeler cet endpoint **avant** le nettoyage local,
   en fire-and-forget (le logout local ne doit pas échouer si le réseau est coupé).
6. **(Phase 2)** Mettre en place un couple access token court / refresh token long avec
   rafraîchissement automatique dans l'intercepteur Dio sur 401.

## Validation

- [ ] Avec un token expiré en cache, l'app redirige vers le login sans appel API métier
- [ ] Après logout, rejouer l'ancien token contre l'API retourne 401 (révocation effective)
- [ ] Logout fonctionne même en mode avion
