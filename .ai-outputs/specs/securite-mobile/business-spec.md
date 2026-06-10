# 📋 Spécification Métier : Sécurisation de l'application mobile (axe sécurité audit)

> Statut : ✅ validée par l'utilisateur le 2026-06-10
> Référence détaillée : fiches `.ai-outputs/audit/SEC-01` à `SEC-05`

### 1. Contexte

L'audit de juin 2026 (fiches SEC-01 à SEC-05) a révélé que l'application, en l'état,
n'est pas au niveau de sécurité requis pour une mise en production : communications
interceptables, identifiants de session et données personnelles lisibles sur l'appareil,
clé de service cartographique exposée, journaux de débogage bavards, sessions jamais
vérifiées côté app. L'app n'a pas encore d'utilisateurs réels — c'est le bon moment pour
corriger sans contrainte de migration.

### 2. Objectif

Mettre l'application mobile au niveau de sécurité attendu pour une production : aucune
donnée sensible lisible en transit, sur le disque de l'appareil, dans le code source ou
dans les journaux, et des sessions qui expirent proprement.

### 3. Acteurs

- **Tous les utilisateurs** (locataire, proprio, démarcheur) : bénéficiaires — leurs
  données et sessions sont protégées. Aucun changement visible dans leur parcours.
- **L'équipe de développement** : conserve un mode développement fonctionnel
  (serveur local sans TLS, diagnostics utilisables).

### 4. Règles Métier

| ID | Règle | Description |
|---|---|---|
| RM1 | Transport chiffré par défaut | En production, toutes les communications (API et temps réel) sont chiffrées. Le mode non chiffré n'est possible qu'en développement, par choix explicite au moment du build. |
| RM2 | Aucun secret de session lisible | Le jeton de session est conservé dans le stockage sécurisé du téléphone (Keychain/Keystore). Les données mises en cache localement (profil, réservations, contacts…) sont chiffrées. |
| RM3 | Pas de migration | Aucun utilisateur réel : au premier lancement de la nouvelle version, une reconnexion est demandée et le cache local repart de zéro. |
| RM4 | Aucun secret dans le code source | La clé Stadia Maps disparaît du dépôt. Les tuiles de carte passeront par le serveur du projet (proxy). L'ancienne clé est considérée compromise et devra être révoquée (action manuelle). |
| RM5 | Journaux muets en production | En build de production, aucun journal applicatif n'est émis. En développement, les journaux ne contiennent jamais de jeton, email, téléphone ou clé secrète en clair. |
| RM6 | Session expirée = retour au login | Une session expirée est détectée par l'app elle-même (au démarrage et avant les actions), sans attendre un rejet du serveur. L'utilisateur est ramené à l'écran de connexion. |
| RM7 | Déconnexion robuste | La déconnexion fonctionne même sans réseau. Quand le serveur le permettra, elle signalera aussi la révocation de la session côté serveur. |

### 5. Cas d'Usage Principal

**Préconditions :** utilisateur disposant d'un compte, nouvelle version installée.

**Scénario :**

1. L'utilisateur ouvre l'app → sa session précédente n'étant plus reconnue (RM3),
   il se reconnecte.
2. Sa session est désormais stockée de façon sécurisée ; ses données de cache sont
   chiffrées au fil de l'eau.
3. Il navigue normalement : cartes, annonces, réservations — aucun changement perceptible.
4. Si sa session expire, l'app le ramène au login dès la détection (RM6).
5. S'il se déconnecte, tout est nettoyé localement, même hors ligne (RM7).

**Postconditions :** aucune donnée sensible lisible sur l'appareil ni en transit.

### 6. Cas Alternatifs

| Cas | Condition | Comportement |
|---|---|---|
| CA1 | Build de développement sur serveur local | Mode non chiffré activable explicitement au build ; carte utilisable via une clé de dev injectée au build (en attendant le proxy). |
| CA2 | Proxy cartes pas encore disponible côté serveur | L'app garde un fonctionnement carte via la clé injectée au build (jamais dans le code) jusqu'à bascule sur le proxy. |
| CA3 | Déconnexion sans réseau | Nettoyage local complet ; le signalement serveur sera tenté sans bloquer. |

### 7. Gestion des Erreurs

| Erreur | Condition | Comportement |
|---|---|---|
| E1 | Cache local illisible (clé perdue, données corrompues) | Cache purgé silencieusement et reconstruit depuis le serveur ; au pire, reconnexion demandée. Jamais de crash. |
| E2 | Session expirée détectée | Message clair + retour au login. |

### 8. Contraintes

- **Sécurité :** objet même de la feature (fiches SEC-01 à SEC-05 = référence détaillée).
- **Dépendances (prérequis serveur, hors périmètre de ce chantier) :**
  1. exposition de l'API en TLS,
  2. endpoint de révocation de session,
  3. proxy de tuiles cartographiques.
  L'app sera prête à les consommer dès leur disponibilité.
- **Compatibilité dev :** l'expérience de développement (serveur local, logs de debug)
  ne doit pas être dégradée.

### 9. Critères d'Acceptation

- [ ] Un build de production refuse toute communication non chiffrée.
- [ ] Aucun jeton, donnée personnelle ou clé d'API n'est lisible dans les fichiers de
      l'app sur l'appareil, ni dans le code source du dépôt.
- [ ] Pendant un parcours complet (login → navigation → logout), les journaux système
      ne contiennent ni jeton, ni email, ni téléphone ; en build de production, aucun
      journal applicatif.
- [ ] Avec une session expirée, l'app ramène au login sans appel métier préalable.
- [ ] La déconnexion en mode avion fonctionne et nettoie tout.
- [ ] La carte fonctionne (clé injectée au build en attendant le proxy serveur).

### 10. Hors Périmètre

- Travaux serveur Spring Boot : TLS, endpoint de révocation, proxy de tuiles
  (listés comme prérequis).
- Révocation effective de l'ancienne clé Stadia (action manuelle sur le dashboard).
- Certificate pinning et refresh token automatique (phase 2 — notés pour plus tard).
- Les axes praticité (PRA-*) et fluidité (PERF-*) de l'audit.

### Décisions de cadrage (réponses utilisateur, 2026-06-10)

- Périmètre : **mobile uniquement**, backend = prérequis identifiés.
- Utilisateurs réels : **aucun** → pas de migration, reconnexion forcée acceptée.
- Clé Stadia : cible = **proxy backend** ; transition via clé injectée au build.
- Livraison : **tout en une fois** (les 5 fiches dans un seul chantier).
