# 📋 Spécification Métier : Page Détail Réservation

> **Feature :** `reservation-detail-screen`
> **Date :** 2026-05-12
> **Auteur BA :** Claude
> **Statut :** ⏳ En attente de validation utilisateur

---

## 1. Contexte

Aujourd'hui, les réservations sont visibles dans plusieurs surfaces de l'application (trips locataire, dashboard et liste proprio, referrals démarcheur, cards chat) mais aucune **page de détail consolidée** n'existe. L'utilisateur clique sur une réservation et ne peut consulter que les informations limitées exposées par la card d'origine. Les actions (annuler, payer, confirmer, refuser, scanner QR…) sont dispersées dans différents écrans.

Le besoin est de **centraliser** toutes les informations et actions liées à une réservation dans **une seule page**, accessible depuis tous les points d'entrée existants.

---

## 2. Objectif

Offrir à chaque acteur (locataire, propriétaire, démarcheur) **une page unique** présentant **toutes les informations** d'une réservation et **toutes les actions disponibles** selon son rôle et le statut courant de la réservation.

---

## 3. Acteurs

| Acteur | Rôle |
|--------|------|
| **Locataire** | Voit ses propres réservations, peut annuler / payer / présenter son QR / contacter le proprio |
| **Propriétaire** | Voit les réservations sur ses biens, peut confirmer / refuser / scanner le QR / éditer une réservation manuelle / contacter le client |
| **Démarcheur** | Voit les réservations qu'il a apportées, consulte sa commission, contacte le proprio |

---

## 4. Règles Métier

| ID | Règle | Description |
|----|-------|-------------|
| **RM1** | Page unique multi-rôle | Une seule page de détail, dont le contenu et les actions s'adaptent au rôle de l'utilisateur courant et au statut de la réservation. |
| **RM2** | Affichage QR locataire | Le QR code de la réservation est visible côté locataire **à partir du statut `payée`** et reste visible jusqu'au statut `terminée`. |
| **RM3** | Démarcheur visible côté proprio | Si la réservation est de type `ReservationDemarcheur`, le proprio voit **le nom du démarcheur source et le montant de la commission** convenue. |
| **RM4** | Édition réservation manuelle | Le proprio peut éditer une `ReservationManuelle` (dates et infos client externe) **uniquement si le statut est `enAttente` ou `confirmée`**. Dès que la réservation passe à `payée` ou `finalisée`, l'édition est verrouillée. |
| **RM5** | Scanner QR direct (proprio) | Quand la réservation est au statut `payée`, le proprio dispose d'un raccourci direct vers le scanner QR depuis la page de détail (pour finaliser le check-in). |
| **RM6** | Historique des événements | Une timeline affiche les étapes franchies par la réservation (création, confirmation, paiement, finalisation, refus, annulation) avec les dates connues et les motifs disponibles (refus, annulation). |
| **RM7** | Contact contextuel | Un bouton "Contacter" propose **chat + appel** vers la contrepartie pertinente selon le rôle de l'utilisateur. |
| **RM8** | Actions selon rôle × statut | Les actions exposées dépendent strictement de la matrice définie au §5. Aucune action n'est affichée si elle est inapplicable. |
| **RM9** | Confidentialité client externe | Pour une `ReservationManuelle`, seul le proprio voit les coordonnées du client externe. Le démarcheur ne s'applique pas à ce type. |
| **RM10** | Accès par référence | La page doit être atteignable via la référence unique de la réservation (ex. `ASF-7K2N9`) pour supporter les deep-links (notifications push, cards chat). |
| **RM11** | Manuelle confirmée ≡ encaissée | Une `ReservationManuelle` est créée par le proprio pour un client externe (paiement géré hors plateforme). Dès le statut `confirmée`, on considère que **le proprio a reçu l'argent** : (a) la réservation compte dans le revenu encaissé (`RevenueHero`, P&L) ; (b) elle n'apparaît plus dans le pipeline ; (c) l'édition est verrouillée (cohérence avec RM4) ; (d) la timeline affiche l'étape `Payée` implicite après `Confirmée`. L'annulation reste possible avec remboursement géré hors-app. |

