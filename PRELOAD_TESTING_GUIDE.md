# Guide de Test du Préchargement Transparent

## 🎯 Objectif

Ce système permet de **naviguer instantanément vers le dashboard** sans attendre le chargement des données. Les données se chargent **en arrière-plan de manière transparente** pendant que l'utilisateur voit des **skeletons animés**.

---

## 🧪 Comment Tester

### 1. Test Basique - Locataire

1. **Ouvrir l'application**
2. **Se connecter en tant que locataire**
3. **Observer** :
   - ✅ Le dashboard s'affiche **immédiatement** (pas d'attente)
   - ✅ L'écran Explore affiche des **skeletons animés** pendant 1-2 secondes
   - ✅ Les appartements s'affichent **progressivement**
   - ✅ Regarder dans les logs : `[main.dart] Démarrage du préchargement pour <nom>`

4. **Naviguer entre les onglets** :
   - Favorites → Devrait afficher des skeletons puis les favoris
   - Booking → Devrait afficher des skeletons puis les réservations
   - Inbox → Devrait afficher des skeletons puis les conversations

5. **Revenir sur Explore** :
   - ✅ Les données s'affichent **instantanément** (déjà en cache)
   - ❌ Pas de rechargement ni de skeleton

---

### 2. Test Basique - Propriétaire

1. **Ouvrir l'application**
2. **Se connecter en tant que propriétaire**
3. **Observer** :
   - ✅ Le dashboard s'affiche **immédiatement**
   - ✅ L'onglet "Listings" affiche des **skeletons animés**
   - ✅ Les appartements s'affichent **progressivement**

4. **Naviguer vers "Résidences"** :
   - ✅ Skeletons animés pendant le chargement
   - ✅ Résidences s'affichent progressivement

5. **Revenir sur "Home"** :
   - ✅ Données affichées **instantanément** (cache)

---

### 3. Test Réseau Lent (Important !)

**Objectif** : Voir clairement les skeletons en action

**Méthode** :

#### Option A : Via Flutter DevTools (Recommandé)
1. Lancer l'app : `flutter run`
2. Ouvrir DevTools
3. Onglet "Network" → Throttle : "Slow 3G"
4. Redémarrer l'app ou se déconnecter/reconnecter

#### Option B : Via proxy (Charles, Proxyman)
1. Installer Charles Proxy
2. Configurer throttling : 50 kbps down, 500ms latency
3. Lancer l'app

**Résultats attendus** :
- ✅ Dashboard s'ouvre **instantanément** (< 500ms)
- ✅ Skeletons visibles **plus longtemps** (5-10 secondes)
- ✅ Données arrivent **progressivement** :
  - Appartements d'abord (priorité 0)
  - Puis favoris (priorité 1)
  - Puis réservations (priorité 2)
  - Puis conversations (priorité 3)

---

### 4. Test Cache

**Objectif** : Vérifier que les données en cache ne se rechargent pas

1. **Se connecter et attendre que toutes les données soient chargées**
2. **Fermer complètement l'app** (swipe up sur iOS/Android)
3. **Rouvrir l'app**
4. **Observer** :
   - ✅ Dashboard s'ouvre
   - ✅ **Aucun skeleton** (données déjà en cache)
   - ✅ Appartements affichés **immédiatement**
   - ✅ Dans les logs : `[...PreloadExecutor] Données déjà chargées, skip preload`

---

### 5. Test Logs (Debugging)

**Activer les logs détaillés** :

1. Chercher dans les logs ces messages clés :

```
// Au démarrage de l'app
[main.dart] Démarrage du préchargement pour <nom utilisateur>

// Coordinateur
[DataPreloadCoordinator] Démarrage du préchargement
[DataPreloadCoordinator] Types de données à précharger: [appartements, favorites, reservations, conversations]
[DataPreloadCoordinator] Niveaux de priorité: [0, 1, 2, 3]
[DataPreloadCoordinator] Traitement priorité 0: [appartements]
[DataPreloadCoordinator] Chargement parallèle: [appartements, favorites]

// Executors
[AppartementPreloadExecutor] Démarrage du préchargement (isProprietaire: false)
[AppartementPreloadExecutor] Préchargement terminé

[FavoritePreloadExecutor] Démarrage du préchargement
[FavoritePreloadExecutor] Préchargement terminé

// Etc...
```

