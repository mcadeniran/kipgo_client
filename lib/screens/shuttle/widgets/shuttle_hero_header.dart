import 'package:flutter/material.dart';
import 'package:kipgo/controllers/auth_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class ShuttleHeroHeader extends StatelessWidget {
  const ShuttleHeroHeader({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    final auth = context.read<AuthProvider>();

    final user = auth.profile!;

    String greeting() {
      final hour = DateTime.now().hour;

      if (hour < 12) {
        return loc.goodMorning;
      }

      if (hour < 17) {
        return loc.goodAfternoon;
      }

      return loc.goodEvening;
    }

    return Container(
      height: 300,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.darkLayer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  greeting(),
                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                ),

                const SizedBox(height: 10),

                Text(
                  user.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  loc.charterAShuttle,
                  style: TextStyle(color: Colors.white70, height: 1.5),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Image.asset('assets/images/bus.png', width: 130),
        ],
      ),
    );
  }
}
