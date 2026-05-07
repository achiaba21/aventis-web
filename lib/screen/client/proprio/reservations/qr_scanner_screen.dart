import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_event.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_state.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Écran de scan QR code pour le propriétaire
/// Scanne le QR code du locataire pour finaliser la réservation
class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isProcessing = false;
  late AnimationController _animationController;
  late Animation<double> _scanLineAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? code = barcode.rawValue;
      if (code != null && code.isNotEmpty) {
        setState(() => _isProcessing = true);
        _processQRCode(code);
        break;
      }
    }
  }

  void _processQRCode(String secretKey) {
    // Vibration feedback
    // HapticFeedback.mediumImpact();

    // Déclencher l'événement BLoC pour finaliser la réservation
    context.read<ReservationBloc>().add(FinalizeReservation(secretKey));
  }

  void _toggleTorch() async {
    await _controller.toggleTorch();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReservationBloc, ReservationState>(
      listener: (context, state) {
        if (state is ReservationFinalized) {
          back(context); // Retour à l'écran précédent
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Réservation finalisée avec succès !'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 3),
            ),
          );
        } else if (state is ReservationError) {
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              duration: Duration(seconds: 4),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: TextSeed(
            "Scanner le code QR",
            color: Colors.white,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: _toggleTorch,
              icon: Icon(
                Icons.flash_on,
                color: Colors.white,
              ),
              tooltip: "Activer/Désactiver la lampe",
            ),
          ],
        ),
        body: Stack(
          children: [
            // Caméra de scan
            MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
            ),

            // Overlay avec zone de scan
            _ScanOverlay(animation: _scanLineAnimation),

            // Instructions en bas
            const _ScanInstructions(),

            // Indicateur de chargement
            if (_isProcessing) const _LoadingOverlay(),
          ],
        ),
      ),
    );
  }
}

/// Overlay avec zone de scan et animation
class _ScanOverlay extends StatelessWidget {
  final Animation<double> animation;

  const _ScanOverlay({required this.animation});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        shape: QrScannerOverlayShape(
          borderColor: AppColors.accent,
          borderRadius: Espacement.radius,
          borderLength: 40,
          borderWidth: 8,
          cutOutSize: MediaQuery.of(context).size.width * 0.75,
        ),
      ),
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return CustomPaint(
            painter: ScanLinePainter(
              progress: animation.value,
              color: AppColors.accent,
            ),
          );
        },
      ),
    );
  }
}

/// Instructions pour l'utilisateur
class _ScanInstructions extends StatelessWidget {
  const _ScanInstructions();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 60,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: Espacement.paddingBloc * 2),
        padding: EdgeInsets.all(Espacement.paddingBloc),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(Espacement.radius),
          border: Border.all(
            color: AppColors.accent.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.qr_code_scanner,
              color: AppColors.accent,
              size: 32,
            ),
            Gap(Espacement.paddingInput),
            TextSeed(
              "Pointez la caméra vers le QR code",
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.center,
            ),
            const Gap(4),
            TextSeed(
              "Le scan se fera automatiquement",
              color: AppColors.textMuted,
              fontSize: 12,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Overlay de chargement pendant le traitement
class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(Espacement.paddingBloc * 2),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(Espacement.radius),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppColors.accent),
              ),
              Gap(Espacement.paddingBloc),
              TextSeed(
                "Finalisation en cours...",
                fontSize: 14,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom shape pour l'overlay de scan
class QrScannerOverlayShape extends ShapeBorder {
  const QrScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return getLeftTopPath(rect)
      ..lineTo(
        rect.right,
        rect.bottom,
      )
      ..lineTo(
        rect.left,
        rect.bottom,
      )
      ..lineTo(
        rect.left,
        rect.top,
      );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final double cutOutWidth = cutOutSize;
    final double cutOutHeight = cutOutSize;
    final Rect cutOutRect = Rect.fromLTWH(
      rect.left + rect.width / 2 - cutOutWidth / 2,
      rect.top + rect.height / 2 - cutOutHeight / 2,
      cutOutWidth,
      cutOutHeight,
    );

    final Paint backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final Path backgroundPath = Path()
      ..addRect(rect)
      ..addRRect(
        RRect.fromRectAndRadius(
          cutOutRect,
          Radius.circular(borderRadius),
        ),
      )
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(backgroundPath, backgroundPaint);

    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    // Dessiner les coins
    _drawCorners(canvas, cutOutRect, borderPaint);
  }

  void _drawCorners(Canvas canvas, Rect rect, Paint paint) {
    // Coin supérieur gauche
    canvas.drawLine(
      Offset(rect.left, rect.top + borderLength),
      Offset(rect.left, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left + borderLength, rect.top),
      paint,
    );

    // Coin supérieur droit
    canvas.drawLine(
      Offset(rect.right - borderLength, rect.top),
      Offset(rect.right, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.top + borderLength),
      paint,
    );

    // Coin inférieur gauche
    canvas.drawLine(
      Offset(rect.left, rect.bottom - borderLength),
      Offset(rect.left, rect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left + borderLength, rect.bottom),
      paint,
    );

    // Coin inférieur droit
    canvas.drawLine(
      Offset(rect.right, rect.bottom - borderLength),
      Offset(rect.right, rect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right - borderLength, rect.bottom),
      Offset(rect.right, rect.bottom),
      paint,
    );
  }

  @override
  ShapeBorder scale(double t) => this;
}

/// Painter pour la ligne de scan animée
class ScanLinePainter extends CustomPainter {
  final double progress;
  final Color color;

  ScanLinePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double cutOutSize = size.width * 0.75;
    final double left = (size.width - cutOutSize) / 2;
    final double top = (size.height - cutOutSize) / 2;
    final double lineY = top + (cutOutSize * progress);

    final Paint paint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 2.0;

    canvas.drawLine(
      Offset(left, lineY),
      Offset(left + cutOutSize, lineY),
      paint,
    );
  }

  @override
  bool shouldRepaint(ScanLinePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