2. **Si vous ne voyez PAS ces logs** :
   - ❌ Le préchargement ne démarre pas
   - Vérifier que UserLoaded est bien émis
   - Vérifier le listener dans main.dart

---

## 🐛 Problèmes Courants

### Problème 1 : Je vois toujours le spinner

**Symptômes** :
- Spinner classique au lieu de skeleton
- Écran blanc pendant 2-3 secondes

**Cause** : L'écran charge les données dans `initState()` avant que le préchargement ne soit terminé

**Solution** : Vérifier que l'écran utilise bien `_loadIfNeeded()` et vérifie si les données sont déjà chargées

**Fichiers à vérifier** :
- `lib/screen/client/proprio/home/proprio_home.dart` (ligne 36-50)
- `lib/screen/client/proprio/residences/mes_residences.dart` (ligne 31-45)
- `lib/screen/client/locataire/home/explore.dart` (ligne 35-47)

---

### Problème 2 : Pas de logs de préchargement

**Symptômes** :
- Aucun log `[main.dart] Démarrage du préchargement`
- Aucun log des executors

**Causes possibles** :

1. **Le listener ne se déclenche pas**
   - Vérifier `lib/main.dart` ligne 88-102
   - Vérifier que `UserLoaded` est bien émis

2. **Le délai est trop court**
   - Le délai de 500ms dans main.dart:175 peut être insuffisant
   - Essayer d'augmenter à 1000ms

3. **Le context n'est pas monté**
   - Vérifier la condition `if (!context.mounted)` ligne 176

**Debug** :
```dart
// Dans main.dart, ligne 96, ajouter :
if (state is UserLoaded) {
  print('DEBUG: UserLoaded émis pour ${state.user.fullName}'); // <-- AJOUTER
  WidgetsBinding.instance.addPostFrameCallback((_) {
    print('DEBUG: PostFrameCallback appelé'); // <-- AJOUTER
    _startDataPreloading(context, state.user);
  });
}
```

---

### Problème 3 : Skeleton ne s'affiche pas

**Symptômes** :
- Écran blanc au lieu de skeleton
- Ou spinner au lieu de skeleton

**Cause** : L'état `AppartementInitial` ou `ResidenceInitial` n'est pas géré

**Solution** : Vérifier dans le `BlocBuilder` :

```dart
// BON ✅
if (state is AppartementInitial) {
  return const AppartementListShimmer(itemCount: 5);
}

// MAUVAIS ❌
if (state is AppartementInitial || state is AppartementLoading) {
  return const Center(child: CircularProgress());
}
```

---

### Problème 4 : Rechargement à chaque navigation

**Symptômes** :
- Skeleton réapparaît à chaque fois qu'on revient sur un écran
- Données se rechargent alors qu'elles sont déjà en cache

**Cause** : La méthode `_loadIfNeeded()` ne vérifie pas correctement l'état

**Solution** : Vérifier la logique :

```dart
void _loadAppartementsIfNeeded() {
  final appartBloc = context.read<AppartementBloc>();
  final currentState = appartBloc.state;

  // ✅ Vérifier si données valides
  final hasValidData = currentState is AppartementLoaded &&
                       currentState.appartements.isNotEmpty;

  // ✅ Vérifier si chargement en cours
  final isLoading = currentState is AppartementLoading;

  // ✅ Ne charger QUE si pas de données ET pas en cours
  if (!hasValidData && !isLoading) {
    appartBloc.add(LoadAppartements());
  }
}
```

---

## 📊 Métriques de Performance

### Temps de Navigation Attendus

| Étape | Avant | Après | Amélioration |
|-------|-------|-------|-------------|
| SplashScreen → Dashboard | 2-3s | < 500ms | **80-90% plus rapide** |
| Dashboard → Données visibles | +2s | Skeletons instantanés | **Perception instantanée** |
| Retour sur écran déjà visité | 2-3s | < 100ms | **95% plus rapide** |

### Ordre de Chargement (Priorités)

**Locataire** :
1. Priorité 0 (0-2s) : Appartements
2. Priorité 1 (1-3s) : Favoris
3. Priorité 2 (2-4s) : Réservations
4. Priorité 3 (3-5s) : Conversations

**Propriétaire** :
1. Priorité 0 (0-3s) : Résidences + Appartements (ensemble)
2. Priorité 2 (2-4s) : Réservations
3. Priorité 3 (3-5s) : Conversations

---

## 🔧 Debug Avancé

