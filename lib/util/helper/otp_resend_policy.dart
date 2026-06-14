/// Délais progressifs entre les renvois de code OTP.
///
/// Chaque demande de renvoi allonge le délai d'attente avant la suivante :
/// 60s → 60s → 120s → 180s, puis plafonné à 180s.
///
/// Le premier palier est ≥ 60s pour respecter le rate-limit backend
/// (`OtpService` : 60s minimum entre deux envois, 5 envois/heure max — fiche
/// sécurité 07). Des paliers plus courts faisaient rejeter les renvois côté
/// serveur (« Veuillez patienter avant de redemander un code »).
class OtpResendPolicy {
  OtpResendPolicy._();

  /// Délais successifs en secondes, indexés par nombre de renvois déjà demandés.
  static const List<int> delays = [60, 60, 120, 180];

  /// Délai de cooldown (secondes) à appliquer après le [resendCount]-ième
  /// envoi (0 = envoi initial). Plafonné au dernier palier.
  static int delayFor(int resendCount) =>
      delays[resendCount.clamp(0, delays.length - 1)];
}
