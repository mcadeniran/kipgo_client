import 'package:flutter/material.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/shuttle_service_item.dart';
import 'package:kipgo/screens/shuttle/widgets/shuttle/shuttle_section_header.dart';
import 'package:kipgo/screens/shuttle/widgets/shuttle/shuttle_service_card.dart';

class ShuttleServicesSection extends StatelessWidget {
  const ShuttleServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    final services = shuttleServices(context);
    return Column(
      children: [
        ShuttleSectionHeader(
          title: loc.ourServices,
          subtitle: loc.ourDifferentServices,
        ),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 0),
            itemCount: services.length,
            itemBuilder: (_, i) {
              final service = services[i];
              return ShuttleServiceCard(item: service);
            },
          ),
        ),
      ],
    );
  }
}
