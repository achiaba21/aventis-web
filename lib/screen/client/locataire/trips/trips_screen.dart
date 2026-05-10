import 'package:flutter/material.dart';
import 'package:asfar/screen/client/locataire/home/sample_listings.dart';
import 'package:asfar/screen/client/locataire/trips/widget/trip_card.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/badge/asfar_chip.dart';

/// Écran "Mes voyages" du Locataire.
///
/// Reproduit `LocataireTrips` du proto : chips à venir / passés + liste
/// de [TripCard] avec footer actions sur les voyages à venir.
class LocataireTripsScreen extends StatefulWidget {
  const LocataireTripsScreen({super.key});

  @override
  State<LocataireTripsScreen> createState() => _LocataireTripsScreenState();
}

class _LocataireTripsScreenState extends State<LocataireTripsScreen> {
  bool _upcoming = true;

  @override
  Widget build(BuildContext context) {
    final listings = SampleListings.all;
    final trips = [
      _TripData(
        listing: listings[0],
        status: 'À venir',
        dates: '12 - 15 nov 2025',
        code: 'ASF-7K2N9',
        upcoming: true,
      ),
      _TripData(
        listing: listings[2],
        status: 'Terminé',
        dates: '3 - 6 oct 2025',
        code: 'ASF-3T8M1',
        upcoming: false,
      ),
      _TripData(
        listing: listings[1],
        status: 'Terminé',
        dates: '18 - 20 sept 2025',
        code: 'ASF-9P2X4',
        upcoming: false,
      ),
    ];

    final filtered = trips.where((t) => t.upcoming == _upcoming).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const DynamicAppBar(title: 'Mes voyages'),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AsfarChip(
                    label: 'À venir (${trips.where((t) => t.upcoming).length})',
                    active: _upcoming,
                    onTap: () => setState(() => _upcoming = true),
                  ),
                  const SizedBox(width: 8),
                  AsfarChip(
                    label: 'Passés (${trips.where((t) => !t.upcoming).length})',
                    active: !_upcoming,
                    onTap: () => setState(() => _upcoming = false),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              for (final t in filtered) ...[
                TripCard(
                  listing: t.listing,
                  status: t.status,
                  dates: t.dates,
                  code: t.code,
                  upcoming: t.upcoming,
                ),
                const SizedBox(height: 14),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TripData {
  final dynamic listing;
  final String status;
  final String dates;
  final String code;
  final bool upcoming;
  _TripData({
    required this.listing,
    required this.status,
    required this.dates,
    required this.code,
    required this.upcoming,
  });
}
