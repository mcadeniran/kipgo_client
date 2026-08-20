import 'package:flutter/material.dart';
import 'package:kipgo/helpers/contact_launcher.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/shuttle/widgets/shuttle/shuttle_contact_card.dart';
import 'package:kipgo/screens/shuttle/widgets/shuttle/shuttle_section_header.dart';
import 'package:kipgo/screens/widgets/reusable_toast.dart';

class ShuttleContactSection extends StatelessWidget {
  const ShuttleContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;

    const shuttlePhone = "+905391054485";
    const shuttleWhatsapp = "905391054485";
    const shuttleEmail = "kipgoonlinedriver@gmail.com";

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
                onTap: () async {
                  try {
                    await ContactLauncher.call(shuttlePhone);
                  } catch (_) {
                    if (!context.mounted) return;
                    ReusableToast.error(
                      context,
                      'Error',
                      'Unable to make phone call',
                    );
                  }
                },
              ),

              const SizedBox(width: 12),

              ShuttleContactCard(
                icon: Icons.chat_rounded,
                title: loc.whatsapp,
                onTap: () async {
                  try {
                    await ContactLauncher.whatsapp(shuttleWhatsapp);
                  } catch (_) {
                    if (!context.mounted) return;

                    ReusableToast.error(
                      context,
                      'Error',
                      'Unable to launch WhatsApp.',
                    );
                  }
                },
              ),

              const SizedBox(width: 12),

              ShuttleContactCard(
                icon: Icons.email_rounded,
                title: loc.email,
                onTap: () async {
                  try {
                    await ContactLauncher.email(
                      email: shuttleEmail,
                      subject: "Shuttle Booking Support",
                    );
                  } catch (_) {
                    if (!context.mounted) return;

                    ReusableToast.error(
                      context,
                      'Error',
                      'Unable to launch email client',
                    );
                  }
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),
      ],
    );
  }
}
