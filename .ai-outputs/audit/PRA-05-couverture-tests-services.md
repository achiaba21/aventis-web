# PRA-05 — Couvrir la couche services / repositories par des tests

> **Axe :** Praticité · **Sévérité :** 🟠 Élevée (risque de régression) · **Effort :** ~2 jours

## Problème

~26 fichiers de test pour 672 fichiers source (~4 %). La couverture existante est
concentrée sur `lib/util/calc/` (18 tests) et 3 blocs wizard. **Zéro test** sur :

- Les services API (`lib/service/model/` — 18 services)
- Les repositories (`lib/service/repository/`)
- `DioRequest` (retry, gestion 401, intercepteurs)

Or c'est précisément la couche qui casse quand le backend évolue (cf. fix « parsing
résilient » du lot modération, découvert en manuel).

## Impact

- Régressions silencieuses sur le parsing API et le cache
- Peur de refactorer la couche données (cf. PRA-02) faute de filet

## Marche à suivre

1. **Outillage** : ajouter en dev_dependencies si absents :
   ```yaml
   mocktail: ^1.0.4
   http_mock_adapter: ^0.6.1   # mock des réponses Dio
   ```
2. **Prioriser 6 cibles à fort levier** :
   | Cible | Ce qu'on teste |
   |---|---|
   | `ResponseMapper` | wrapper `{body}`, items corrompus ignorés, listes vides |
   | `DioRequest` | retry GET avec backoff, 401 → logout, propagation timeout |
   | `AppartementService` | mapping `getAppartements`, payload `saveAppartement` |
   | `ReservationService` | `createReservation` succès / body malformé |
   | `AppartementRepository` | cache-first : cache rendu immédiatement, refresh en fond, `isCacheStale` |
   | `ReservationRepository` | fallback cache quand l'API échoue |
3. **Pattern** : mocker au niveau Dio (`http_mock_adapter`) pour les services, mocker
   les services pour les repositories. Pour Hive en test : `Hive.init(tempDir)`.
4. **Fixtures réalistes** : enregistrer de vraies réponses JSON du backend dans
   `test/fixtures/*.json` — elles documentent le contrat et détectent les dérives.
5. **Brancher en CI** (ou hook local) : `flutter test` obligatoire avant merge.
6. **Règle d'or ensuite** : toute nouvelle feature touchant un service/repository
   livre son test (déjà dans le workflow agent Audit).

## Validation

- [ ] `flutter test` vert avec les 6 nouvelles suites
- [ ] Un body backend volontairement malformé dans une fixture fait échouer le test correspondant
- [ ] PRA-02 (centralisation extractBody) peut se faire sous protection de ces tests
