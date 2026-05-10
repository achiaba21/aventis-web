import 'package:flutter/material.dart';
import 'package:asfar/model/user/user.dart';
import 'package:asfar/screen/client/demarcheur/demarcheur_shell.dart';
import 'package:asfar/screen/client/locataire/locataire_shell.dart';
import 'package:asfar/screen/client/proprio/proprio_shell.dart';

/// Routeur de home selon le rôle de l'utilisateur connecté.
///
/// Retourne le `Shell` approprié — Locataire (Vague 5), Démarcheur (Vague 6)
/// et Propriétaire (Vague 7) sont tous reconstruits. Le switch de rôle est
/// désormais tri-directionnel via le `ProfileRoleSwitcher` du
/// `ClientProfileScreen` partagé.
class RoleHomeRouter {
  RoleHomeRouter._();

  static Widget shellFor(User user) {
    final role = (user.type ?? '').toLowerCase();
    final firstName = user.prenom?.trim();
    switch (role) {
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
}
