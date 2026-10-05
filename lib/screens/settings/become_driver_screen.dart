import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kipgo/controllers/auth_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BecomeDriverScreen extends StatefulWidget {
  const BecomeDriverScreen({super.key});

  @override
  State<BecomeDriverScreen> createState() => _BecomeDriverScreenState();
}

class _BecomeDriverScreenState extends State<BecomeDriverScreen> {
  bool _isLoading = false;
  bool _hasConfirmedEligibility = false;

  Future<void> _becomeDriver() async {
    if (!_hasConfirmedEligibility || _isLoading) return;
    final loc = AppLocalizations.of(context)!;
    final auth = context.read<AuthProvider>();

    final profile = auth.profile;

    if (profile == null || profile.role != 'rider') {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      /*
       * Update the user's role.
       *
       * IMPORTANT:
       * Replace 'users' below if your actual Firestore profile
       * collection uses a different name.
       */
      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(profile.id)
          .update({'role': 'driver', 'account.isApproved': false});

      await auth.refreshProfile();

      if (!mounted) return;

      /*
       * If your AuthProvider has a method for refreshing/reloading
       * the profile, call it here.
       *
       * Example:
       *
       * await context.read<AuthProvider>().refreshProfile();
       */

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          final isDark = context.read<ThemeProvider>().isDarkMode;

          return Dialog(
            backgroundColor: isDark ? AppColors.darkAccent : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondary.withValues(alpha: .12),
                    ),
                    child: Icon(
                      Icons.local_taxi_rounded,
                      size: 38,
                      color: AppColors.secondary,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    loc.driverAccountActivated,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    loc.driverAccountActivatedDescription,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      height: 1.55,
                      color: Colors.blueGrey,
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        loc.continueText,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.unableToChangeAccountRole),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final loc = AppLocalizations.of(context)!;

    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    final cardColor = isDark ? AppColors.darkAccent : Colors.grey.shade50;

    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Scaffold(
      backgroundColor: AppColors.primary,

      appBar: AppBarWidget(
        title: loc.becomeADriver.toUpperCase(),
        showLanguage: false,
      ),

      body: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),

        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
                  children: [
                    // =====================================================
                    // HERO
                    // =====================================================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withValues(alpha: .10),
                            AppColors.secondary.withValues(alpha: .07),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: .08),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 86,
                            height: 86,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.secondary.withValues(alpha: .12),
                            ),
                            child: Icon(
                              Icons.local_taxi_rounded,
                              size: 44,
                              color: AppColors.secondary,
                            ),
                          ),

                          const SizedBox(height: 18),

                          Text(
                            loc.driveWithKipgo,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            loc.driveWithKipgoDescription,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              height: 1.6,
                              color: isDark ? Colors.white70 : Colors.blueGrey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // =====================================================
                    // REQUIREMENTS
                    // =====================================================
                    Text(
                      loc.beforeYouContinue,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _buildRequirementCard(
                      context,
                      icon: Icons.local_taxi_outlined,
                      title: loc.registeredTaxiDriver,
                      description: loc.registeredTaxiDriverDescription,
                      cardColor: cardColor,
                      iconColor: isDark
                          ? AppColors.lightLayer
                          : AppColors.primary,
                    ),

                    const SizedBox(height: 10),

                    _buildRequirementCard(
                      context,
                      icon: Icons.location_on_outlined,
                      title: loc.northernCyprusRequirement,
                      description: loc.northernCyprusRequirementDescription,
                      cardColor: cardColor,
                      iconColor: AppColors.tertiary,
                    ),

                    const SizedBox(height: 10),

                    _buildRequirementCard(
                      context,
                      icon: Icons.badge_outlined,
                      title: loc.legalCompliance,
                      description: loc.legalComplianceDescription,
                      cardColor: cardColor,
                      iconColor: AppColors.secondary,
                    ),

                    const SizedBox(height: 28),

                    // =====================================================
                    // IMPORTANT NOTICE
                    // =====================================================
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: .07),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: .18),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.orange.withValues(alpha: .10),
                            ),
                            child: const Icon(
                              Icons.info_outline_rounded,
                              size: 20,
                              color: Colors.orange,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              loc.driverEligibilityNotice,
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                height: 1.55,
                                color: isDark
                                    ? Colors.white70
                                    : Colors.blueGrey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // =====================================================
                    // CONFIRMATION
                    // =====================================================
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        setState(() {
                          _hasConfirmedEligibility = !_hasConfirmedEligibility;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _hasConfirmedEligibility
                                ? AppColors.primary.withValues(alpha: .30)
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: _hasConfirmedEligibility,
                              activeColor: isDark
                                  ? AppColors.lightLayer
                                  : AppColors.primary,
                              onChanged: (value) {
                                setState(() {
                                  _hasConfirmedEligibility = value ?? false;
                                });
                              },
                            ),

                            const SizedBox(width: 4),

                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  loc.iConfirmDriverEligibility,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    height: 1.5,
                                    fontWeight: FontWeight.w500,
                                    color: textColor,
                                  ),
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

              // ===========================================================
              // BOTTOM ACTION
              // ===========================================================
              Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .06),
                      blurRadius: 14,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: _hasConfirmedEligibility && !_isLoading
                        ? _becomeDriver
                        : null,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 19,
                            height: 19,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.local_taxi_rounded, size: 20),
                    label: Text(
                      _isLoading ? loc.pleaseWait : loc.switchToDriverAccount,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: isDark
                          ? Colors.white12
                          : Colors.black12,
                      disabledForegroundColor: isDark
                          ? Colors.white38
                          : Colors.black38,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequirementCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color cardColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withValues(alpha: .09),
            ),
            child: Icon(icon, size: 21, color: iconColor),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    height: 1.5,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
