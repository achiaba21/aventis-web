import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_event.dart';
import 'package:asfar/bloc/user_bloc/user_state.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/dto/user_req.dart';
import 'package:asfar/model/user/demarcheur.dart';
import 'package:asfar/model/user/locataire.dart';
import 'package:asfar/model/user/proprietaire.dart';
import 'package:asfar/screen/client/demarcheur/demarcheur_navigation.dart';
import 'package:asfar/screen/client/locataire/home/home.dart';
import 'package:asfar/screen/client/proprio/proprio_navigation.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/button/texte_button.dart';
import 'package:asfar/widget/input/otp_input.dart';
import 'package:asfar/widget/logo.dart';
import 'package:asfar/widget/text/text_seed.dart';

class OtpVerificationScreen extends StatefulWidget {
  final UserReq userReq;

  const OtpVerificationScreen({super.key, required this.userReq});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<int> _resendDelays = [15, 20, 30, 60];

  int _currentDelayIndex = 0;
  bool _inputBlocked = false;
  bool _waitingForVerification = false;
  String? _errorMessage;

  Timer? _timer;
  int _secondsLeft = 0;
  int _otpKey = 0;

  @override
  void initState() {
    super.initState();
    _startTimer(_resendDelays[0]);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(int seconds) {
    _timer?.cancel();
    setState(() => _secondsLeft = seconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  bool _isBlockingError(String message) {
    return message.contains("bloqué") || message.contains("expiré");
  }

  void _onCodeComplete(String code) {
    if (_inputBlocked) return;
    setState(() => _waitingForVerification = true);
    context.read<UserBloc>().add(VerifyAndSignup(code, widget.userReq));
  }

  void _onResend() {
    if (_secondsLeft > 0) return;

    context.read<UserBloc>().add(SendOtp(widget.userReq.telephone ?? ""));

    final nextIndex = (_currentDelayIndex + 1).clamp(0, _resendDelays.length - 1);
    setState(() {
      _currentDelayIndex = nextIndex;
      _otpKey++;
      _inputBlocked = false;
      _errorMessage = null;
      _waitingForVerification = false;
    });
    _startTimer(_resendDelays[_currentDelayIndex]);
  }

  void _handleError(String message) {
    if (!_waitingForVerification) return;

    final blocking = _isBlockingError(message);
    setState(() {
      _waitingForVerification = false;
      _errorMessage = message;
      _inputBlocked = blocking;
      if (blocking) _otpKey++;
    });
  }

  void _redirectBasedOnUser(dynamic user) {
    if (user is Proprietaire) {
      pushAndRemoveAll(context, ProprioNavigation());
    } else if (user is Demarcheur) {
      pushAndRemoveAll(context, DemarcheurNavigation());
    } else if (user is Locataire) {
      pushAndRemoveAll(context, Home());
    } else {
      pushAndRemoveAll(context, Home());
    }
  }

  String _maskedPhone(String? telephone) {
    if (telephone == null || telephone.length < 4) return telephone ?? "";
    return "${telephone.substring(0, telephone.length - 2).replaceAll(RegExp(r'\d'), '•')}${telephone.substring(telephone.length - 2)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<UserBloc, UserState>(
          builder: (context, state) {
            if (state is UserLoading && _waitingForVerification) {
              return const Center(child: CircularProgressIndicator());
            }
            return _buildBody();
          },
          listener: (context, state) {
            if (state is UserLoaded) {
              _redirectBasedOnUser(state.user);
            }
            if (state is UserError) {
              _handleError(state.message);
            }
          },
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(Espacement.paddingBloc),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IconButton(
              alignment: Alignment.centerLeft,
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => back(context),
            ),
            const Logo(),
            Gap(Espacement.paddingBloc),
            TextSeed(
              "Vérification",
              fontWeight: FontWeight.bold,
              fontSize: 22,
              textAlign: TextAlign.center,
            ),
            Gap(Espacement.gapSection),
            TextSeed(
              "Code envoyé au ${_maskedPhone(widget.userReq.telephone)}",
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
            ),
            Gap(Espacement.paddingBloc),
            OtpInput(
              key: ValueKey(_otpKey),
              onCompleted: _onCodeComplete,
              enabled: !_inputBlocked,
            ),
            Gap(Espacement.gapSection),
            if (_errorMessage != null)
              TextSeed(
                _errorMessage!,
                color: AppColors.error,
                textAlign: TextAlign.center,
              ),
            Gap(Espacement.paddingBloc),
            _buildResendButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildResendButton() {
    if (_secondsLeft > 0) {
      return Center(
        child: TextSeed(
          "Renvoyer dans ${_secondsLeft}s",
          color: AppColors.textSecondary,
        ),
      );
    }

    return Center(
      child: TexteButton(
        text: "Renvoyer le code",
        onPressed: _onResend,
      ),
    );
  }
}
