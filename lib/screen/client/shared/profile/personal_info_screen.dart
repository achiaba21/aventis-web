import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_state.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/item/field_row.dart';

/// Écran « Informations personnelles » — affichage read-only des données
/// du `UserBloc`.
///
/// V9.5 : édition write nécessite un endpoint backend `UpdateUserProfile`
/// + event UserBloc dédié. En attendant, chaque champ ouvre un SnackBar
/// "Modification disponible prochainement".
class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

  static const _months = [
    'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
    'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
  ];

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _typeLabel(String? type) {
    switch ((type ?? '').toLowerCase()) {
      case 'proprietaire':
        return 'Propriétaire';
      case 'demarcheur':
        return 'Démarcheur';
      case 'locataire':
        return 'Locataire';
      default:
        return 'Membre';
    }
  }

  String _memberSinceText(DateTime? createdAt) {
    if (createdAt == null) return 'Date inconnue';
    return 'Membre depuis ${_months[createdAt.month - 1]} ${createdAt.year}';
  }

  String _displayValue(String? value, {String fallback = 'Non renseigné'}) {
    final v = value?.trim();
    if (v == null || v.isEmpty) return fallback;
    return v;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DynamicAppBar(
        title: 'Informations personnelles',
        leading: IconBoutton(
          icon: Icons.arrow_back_ios_new,
          onPressed: () => back(context),
        ),
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            final user = state.user;
            if (user == null) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'Utilisateur non connecté.',
                    style: AppTextStyles.small,
                  ),
                ),
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.bgElev1,
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      border: Border.all(color: AppColors.line, width: 1),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        FieldRow(
                          eyebrow: 'NOM',
                          value: _displayValue(user.nom),
                          trailingIcon: null,
                        ),
                        FieldRow(
                          eyebrow: 'PRÉNOM',
                          value: _displayValue(user.prenom),
                          trailingIcon: null,
                        ),
                        FieldRow(
                          eyebrow: 'TÉLÉPHONE',
                          value: _displayValue(user.telephone),
                          onTap: () => _toast(context,
                              'Le téléphone sert d\'identifiant — contactez le support pour le modifier'),
                        ),
                        FieldRow(
                          eyebrow: 'EMAIL',
                          value: _displayValue(user.email),
                          trailingIcon: null,
                        ),
                        FieldRow(
                          eyebrow: 'TYPE DE COMPTE',
                          value: _typeLabel(user.type),
                          onTap: () => _toast(context,
                              'Le type de compte ne peut pas être modifié'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      _memberSinceText(user.createdAt),
                      style: AppTextStyles.small.copyWith(fontSize: 12),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
