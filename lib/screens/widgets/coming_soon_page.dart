import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class ComingSoonPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final String icon;
  final VoidCallback? onBack;

  const ComingSoonPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    final primaryColor = isDark ? AppColors.darkLayer : AppColors.primary;

    final mutedColor = isDark ? Colors.white70 : Colors.blueGrey.shade600;

    AppLocalizations loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // ------------------------------------------------------------
            // Decorative background
            // ------------------------------------------------------------
            Positioned(
              top: -120,
              right: -100,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withValues(alpha: .06),
                ),
              ),
            ),

            Positioned(
              bottom: -150,
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

            // ------------------------------------------------------------
            // Back button
            // ------------------------------------------------------------
            Positioned(
              top: 12,
              left: 12,
              child: IconButton(
                onPressed: onBack ?? () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),

            // ------------------------------------------------------------
            // Content
            // ------------------------------------------------------------
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 40,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Image.asset(
                      'assets/images/splash12.png',
                      width: 62,
                      height: 62,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Kipgo',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: 45),

                    // ----------------------------------------------------
                    // Service icon
                    // ----------------------------------------------------
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor.withValues(alpha: .08),
                      ),
                      child: Center(
                        child: Container(
                          width: 86,
                          height: 86,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryColor.withValues(alpha: .12),
                          ),
                          child: Center(
                            child: Iconify(icon, size: 42, color: primaryColor),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ----------------------------------------------------
                    // Coming soon
                    // ----------------------------------------------------
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: .09),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        loc.comingSoonTag,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: primaryColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Title
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Subtitle
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: primaryColor,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Description
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Text(
                        description,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                          color: mutedColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 35),

                    // ----------------------------------------------------
                    // Decorative divider
                    // ----------------------------------------------------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 35,
                          height: 1,
                          color: primaryColor.withValues(alpha: .25),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 35,
                          height: 1,
                          color: primaryColor.withValues(alpha: .25),
                        ),
                      ],
                    ),

                    const SizedBox(height: 35),

                    // ----------------------------------------------------
                    // Footer
                    // ----------------------------------------------------
                    Text(
                      loc.somethingWonderfulIsOnTheWay,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                        color: mutedColor,
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
