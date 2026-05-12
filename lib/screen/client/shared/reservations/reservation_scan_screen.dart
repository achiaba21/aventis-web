import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/function.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/icon_boutton.dart';

/// Écran de scan QR — utilisé par le propriétaire pour finaliser une
/// réservation au statut `payée`.
///
/// Au scan réussi, l'écran se ferme via `Navigator.pop(secretKey)` et
/// délègue la finalisation au caller (la page détail qui dispatchera
/// `PerformAction(scanQr, secretKey)` sur le `ReservationDetailBloc`).
class ReservationScanScreen extends StatefulWidget {
  const ReservationScanScreen({super.key});

  @override
  State<ReservationScanScreen> createState() => _ReservationScanScreenState();
}

class _ReservationScanScreenState extends State<ReservationScanScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final code = capture.barcodes
        .map((b) => b.rawValue)
        .firstWhere((v) => v != null && v.isNotEmpty, orElse: () => null);
    if (code == null || code.isEmpty) return;
    _handled = true;
    deboger(['[ReservationScanScreen] QR détecté: $code']);
    back(context, code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: DynamicAppBar(
        title: 'Scanner le code',
        backgroundColor: AppColors.black,
        leading: IconBoutton(
          icon: Icons.arrow_back_ios_new,
          onPressed: () => back(context),
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          const _ReservationScanOverlay(),
        ],
      ),
    );
  }
}

class _ReservationScanOverlay extends StatelessWidget {
  const _ReservationScanOverlay();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.accent, width: 3),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.overlay,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Cadrez le QR du locataire',
              style: AppTextStyles.body.copyWith(color: AppColors.text),
            ),
          ),
        ],
      ),
    );
  }
}