---

## 5. Cas d'Usage Principal

**Préconditions :**
- L'utilisateur est authentifié
- La réservation existe et l'utilisateur est légitime pour la consulter (locataire propriétaire de la résa / proprio propriétaire du bien / démarcheur source)

**Scénario :**
1. L'utilisateur tape sur une réservation depuis l'un des points d'entrée (trips, liste proprio, referrals, card chat, notification push)
2. La page de détail s'ouvre et affiche les informations adaptées au rôle
3. L'utilisateur consulte les informations (identité, dates, montants, statut, historique)
4. L'utilisateur effectue une action autorisée (voir §5.2 matrice)
5. L'action déclenche un changement de statut → la page se rafraîchit automatiquement
6. L'utilisateur peut revenir à l'écran précédent à tout moment

**Postconditions :**
- L'utilisateur a la vision complète de la réservation
- Les actions effectuées sont persistées et reflétées dans toutes les autres surfaces (trips, dashboard, etc.)

### 5.1 Sections affichées (toutes vues)

| Section | Contenu | Visibilité |
|---------|---------|------------|
| **En-tête** | Référence, statut visuel (badge), type (plateforme / manuelle / démarcheur) | Toujours |
| **Appartement** | Nom, adresse, photo, accès rapide à la fiche bien | Toujours |
| **Dates & durée** | Date début, date fin, nombre de nuits | Toujours |
| **Montants** | Prix total, frais Asfar (si applicable), avance versée, reste à payer | Toujours (formats adaptés au rôle) |
| **Client / Locataire** | Nom, contact (selon RM9) | Proprio + démarcheur (limité) |
| **Propriétaire** | Nom, contact | Locataire + démarcheur |
| **Démarcheur** | Nom + commission (RM3) | Proprio uniquement, si type = démarcheur |
| **QR code** | Image du QR (RM2) | Locataire uniquement, statut ≥ payée |
| **Historique** | Timeline des événements (RM6) | Toujours |
| **Actions** | Boutons selon RM8 | Selon matrice §5.2 |

### 5.2 Matrice Actions par Rôle × Statut

| Statut → | **enAttente** | **confirmée** | **payée** | **finalisée** | **terminée** | **refusée** | **annulée** |
|---|---|---|---|---|---|---|---|
| **Locataire** | Annuler · Contacter | Payer · Annuler · Contacter | Voir QR · Contacter | Voir QR · Contacter | Contacter | Contacter | Contacter |
| **Proprio** (plateforme) | Confirmer · Refuser · Contacter | Contacter | Scanner QR · Contacter | Contacter | Contacter | Contacter | Contacter |
| **Proprio** (manuelle) | Éditer · Annuler · Contacter | Éditer · Annuler · Contacter | Scanner QR · Contacter | Contacter | Contacter | — | — |
| **Proprio** (démarcheur) | Confirmer · Refuser · Contacter | Contacter | Scanner QR · Contacter | Contacter | Contacter | Contacter | Contacter |
| **Démarcheur** | Contacter | Contacter | Contacter | Contacter | Contacter | Contacter | Contacter |

> Note : « Contacter » pour le démarcheur cible le proprio ; pour le locataire et le proprio, cible la contrepartie naturelle.

---

## 6. Cas Alternatifs

