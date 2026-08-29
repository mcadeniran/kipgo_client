import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/auth/auth_screen.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class RequireAuthenticationPage extends StatelessWidget {
  final String? title;
  final String? message;
  final String? buttonText;
  final VoidCallback? onAuthenticated;

  const RequireAuthenticationPage({
    super.key,
    this.title,
    this.message,
    this.buttonText,
    this.onAuthenticated,
  });

  Future<void> _authenticate(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );

    if (result == true && context.mounted) {
      onAuthenticated?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    final primaryColor = isDark ? AppColors.darkLayer : AppColors.primary;

    final textColor = isDark ? Colors.white : Colors.black87;

    final mutedColor = isDark ? Colors.white70 : Colors.blueGrey.shade600;

    AppLocalizations loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // ----------------------------------------------------------
            // Decorative background glow
            // ----------------------------------------------------------
            Positioned(
              top: -120,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withValues(alpha: .055),
                ),
              ),
            ),

            Positioned(
              bottom: -140,
              left: -120,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withValues(alpha: .04),
                ),
              ),
            ),

            // ----------------------------------------------------------
            // Main content
            // ----------------------------------------------------------
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 40,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ----------------------------------------------------
                    // Kipgo logo
                    // ----------------------------------------------------
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: .07),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Image.asset('assets/images/splash12.png'),
                    ),

                    const SizedBox(height: 32),

                    // ----------------------------------------------------
                    // Lock / account icon
                    // ----------------------------------------------------
                    Container(
                      width: 118,
                      height: 118,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor.withValues(alpha: .07),
                      ),
                      child: Center(
                        child: Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryColor.withValues(alpha: .12),
                          ),
                          child: Icon(
                            Icons.lock_outline_rounded,
                            size: 38,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ----------------------------------------------------
                    // Title
                    // ----------------------------------------------------
                    Text(
                      title ?? loc.welcomeToKipgo,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 27,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: textColor,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ----------------------------------------------------
                    // Description
                    // ----------------------------------------------------
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 430),
                      child: Text(
                        message ?? loc.signInOrCreateAccountToContinue,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          height: 1.65,
                          color: mutedColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ----------------------------------------------------
                    // Benefits
                    // ----------------------------------------------------
                    _BenefitItem(
                      icon: Icons.bookmark_outline_rounded,
                      text: loc.manageYourBookings,
                      primaryColor: primaryColor,
                      textColor: textColor,
                    ),

                    const SizedBox(height: 12),

                    _BenefitItem(
                      icon: Icons.favorite_border_rounded,
                      text: loc.saveYourFavouriteEx,
                      primaryColor: primaryColor,
                      textColor: textColor,
                    ),

                    const SizedBox(height: 12),

                    _BenefitItem(
                      icon: Icons.speed_rounded,
                      text: loc.enjoyAFasterBooking,
                      primaryColor: primaryColor,
                      textColor: textColor,
                    ),

                    const SizedBox(height: 34),

                    // ----------------------------------------------------
                    // Authentication button
                    // ----------------------------------------------------
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () => _authenticate(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          buttonText ?? loc.signInOrRegister,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ----------------------------------------------------
                    // Continue browsing
                    // ----------------------------------------------------
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        loc.continueBrowsing,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: mutedColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color primaryColor;
  final Color textColor;

  const _BenefitItem({
    required this.icon,
    required this.text,
    required this.primaryColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: .045),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withValues(alpha: .08)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withValues(alpha: .09),
            ),
            child: Icon(icon, size: 18, color: primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
