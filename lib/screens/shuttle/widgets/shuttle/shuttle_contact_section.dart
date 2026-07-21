import 'package:flutter/material.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/shuttle/widgets/shuttle/shuttle_contact_card.dart';
import 'package:kipgo/screens/shuttle/widgets/shuttle/shuttle_section_header.dart';

class ShuttleContactSection extends StatelessWidget {
  const ShuttleContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    return Column(
      children: [
        ShuttleSectionHeader(
          title: loc.needAssistance,
          subtitle: loc.needAssistanceSubtitle,
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              ShuttleContactCard(
                icon: Icons.call_rounded,
                title: loc.call,
                onTap: () {},
              ),

              const SizedBox(width: 12),

              ShuttleContactCard(
                icon: Icons.chat_rounded,
                title: loc.whatsapp,
                onTap: () {},
              ),

              const SizedBox(width: 12),

              ShuttleContactCard(
                icon: Icons.email_rounded,
                title: loc.email,
                onTap: () {},
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),
      ],
    );
  }
}
