# SEC-01 — Migration HTTP → HTTPS et WS → WSS

> **Axe :** Sécurité · **Sévérité :** 🔴 Critique (bloquant production) · **Effort :** ~1 jour (+ backend)

## Problème

Tout le trafic de l'application circule en clair :

- `lib/config/app_propertie.dart:43` — `final String domain = "http://$serveur:$port";`
- `lib/service/model/Auth/authentication_service.dart` — toutes les URLs d'auth (`urlLogin`, `urlOtpSend`, `urlOtpVerify`...) construites en `http://`
- `lib/service/websocket/websocket_service.dart:104` — `'ws://$serveur:$port/ws/websocket'`

Tokens JWT, codes OTP, mots de passe et données personnelles sont interceptables par
n'importe qui sur le même réseau (MITM sur WiFi public, réseau local, ISP).

## Impact

- Vol de session (token Bearer capturé en transit)
- Interception des OTP → contournement de l'authentification
- Exposition des données perso (téléphones, emails, réservations)

## Marche à suivre

1. **Backend (prérequis)** : exposer le Spring Boot derrière TLS — certificat Let's Encrypt
   via un reverse proxy (nginx/Caddy) ou directement dans Spring Boot.
2. **Centraliser le schéma** dans `app_propertie.dart` :
   ```dart
   const bool kUseTls = bool.fromEnvironment('USE_TLS', defaultValue: true);
   final String domain = "${kUseTls ? 'https' : 'http'}://$serveur:$port";
   ```
   En dev local : `flutter run --dart-define=USE_TLS=false`.
3. **Corriger toutes les URLs en dur** : grep `http://` dans `lib/` et faire pointer
   chaque service vers `domain` plutôt que de reconstruire l'URL.
4. **WebSocket** : dans `websocket_service.dart`, dériver le schéma du même flag :
   `wss://` quand TLS est actif.
5. **Verrouiller côté plateformes** :
   - Android : network security config refusant le cleartext en release
     (`cleartextTrafficPermitted="false"`).
   - iOS : ne PAS ajouter d'exception `NSAllowsArbitraryLoads` (ATS impose déjà HTTPS).
6. **(Optionnel, phase 2)** Certificate pinning via un intercepteur Dio une fois le
   certificat de prod stable.

## Validation

- [ ] `grep -rn "http://" lib/` ne retourne plus aucune URL backend en dur
- [ ] Login, OTP, listing appartements et WebSocket fonctionnent en HTTPS/WSS
- [ ] Build release Android refuse une connexion cleartext (test avec proxy)
