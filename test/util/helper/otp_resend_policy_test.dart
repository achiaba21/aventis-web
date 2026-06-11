import 'package:flutter_test/flutter_test.dart';
import 'package:asfar/util/helper/otp_resend_policy.dart';

void main() {
  group('OtpResendPolicy — délais progressifs', () {
    test('séquence 15 → 20 → 30 → 60', () {
      expect(OtpResendPolicy.delayFor(0), 15);
      expect(OtpResendPolicy.delayFor(1), 20);
      expect(OtpResendPolicy.delayFor(2), 30);
      expect(OtpResendPolicy.delayFor(3), 60);
    });

    test('plafonné à 60 au-delà du dernier palier', () {
      expect(OtpResendPolicy.delayFor(4), 60);
      expect(OtpResendPolicy.delayFor(99), 60);
    });

    test('compteur négatif ramené au premier palier', () {
      expect(OtpResendPolicy.delayFor(-1), 15);
    });
  });
}
