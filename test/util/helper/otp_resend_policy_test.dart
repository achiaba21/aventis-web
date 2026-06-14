import 'package:flutter_test/flutter_test.dart';
import 'package:asfar/util/helper/otp_resend_policy.dart';

void main() {
  group('OtpResendPolicy — délais progressifs', () {
    test('séquence 60 → 60 → 120 → 180', () {
      expect(OtpResendPolicy.delayFor(0), 60);
      expect(OtpResendPolicy.delayFor(1), 60);
      expect(OtpResendPolicy.delayFor(2), 120);
      expect(OtpResendPolicy.delayFor(3), 180);
    });

    test('premier palier ≥ 60s (rate-limit backend : 60s min entre 2 envois)', () {
      expect(OtpResendPolicy.delayFor(0), greaterThanOrEqualTo(60));
    });

    test('plafonné à 180 au-delà du dernier palier', () {
      expect(OtpResendPolicy.delayFor(4), 180);
      expect(OtpResendPolicy.delayFor(99), 180);
    });

    test('compteur négatif ramené au premier palier', () {
      expect(OtpResendPolicy.delayFor(-1), 60);
    });
  });
}
