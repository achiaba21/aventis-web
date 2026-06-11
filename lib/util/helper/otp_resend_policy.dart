/// Délais progressifs entre les renvois de code OTP.
///
/// Chaque demande de renvoi allonge le délai d'attente avant la suivante :
/// 15s → 20s → 30s → 60s, puis plafonné à 60s.
class OtpResendPolicy {
  OtpResendPolicy._();

  /// Délais successifs en secondes, indexés par nombre de renvois déjà demandés.
  static const List<int> delays = [15, 20, 30, 60];

  /// Délai de cooldown (secondes) à appliquer après le [resendCount]-ième
  /// envoi (0 = envoi initial). Plafonné au dernier palier.
  static int delayFor(int resendCount) =>
      delays[resendCount.clamp(0, delays.length - 1)];
}
