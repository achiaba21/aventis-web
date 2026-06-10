# SEC-02 — Stockage sécurisé du token et chiffrement Hive

> **Axe :** Sécurité · **Sévérité :** 🔴 Critique · **Effort :** ~1 jour

## Problème

1. **Token JWT en clair dans SharedPreferences** — `lib/service/local_store.dart:11` :
   ```dart
   return pref.setString("token", token); // stockage non chiffré
   ```
   SharedPreferences est un simple fichier XML lisible sur appareil rooté / via backup.

2. **Boxes Hive non chiffrées** — `lib/service/storage/storage_service.dart:68-100` :
   toutes les boxes (`auth`, `user`, réservations, propriétaires, appartements) sont
   ouvertes sans `HiveAesCipher`. Données perso (emails, téléphones, adresses) en clair
   sur le disque.

## Impact

- Vol de session si l'appareil est compromis ou via extraction de backup
- Fuite de données personnelles (RGPD / réglementation locale)

## Marche à suivre

1. **Ajouter la dépendance** :
   ```yaml
   flutter_secure_storage: ^9.2.2
   ```
2. **Créer un `SecureTokenStore`** (nouveau fichier, ex. `lib/service/storage/secure_token_store.dart`)
   qui encapsule `FlutterSecureStorage` pour `getToken`/`setToken`/`deleteToken`.
   → Keychain sur iOS, Keystore sur Android.
3. **Migrer `local_store.dart`** : remplacer les appels SharedPreferences "token" par le
   `SecureTokenStore`. Prévoir une **migration one-shot** au démarrage : si un token
   existe encore dans SharedPreferences, le déplacer vers le secure storage puis le
   supprimer.
4. **Chiffrer Hive** :
   - Générer une clé AES 256 une seule fois, la stocker dans `flutter_secure_storage`.
   - Ouvrir les boxes sensibles avec le cipher :
     ```dart
     final key = await secureStorage.read(key: 'hive_key');
     await Hive.openBox(name, encryptionCipher: HiveAesCipher(base64Decode(key)));
     ```
   - Migration : à la première ouverture chiffrée, si une box claire existe, recopier
     les données puis supprimer l'ancienne box (`Hive.deleteBoxFromDisk`).
5. **Nettoyer au logout** : vérifier que `StorageService.clear()` + `SecureTokenStore.deleteToken()`
   effacent bien tout.

## Validation

- [ ] Aucune occurrence de `setString("token"` dans `lib/`
- [ ] Les fichiers `.hive` sur le device ne contiennent plus de données lisibles (vérifier avec `strings`)
- [ ] Login → kill app → relaunch : session restaurée (migration OK)
- [ ] Logout : token absent du secure storage