| Cas | Condition | Comportement |
|-----|-----------|--------------|
| **CA1** | Ouverture avec une référence inexistante (ex. deep-link périmé) | Afficher un état d'erreur clair « Réservation introuvable » + bouton retour |
| **CA2** | Utilisateur non légitime tente de consulter la réservation | Refuser l'accès, afficher un message d'erreur « Réservation non accessible » |
| **CA3** | Réservation manuelle, pas de locataire plateforme | Afficher les `clientExterneNom/Telephone/Email` à la place du locataire |
| **CA4** | Réservation démarcheur consultée par le locataire | Le locataire ne voit pas qu'un démarcheur est impliqué (transparence) |
| **CA5** | Tentative d'édition d'une résa manuelle au statut `payée` | Bouton Éditer désactivé / masqué (RM4) |
| **CA6** | Page consultée hors ligne | Afficher les données du cache local + bandeau « Mode hors ligne, certaines actions sont indisponibles » |
| **CA7** | Action en cours d'exécution (paiement, confirmation…) | Désactiver les autres actions et afficher un indicateur de chargement |
| **CA8** | Réservation passée à `terminée` automatiquement par le backend | La page se rafraîchit et masque les actions devenues obsolètes (paiement, QR…) |

---

## 7. Gestion des Erreurs

| Erreur | Condition | Comportement |
|--------|-----------|--------------|
| **E1** | Échec API au chargement | Afficher message d'erreur + bouton « Réessayer », conserver les données du cache si dispo |
| **E2** | Échec d'une action (annuler, payer, confirmer…) | Toast / snackbar explicite, statut inchangé, action ré-essayable |
| **E3** | Échec édition résa manuelle | Champ en erreur surligné, message inline |
| **E4** | QR code introuvable (locataire, statut payée) | Bouton « Régénérer mon code » + message clair |
| **E5** | Scanner QR échoue (proprio) | Message d'erreur, retour à la page de détail |

---

## 8. Contraintes

- **Performance :** ouverture instantanée avec données déjà connues (cache), rafraîchissement silencieux en arrière-plan
- **Cohérence visuelle :** respect strict du design system existant (cards, badges statut, couleurs, typographie)
- **Accessibilité :** toutes les actions critiques accessibles avec libellés clairs (pas uniquement des icônes)
- **Multi-rôle :** une seule page, adaptation par rôle invisible pour l'utilisateur final
- **Deep-link :** la page doit pouvoir être ouverte par une référence (`ASF-XXXXX`) seule, sans avoir l'objet `Reservation` en mémoire
- **État de chargement :** afficher un skeleton plutôt qu'un spinner pendant le chargement initial (cohérence projet)

---

## 9. Critères d'Acceptation

- [ ] La page s'ouvre depuis les 5 points d'entrée existants (trips, liste proprio, dashboard, referrals, card chat)
- [ ] La page s'ouvre depuis une notification push avec la référence en deep-link
- [ ] L'identité, les dates, les montants et le statut sont visibles dans tous les rôles
- [ ] Le locataire voit le QR code uniquement à partir du statut `payée` (RM2)
- [ ] Le proprio voit le nom du démarcheur source et la commission si type = démarcheur (RM3)
- [ ] Le proprio peut éditer une résa manuelle uniquement avant `payée` (RM4)
- [ ] Le proprio peut lancer le scanner QR depuis la page si statut = `payée` (RM5)
- [ ] La timeline d'historique affiche correctement les transitions connues (RM6)
- [ ] Le bouton « Contacter » propose chat + appel selon la contrepartie pertinente (RM7)
- [ ] Les actions affichées respectent strictement la matrice §5.2 (RM8)
- [ ] La page gère correctement les 8 cas alternatifs (CA1 à CA8)
- [ ] Les 5 erreurs (E1 à E5) sont gérées avec messages clairs
- [ ] Aucune flash UI au rafraîchissement (données du cache conservées)

---

## 10. Hors Périmètre

- **Partage externe de la réservation** (envoi par email, SMS, WhatsApp d'un récapitulatif PDF) → V2
- **Notation / avis** post-séjour → feature séparée
- **Réclamation / litige** → feature séparée
- **Modification de la durée par le locataire** (extension de séjour) → V2
- **Multi-langue** des libellés → conforme au reste de l'app (français)
- **Audit log backend** détaillé (qui a fait quoi, quand) au-delà des transitions de statut → demande backend à part
- **Édition d'une réservation plateforme ou démarcheur** par le proprio → uniquement les manuelles (RM4)
- **Annulation par le démarcheur** → uniquement par le locataire ou le proprio
