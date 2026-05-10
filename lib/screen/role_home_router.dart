import 'package:flutter/material.dart';
import 'package:asfar/model/user/user.dart';
import 'package:asfar/screen/client/demarcheur/demarcheur_shell.dart';
import 'package:asfar/screen/client/locataire/locataire_shell.dart';
import 'package:asfar/screen/client/proprio/proprio_shell.dart';

/// Routeur de Shell selon la **vue active** de l'utilisateur connecté.
///
/// V8.5 : la vue active est différente du **type de compte** (`user.type`) —
/// un proprio/démarcheur peut basculer en mode Locataire pour séjourner
/// ailleurs sans changer son type. Si [viewId] est `null`, on retombe sur
/// `user.type` (comportement par défaut au premier login).
///
/// Locataire (Vague 5), Démarcheur (Vague 6) et Propriétaire (Vague 7) sont
/// tous reconstruits.
class RoleHomeRouter {
  RoleHomeRouter._();

  static Widget shellFor(User user, {String? viewId}) {
    final activeView = (viewId ?? user.type ?? '').toLowerCase();
    final firstName = user.prenom?.trim();
    switch (activeView) {
      case 'locataire':
        return LocataireShell(firstName: firstName);
      case 'demarcheur':
        return DemarcheurShell(firstName: firstName);
      case 'proprietaire':
        return ProprioShell(firstName: firstName);
      default:
        return LocataireShell(firstName: firstName);
    }
  }

  /// Liste des vues accessibles à un utilisateur selon son `user.type`.
  ///
  /// V8.5 : un locataire pur ne voit que LocataireShell. Un proprio voit
  /// LocataireShell + ProprioShell (pour pouvoir séjourner ailleurs). Un
  /// démarcheur voit LocataireShell + DemarcheurShell.
  static List<String> availableViewsFor(User user) {
    final type = (user.type ?? '').toLowerCase();
    switch (type) {
      case 'proprietaire':
        return const ['locataire', 'proprietaire'];
      case 'demarcheur':
        return const ['locataire', 'demarcheur'];
      case 'locataire':
      default:
        return const ['locataire'];
    }
  }
}
