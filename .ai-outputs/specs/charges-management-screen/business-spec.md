# 📋 Spécification Métier : Gestion des Charges (CRUD)

> **Feature :** `charges-management-screen`
> **Date :** 2026-05-12
> **Auteur BA :** Claude
> **Statut :** ⏳ En attente de validation utilisateur

---

## 1. Contexte

Le système de charges existe depuis longtemps côté Flutter et serveur :
- Modèle `Charge` complet (13 types × 6 fréquences)
- `ChargeBloc` avec tous les events CRUD
- API REST opérationnelle sur `/api/v1/comptabilite/charges`
- Calculs P&L et Cashflow intègrent déjà les charges

**Mais le propriétaire n'a aucune interface utilisateur** pour gérer ses charges depuis l'app. Il peut uniquement voir les charges agrégées (par type, par mois) dans le P&L de la page Finances — sans pouvoir en ajouter, modifier, supprimer ou marquer comme payée.

Trois actions ciblées dans cette feature :
1. **Création de la feature UI** : écran liste + formulaire CRUD
2. **Nettoyage** : suppression du doublon `charge_local_service.dart` (clone exact de `ChargeRepository`)
3. **Unification du calcul** : alignement de `PnLAggregator` sur `CashflowAggregator` (pivot strict `datePaiement`)

---

## 2. Objectif

Offrir au propriétaire un écran de gestion complet de ses charges, accessible depuis la page Finances. Le proprio peut consulter, filtrer, créer, modifier, supprimer et marquer payée une charge. Les calculs financiers (P&L, Cashflow) sont unifiés sur la règle « la charge compte le mois où elle est effectivement payée » (pivot strict `datePaiement`).

---

## 3. Acteurs

| Acteur | Rôle |
|--------|------|
| **Propriétaire** | Seul acteur — consulte et gère les charges de ses appartements |

---

## 4. Règles Métier

| ID | Règle | Description |
|----|-------|-------------|
| **RM1** | Point d'entrée unique | L'écran est accessible **uniquement** depuis un bouton/CTA dans `ProprioFinancesScreen`. Pas d'onglet dédié, pas de Dashboard card. |
| **RM2** | Filtres serveur | 4 filtres exposés en V1 : **statut** (payées/impayées/en retard), **appartement** (liste venant du `AppartementBloc` serveur), **type de charge** (enum aligné serveur), **période** (mois/année). Les filtres sont combinables. |
| **RM3** | Action « marquer payée » double | Action principale via **swipe** (gauche→droite sur la card) pour rapidité. Bouton « Marquer payée » aussi présent dans la page détail/édition (RM6) pour les utilisateurs qui préfèrent un parcours explicite. |
| **RM4** | Création d'une charge | Formulaire avec champs : appartement (obligatoire), type, libellé optionnel, montant, fréquence, date de début, date d'échéance, est récurrente, notes. Validation : `appartementId` et `montant > 0` obligatoires. |
| **RM5** | Édition d'une charge | Tous les champs sauf `id`/`createdAt`/`appartementNom`/`residenceNom`. Le `datePaiement` se modifie uniquement via l'action « marquer payée » ou « marquer impayée ». |
| **RM6** | Page détail | Tap sur une charge → page détail avec toutes les infos + actions (Modifier, Supprimer, Marquer payée/impayée). |
| **RM7** | Suppression sécurisée | Confirmation modale avant suppression définitive. Pas de corbeille / soft-delete en V1. |
| **RM8** | Unification calcul P&L/Cashflow | La règle « charge tombe dans la période » utilise désormais **uniquement** `datePaiement`. Les charges non payées sont exclues du P&L et du Cashflow (mais restent visibles dans la liste et les alertes). Conséquence : alignement de `PnLAggregator._chargeFallsInPeriod` sur la logique du `CashflowAggregator`. |
| **RM9** | Affichage des alertes | Les charges en retard ou avec échéance proche (≤ 7 jours) sont mises en avant visuellement dans la liste, mais ne polluent plus le P&L tant qu'elles ne sont pas payées (RM8). |
| **RM10** | Cleanup `charge_local_service` | Le fichier `lib/service/comptabilite/charge_local_service.dart` (doublon exact de `ChargeRepository`) est supprimé. Aucun import à patcher (déjà non référencé). |

---

## 5. Cas d'Usage Principal

**Préconditions :**
- Le propriétaire est authentifié
- Au moins un appartement est enregistré (sinon création de charge impossible)

**Scénario :**
1. Le propriétaire ouvre **Finances** depuis le shell propriétaire
2. Il tape sur le bouton **« Gérer mes charges »** (CTA dans Finances)
3. L'écran liste s'ouvre — toutes les charges du proprio, triées par échéance la plus proche
4. Il peut filtrer (statut, appartement, type, période)
5. Il tape sur une charge → page détail
6. Il peut :
   - **Swipe** une charge dans la liste pour la marquer payée rapidement
   - **Taper** « + » pour créer une nouvelle charge → formulaire
   - **Éditer** une charge existante → formulaire pré-rempli
   - **Supprimer** une charge → confirmation modale

