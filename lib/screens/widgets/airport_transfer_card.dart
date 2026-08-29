import 'package:flutter/material.dart';
import 'package:kipgo/helpers/require_authentication.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/shuttle/shuttle_bottom_navigation.dart';
import 'package:kipgo/utils/colors.dart';

class AirportTransferCard extends StatelessWidget {
  const AirportTransferCard({super.key});

  @override
  Widget build(BuildContext context) {
    const gradient = [AppColors.primary, Color(0xff1F4BD8)];
    AppLocalizations loc = AppLocalizations.of(context)!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ShuttleBottomNavigation()),
          );
        },
        child: Ink(
          height: 230,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withValues(alpha: .0),
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -45,
                top: -45,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: .08),
                  ),
                ),
              ),

              Positioned(
                left: 24,
                top: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .18),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    loc.airportTransferTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              Positioned(
                right: 24,
                top: 24,
                child: Icon(
                  Icons.airplanemode_active_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 60, 150, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    Expanded(
                      child: Text(
                        loc.bookAirportTransferInAdvance,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: .92),
                          fontSize: 15,
                          height: 1.45,
                        ),
                      ),
                    ),

                    ElevatedButton(
                      onPressed: () async {
                        final authenticated = await requireAuthentication(
                          context,
                        );

                        if (!authenticated || !context.mounted) return;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ShuttleBottomNavigation(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(loc.bookNow),
                    ),

                    // Row(
                    //   children: [
                    //     Text(
                    //       'Book Now',
                    //       style: TextStyle(
                    //         color: Colors.white,
                    //         fontWeight: FontWeight.w600,
                    //         fontSize: 15,
                    //       ),
                    //     ),
                    //     SizedBox(width: 8),
                    //     Icon(
                    //       Icons.arrow_forward_rounded,
                    //       color: Colors.white,
                    //       size: 18,
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),

              /// Vehicle Image
              Positioned(
                right: 8,
                bottom: 8,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: Image.asset(
                    'assets/images/vito.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
