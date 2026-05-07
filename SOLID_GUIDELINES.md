# 🎯 SOLID Guidelines - Asfar Flutter App

## 📌 Contexte
Ce document définit les principes SOLID à respecter pour **tout nouveau code** ajouté au projet Asfar.
⚠️ **Important** : Nous ne refactorisons PAS le code existant, mais tout nouveau développement doit suivre ces principes.

---

## 🔐 Principe Fondamental : Séparation des Rôles

### Problème Actuel
L'application gère 2 rôles utilisateurs distincts :
- **Locataire** (Tenant) : Recherche, réservation, favoris
- **Propriétaire** (Landlord) : Gestion de patrimoine, validation de réservations

Certains BLoCs actuels mélangent ces 2 responsabilités, ce qui crée des risques :
- ❌ Modification pour locataire → Casse la logique propriétaire
- ❌ Modification pour propriétaire → Casse la logique locataire

---

## ✅ Règles SOLID pour le Nouveau Code

### 1️⃣ Single Responsibility Principle (SRP)

**Règle :** Un BLoC = Un Rôle = Une Responsabilité

#### ❌ À ÉVITER (comme le code existant)
```dart
// UN SEUL BLoC pour 2 rôles différents
class ReservationBloc {
  on<LoadUserReservations>(...) // LOCATAIRE
  on<LoadProprietaireReservations>(...) // PROPRIÉTAIRE
  on<ApproveBooking>(...) // PROPRIÉTAIRE SEULEMENT
  on<CreateBooking>(...) // LOCATAIRE SEULEMENT
}
```

#### ✅ À FAIRE pour nouveau code
```dart
// SÉPARATION PAR RÔLE

// Pour LOCATAIRE uniquement
class TenantBookingBloc extends Bloc<TenantBookingEvent, TenantBookingState> {
  on<LoadMyBookings>(...)
  on<CreateBooking>(...)
  on<CancelMyBooking>(...)
  on<AddReview>(...)
}

// Pour PROPRIÉTAIRE uniquement
class LandlordBookingBloc extends Bloc<LandlordBookingEvent, LandlordBookingState> {
  on<LoadPropertyBookings>(...)
  on<ApproveBooking>(...)
  on<RejectBooking>(...)
  on<ViewBookingDetails>(...)
}
```

**Bénéfice :** Modification locataire → **ZÉRO risque** pour proprio

---

### 2️⃣ Open/Closed Principle (OCP)

**Règle :** Extensible sans modifier le code existant

#### ✅ Structure de dossiers recommandée
```
lib/bloc/
  ├── tenant/              # Tout ce qui concerne LOCATAIRE
  │   ├── booking/
  │   │   ├── tenant_booking_bloc.dart
  │   │   ├── tenant_booking_event.dart
  │   │   └── tenant_booking_state.dart
  │   ├── search/
  │   └── favorites/
  │
  ├── landlord/            # Tout ce qui concerne PROPRIÉTAIRE
  │   ├── booking/
  │   │   ├── landlord_booking_bloc.dart
  │   │   ├── landlord_booking_event.dart
  │   │   └── landlord_booking_state.dart
  │   ├── property/
  │   └── analytics/
  │
  └── shared/              # Fonctionnalités communes (notifications, chat)
      ├── notification_bloc.dart
      └── conversation_bloc.dart
```

**Bénéfice :** Ajout d'un 3e rôle (Admin) → Créer `lib/bloc/admin/` sans toucher aux autres

---

### 3️⃣ Liskov Substitution Principle (LSP)

**Règle :** Utiliser des interfaces/contrats pour les services

#### ✅ Exemple avec Contrats
```dart
// Définir des contrats clairs
abstract class TenantBookingContract {
  Future<List<Reservation>> getMyBookings();
  Future<Reservation> createBooking(ReservationReq request);
  Future<void> cancelBooking(int bookingId);
}

abstract class LandlordBookingContract {
  Future<List<Reservation>> getPropertyBookings();
  Future<void> approveBooking(int bookingId);
  Future<void> rejectBooking(int bookingId, String reason);
}

// Service implémente LES DEUX contrats
class ReservationService
    implements TenantBookingContract, LandlordBookingContract {
  // Implémentation...
}
```

**Bénéfice :** Tests unitaires faciles avec mocks par rôle

---

### 4️⃣ Interface Segregation Principle (ISP)

**Règle :** Ne pas exposer des méthodes inutiles à un rôle

#### ❌ À ÉVITER
```dart
// Le locataire voit des méthodes qu'il ne peut jamais utiliser
class BookingService {
  Future<void> approveBooking(int id); // ⚠️ Locataire ne peut pas utiliser
  Future<void> rejectBooking(int id);  // ⚠️ Locataire ne peut pas utiliser
  Future<void> createBooking(...);     // ✅ Locataire peut utiliser
}
```

#### ✅ À FAIRE
```dart
// Interfaces ségrégées
abstract class TenantBookingContract {
  Future<void> createBooking(...);
  Future<void> cancelMyBooking(int id);
  // Seulement ce dont le locataire a besoin
}

abstract class LandlordBookingContract {
  Future<void> approveBooking(int id);
  Future<void> rejectBooking(int id);
  // Seulement ce dont le proprio a besoin
}
```

---

### 5️⃣ Dependency Inversion Principle (DIP)

**Règle :** Dépendre d'abstractions, pas d'implémentations concrètes