**Postconditions :**
- Toutes les modifications sont persistées (API + cache local)
- Les calculs P&L et Cashflow de Finances reflètent les nouvelles données via `LoadCharges` automatique

### 5.1 Sections affichées dans la liste

| Section | Contenu |
|---------|---------|
| **En-tête** | Titre « Mes charges » + bouton « + » (création) |
| **Barre de filtres** | 4 chips/dropdowns : statut, appartement, type, période |
| **Alertes** (si présentes) | Banner ou bloc « X charges en retard » au-dessus de la liste |
| **Liste** | Cards : icône type + libellé + montant + statut badge + date échéance + appartement |
| **Empty state** | « Aucune charge enregistrée. Tapez + pour en ajouter. » |

### 5.2 Sections dans la page détail

| Section | Contenu |
|---------|---------|
| **En-tête** | Icône type + libellé + badge statut |
| **Montant** | Montant en gros + fréquence |
| **Logement** | Card cliquable (appartement lié) |
| **Dates** | Date de début, échéance, date de paiement (si payée) |
| **Notes** | Si présent |
| **Historique** | Créée le, mise à jour le |
| **Action bar (sticky bottom)** | Bouton primaire « Marquer payée » (ou « Marquer impayée »), secondaires « Modifier » / « Supprimer » |

---

## 6. Cas Alternatifs

| Cas | Condition | Comportement |
|-----|-----------|--------------|
| **CA1** | Aucun appartement enregistré | Empty state spécial « Créez d'abord un appartement pour ajouter des charges » avec CTA vers création appartement |
| **CA2** | Création offline (pas de réseau) | Sauvegarde locale avec flag `pendingSync` — sync différée au retour de connexion (hors scope V1 si trop complexe) |
| **CA3** | Charge déjà payée | Bouton swipe affiche « Marquer impayée » ; pas de re-confirmation paiement |
| **CA4** | Filtre vide | Toujours retourner la liste complète si aucun filtre n'est actif |
| **CA5** | Charge récurrente | Affichage de la fréquence dans la card + badge « Récurrent ». Le serveur gère la régénération via CRON ; côté Flutter on ne crée que la charge initiale. |
| **CA6** | Tentative de suppression d'une charge avec datePaiement | Confirmation renforcée « Cette charge a déjà été payée. Confirmer la suppression ? » |

---

## 7. Gestion des Erreurs

| Erreur | Condition | Comportement |
|--------|-----------|--------------|
| **E1** | Échec chargement liste | Banner d'erreur + bouton « Réessayer », fallback cache local |
| **E2** | Échec création/modif (API) | Toast erreur, formulaire non fermé, valeurs préservées |
| **E3** | Échec suppression | Toast erreur, charge restaurée localement |
| **E4** | Validation formulaire échouée | Champs en erreur surlignés, message inline |
| **E5** | Aucun appartement disponible au moment de création | Modal informatif + redirection vers création appart |

---

## 8. Contraintes

- **Performance** : ouverture instantanée avec données du cache, refresh API en arrière-plan
- **Cohérence visuelle** : design system Asfar Premium (réutiliser badges, cards, action bars existants — pattern aligné sur `ReservationDetailScreen` récemment créé)
- **Multilingue** : français uniquement (cohérent avec le reste de l'app)
- **Accessibilité** : libellés explicites sur tous les boutons, pas uniquement icônes
- **Pas de pagination V1** : on suppose ≤ 100 charges actives par proprio

---

## 9. Critères d'Acceptation

- [ ] Bouton « Gérer mes charges » visible dans `ProprioFinancesScreen`
- [ ] La liste s'ouvre, affiche les charges existantes triées par échéance
- [ ] Les 4 filtres (statut, appartement, type, période) fonctionnent et sont combinables
- [ ] Swipe sur une charge la marque payée (ou impayée si déjà payée)
- [ ] Bouton « + » ouvre le formulaire de création
- [ ] Tap sur une charge ouvre la page détail
- [ ] Page détail expose les actions Modifier / Supprimer / Marquer payée
- [ ] Suppression nécessite confirmation modale
- [ ] Le P&L (Finances) ne compte plus que les charges avec `datePaiement` dans la période (RM8)
- [ ] Le Cashflow reste cohérent avec le P&L (même règle)
- [ ] `charge_local_service.dart` supprimé sans casser le projet
- [ ] Aucune régression sur Finances PDF/CSV (qui consomme le P&L)

---

## 10. Hors Périmètre

- **Photo de justificatif** (PDF/image attachée à une charge) → V2
- **Catégories personnalisées** au-delà des 13 types prédéfinis → V2
- **Récurrence custom** (ex. tous les 45 jours) → V2 (les 6 fréquences enum suffisent V1)
- **Export charges seul** (sans P&L global) → V2
- **Historique des modifications** (audit log) → V2
- **Sync différée des charges créées offline** (`pendingSync` flag) → V2 si trop complexe pour V1, sinon dans le scope
- **Notifications push pour les échéances proches** → V2
- **Soft-delete / corbeille** → V2 (suppression définitive seulement)
- **Multi-utilisateurs sur même appartement** → hors scope (modèle propriétaire unique)
