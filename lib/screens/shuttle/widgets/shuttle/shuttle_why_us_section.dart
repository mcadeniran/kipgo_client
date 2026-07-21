import 'package:flutter/material.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/shuttle/widgets/shuttle/shuttle_feature_card.dart';
import 'package:kipgo/screens/shuttle/widgets/shuttle/shuttle_section_header.dart';

class ShuttleWhyUsSection extends StatelessWidget {
  const ShuttleWhyUsSection({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    final features = shuttleFeatures(context);
    return Column(
      children: [
        ShuttleSectionHeader(
          title: loc.whyChooseUs,
          subtitle: loc.travelWithConfidence,
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: features.length,
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: .95,
            ),
            itemBuilder: (_, i) => ShuttleFeatureCard(feature: features[i]),
          ),
        ),
      ],
    );
  }
}