#### ✅ Injection de dépendances
```dart
class TenantBookingBloc {
  final TenantBookingContract _bookingService; // Interface, pas classe concrète

  TenantBookingBloc({
    required TenantBookingContract bookingService,
  }) : _bookingService = bookingService;

  // Utilisation
  on<CreateBooking>((event, emit) async {
    final booking = await _bookingService.createBooking(event.request);
    emit(BookingCreated(booking));
  });
}
```

**Bénéfice :** Tests avec mocks, changement d'implémentation sans modifier le BLoC

---

## 🚀 Checklist pour Nouveau Code

Avant de créer un nouveau BLoC/Service, vérifiez :

### ✅ Questions à se poser

1. **Ce BLoC sert-il UN SEUL rôle ?**
   - [ ] Oui → Bon
   - [ ] Non → Séparer en 2 BLoCs (tenant/ et landlord/)

2. **Ce BLoC est-il dans le bon dossier ?**
   - [ ] `lib/bloc/tenant/` si SEULEMENT pour locataire
   - [ ] `lib/bloc/landlord/` si SEULEMENT pour propriétaire
   - [ ] `lib/bloc/shared/` si pour LES DEUX rôles

3. **Le service utilise-t-il des interfaces ?**
   - [ ] Oui → Définir un contrat (abstract class)
   - [ ] Non → À améliorer

4. **Les événements/états sont-ils spécifiques au rôle ?**
   - [ ] Oui → Nommer clairement (ex: `TenantBookingEvent`)
   - [ ] Non → Risque de confusion

5. **Est-ce que je teste SEULEMENT ce rôle ?**
   - [ ] Oui → Tests isolés et simples
   - [ ] Non → Tests complexes avec 2 contextes

---

## 📝 Exemples de Nommage

### BLoCs
```dart
// ✅ BON : Clair et spécifique
TenantBookingBloc
LandlordBookingBloc
ApartmentSearchBloc (locataire)
PropertyManagementBloc (propriétaire)

// ❌ MAUVAIS : Ambiguë
BookingBloc (pour qui ?)
ApartmentBloc (locataire ou proprio ?)
```

### Events
```dart
// ✅ BON
class LoadMyBookings extends TenantBookingEvent {}
class LoadPropertyBookings extends LandlordBookingEvent {}

// ❌ MAUVAIS
class LoadBookings {} // Pour qui ?
```

### States
```dart
// ✅ BON
class TenantBookingsLoaded extends TenantBookingState {
  final List<Reservation> myBookings;
}

class LandlordBookingsLoaded extends LandlordBookingState {
  final List<Reservation> propertyBookings;
  final RevenueStats stats; // Spécifique proprio
}

// ❌ MAUVAIS
class BookingsLoaded { // Quel contexte ?
  final List<Reservation> bookings;
}
```

---

## 🔧 Cas d'Usage : Ajouter une Nouvelle Feature

### Scénario : Feature "Notes privées sur réservations" (Propriétaire uniquement)

#### ✅ Approche SOLID

1. **Créer un nouveau BLoC séparé**
```dart
// lib/bloc/landlord/booking_notes/landlord_booking_notes_bloc.dart
class LandlordBookingNotesBloc extends Bloc<...> {
  on<AddNoteToBooking>(...);
  on<UpdateNote>(...);
  on<DeleteNote>(...);
}
```

2. **Définir un contrat**
```dart
// lib/service/contracts/booking_notes_contract.dart
abstract class BookingNotesContract {
  Future<Note> addNote(int bookingId, String content);
  Future<List<Note>> getNotes(int bookingId);
  Future<void> deleteNote(int noteId);
}
```

3. **Provider conditionnel**
```dart
// Dans main.dart ou navigation proprietaire
if (user is Proprietaire) {
  BlocProvider(
    create: (_) => LandlordBookingNotesBloc(
      notesService: BookingNotesService(),
    ),
  );
}
```

**Résultat :**
- ✅ Code locataire **NON TOUCHÉ**
- ✅ Tests isolés pour notes proprio
- ✅ Facile à désactiver/activer par feature flag

---

## 🎯 Impact sur les Tests

### Avant (Code mixte)
```dart
test('booking bloc', () {
  // Tester locataire ET proprio dans le même test
  // Complexe, long, fragile
});
```

### Après (Code séparé)
```dart
test('tenant booking bloc - create booking', () {
  // Tester SEULEMENT la création côté locataire
  // Simple, rapide, robuste
});

test('landlord booking bloc - approve booking', () {
  // Tester SEULEMENT l'approbation côté proprio
  // Indépendant du test locataire
});
```

---

## 📚 Ressources

- [SOLID Principles (Wikipedia)](https://en.wikipedia.org/wiki/SOLID)
- [BLoC Pattern Best Practices](https://bloclibrary.dev/#/architecture)
- [Flutter Clean Architecture](https://resocoder.com/flutter-clean-architecture-tdd/)

---

## ✅ Résumé des Règles d'Or

1. **Un BLoC = Un Rôle** → Toujours se demander : "C'est pour locataire ou proprio ?"
2. **Dossiers séparés** → `tenant/`, `landlord/`, `shared/`
3. **Nommage explicite** → `TenantXxxBloc`, `LandlordXxxBloc`
4. **Contrats (interfaces)** → Pour chaque service métier
5. **Tests isolés** → Un test par rôle, jamais mixte
6. **Penser aux 2 rôles** → Chaque modif doit être évaluée pour locataire ET proprio

---

**Date de création :** 2025-01-20
**Dernière mise à jour :** 2025-01-20
**Maintenu par :** Équipe dev Asfar
