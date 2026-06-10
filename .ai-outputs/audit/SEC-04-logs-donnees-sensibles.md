# SEC-04 — Logs exposant des données sensibles

> **Axe :** Sécurité · **Sévérité :** 🟠 Élevée · **Effort :** ~2-3h

## Problème

De nombreux logs écrivent des données sensibles dans la console système (Logcat / Xcode),
récupérables via `adb logcat` ou des outils de crash reporting :

- **Headers HTTP complets (token Bearer inclus)** — `lib/service/dio/dio_request.dart:236, 245, 252` :
  ```dart
  deboger("Url : $end \nheaders: ${option.headers}");
  prettyPrint(body, label: "corp"); // body complet des requêtes/réponses
  ```
- **Token FCM en clair** — `lib/service/firebase/fcm_service.dart:50, 57`
- **Données personnelles** — ex. `lib/screen/demarcheur/referrals/referral_detail_screen.dart:182-183`
  (téléphone + email), `lib/service/model/booking/reservation_service.dart:277`
  (clé secrète de réservation), `partenariat_demarcheur_service.dart:15` (téléphone).

## Impact

- Token Bearer extractible des logs → vol de session
- Fuite de données perso vers les logs système et services de crash externes

## Marche à suivre

1. **Dio (le plus urgent)** — dans `dio_request.dart`, ne plus jamais logger
   `option.headers` ni les bodies bruts. Logger uniquement méthode + URL + status :
   ```dart
   if (kDebugMode) deboger("→ ${option.method} ${option.uri}");
   if (kDebugMode) deboger("← $code ${resp.requestOptions.uri}");
   ```
2. **FCM** — remplacer le log du token par sa longueur ou ses 6 derniers caractères.
3. **Audit global** — passer en revue les sorties de :
   ```bash
   grep -rn "deboger\|debugPrint\|print(" lib/ | grep -iE "token|telephone|email|secret|password"
   ```
   et masquer chaque occurrence (longueur, domaine de l'email, derniers chiffres...).
4. **Garde-fou durable** — s'assurer que `deboger()`/`prettyPrint()` (dans `lib/util/`)
   sont no-op en release (`if (!kDebugMode) return;`). Ainsi même un oubli futur ne
   fuit pas en production.
5. **(Optionnel)** Ajouter une règle d'analyse (`avoid_print`) dans `analysis_options.yaml`.

## Validation

- [ ] `adb logcat` pendant un login complet : aucun token, email ou téléphone visible
- [ ] Le grep de l'étape 3 ne retourne plus de données sensibles loggées
- [ ] En build release, `deboger`/`prettyPrint` n'émettent rien
