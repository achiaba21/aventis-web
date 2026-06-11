import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_event.dart';
import 'package:asfar/bloc/user_bloc/user_state.dart';
import 'package:asfar/service/model/Auth/authentication_service.dart';
import 'package:asfar/util/custom_exception.dart';

class _MockAuthenticationService extends Mock implements AuthenticationService {}

void main() {
  const tel = '+225 07 00 00 00 00';
  const code = '1234';

  group('UserBloc — VerifyOtp', () {
    test('vérification réussie → UserLoading puis OtpVerified(telephone)',
        () async {
      final auth = _MockAuthenticationService();
      when(() => auth.verifyOtp(tel, code)).thenAnswer((_) async {});
      final bloc = UserBloc(authentication: auth);

      final states = <UserState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(VerifyOtp(tel, code));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(states, hasLength(2));
      expect(states[0], isA<UserLoading>());
      expect(states[1], isA<OtpVerified>());
      expect((states[1] as OtpVerified).telephone, tel);
      verify(() => auth.verifyOtp(tel, code)).called(1);

      await sub.cancel();
      await bloc.close();
    });

    test('code refusé par le serveur → UserError, pas de OtpVerified',
        () async {
      final auth = _MockAuthenticationService();
      when(() => auth.verifyOtp(tel, code))
          .thenThrow(CustomException('Code invalide'));
      final bloc = UserBloc(authentication: auth);

      final states = <UserState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(VerifyOtp(tel, code));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(states, hasLength(2));
      expect(states[0], isA<UserLoading>());
      expect(states[1], isA<UserError>());
      expect(states.whereType<OtpVerified>(), isEmpty);

      await sub.cancel();
      await bloc.close();
    });
  });
}
