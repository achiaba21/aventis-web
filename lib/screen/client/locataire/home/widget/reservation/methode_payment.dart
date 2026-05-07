import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_event.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_state.dart';
import 'package:asfar/model/enumeration/moyen_paiement.dart';
import 'package:asfar/widget/item/custom_tile.dart';
import 'package:asfar/widget/text/text_seed.dart';

class MethodePayment extends StatefulWidget {
  const MethodePayment({super.key});

  @override
  State<MethodePayment> createState() => _MethodePaymentState();
}

class _MethodePaymentState extends State<MethodePayment> {
  MoyenPaiement? selectedPayment;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReservationBloc, ReservationState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextSeed("Moyen de paiement", fontSize: 16, fontWeight: FontWeight.w600),
            SizedBox(height: 12),

            // Wave uniquement
            CustomTile(
              leftSvgPath: "assets/icon/mobile_monney.svg",
              libelle: "Wave",
              rightImage: selectedPayment == MoyenPaiement.WAVE
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              onPressed: () => _selectPaymentMethod(context, MoyenPaiement.WAVE),
            ),
          ],
        );
      },
    );
  }

  void _selectPaymentMethod(BuildContext context, MoyenPaiement payment) {
    setState(() {
      selectedPayment = payment;
    });

    final reservationBloc = context.read<ReservationBloc>();
    final req = reservationBloc.state.currentReq;
    if (req != null) {
      req.moyenPaiement = payment;
      reservationBloc.add(SetReservationReq(req));
    }
  }
}