### Activer les logs détaillés

Dans `lib/util/function.dart`, la fonction `deboger()` affiche déjà les logs. Si vous voulez plus de détails :

```dart
// Dans chaque executor, ajouter des logs
Future<void> execute() async {
  print('DEBUG: Executor démarré');

  // ... logique ...

  print('DEBUG: État actuel: $currentState');
  print('DEBUG: hasValidData: $hasValidData');

  // ... suite ...
}
```

### Simuler des erreurs réseau

Pour tester la gestion d'erreurs :

1. **Mode avion** : Activer le mode avion après connexion
2. **Mock API failure** : Modifier temporairement le service pour retourner une erreur
3. **Timeout** : Réduire le timeout dans les executors (10s → 2s)

---

## ✅ Checklist de Validation

Avant de considérer le système comme fonctionnel :

- [ ] Dashboard s'ouvre en < 500ms après SplashScreen
- [ ] Skeletons animés visibles pendant le chargement
- [ ] Logs de préchargement présents
- [ ] Données chargées progressivement (ordre de priorité)
- [ ] Cache fonctionne (pas de rechargement inutile)
- [ ] Navigation entre onglets fluide
- [ ] Gestion d'erreurs gracieuse (pas de crash)
- [ ] Fonctionne pour locataire ET propriétaire
- [ ] Réseau lent : expérience reste fluide
- [ ] Mode hors ligne : données en cache affichées

---

## 🎓 Comprendre le Système

### Architecture du Préchargement

```
UserLoaded (SplashScreen)
    ↓
main.dart: UserBloc listener
    ↓
PostFrameCallback + 500ms delay
    ↓
PreloadCoordinatorBuilder.build()
    ↓
PreloadStrategyFactory.createStrategy()
    ↓
DataPreloadCoordinator.startPreloading()
    ↓
Par priorité:
    ├─ Priorité 0: Executors en parallèle
    ├─ Priorité 1: Executors en parallèle
    ├─ Priorité 2: Executors en parallèle
    └─ Priorité 3: Executors séquentiels (WebSocket)
```

### États BLoC

| État | Signification | Affichage |
|------|--------------|-----------|
| `Initial` | Pas encore chargé | Skeleton |
| `Loading` | Chargement manuel | Spinner |
| `Loaded` | Données disponibles | Liste |
| `Error` | Erreur survenue | Message d'erreur |

---

## 📝 Rapport de Test

Après vos tests, remplissez ce rapport :

```
=== RAPPORT DE TEST - PRÉCHARGEMENT TRANSPARENT ===

Date: ________________
Testeur: ________________

✅ = Fonctionne | ❌ = Ne fonctionne pas | ⚠️ = Partiel

[ ] Test Locataire - Navigation instantanée
[ ] Test Locataire - Skeletons visibles
[ ] Test Locataire - Cache fonctionne
[ ] Test Propriétaire - Navigation instantanée
[ ] Test Propriétaire - Skeletons visibles
[ ] Test Propriétaire - Cache fonctionne
[ ] Test Réseau Lent - Expérience fluide
[ ] Test Logs - Tous les logs présents
[ ] Test Offline - Données en cache affichées

Temps de navigation moyen (SplashScreen → Dashboard): _____ms

Problèmes rencontrés:
_______________________________________________________
_______________________________________________________
_______________________________________________________

Améliorations suggérées:
_______________________________________________________
_______________________________________________________
_______________________________________________________
```

---

## 🚀 Optimisations Futures

Si tout fonctionne et que vous voulez aller plus loin :

1. **Ajuster les priorités** selon l'usage réel
2. **Précharger les images** des premiers appartements
3. **Analytics** pour mesurer les performances
4. **Prefetch adaptatif** basé sur les habitudes utilisateur
5. **Background sync** périodique des données

---

## 📞 Support

Si vous rencontrez des problèmes persistants :

1. Vérifier tous les logs
2. Lire la section "Problèmes Courants" ci-dessus
3. Vérifier que tous les fichiers ont été modifiés correctement
4. Comparer avec les exemples de code fournis

Fichiers clés à vérifier :
- `lib/main.dart` (ligne 88-190)
- `lib/service/preload/data_preload_coordinator.dart`
- `lib/service/preload/executors/*.dart`
- `lib/screen/client/proprio/home/proprio_home.dart`
- `lib/screen/client/locataire/home/explore.dart`
