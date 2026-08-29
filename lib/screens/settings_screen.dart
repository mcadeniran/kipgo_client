import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/carbon.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:kipgo/controllers/auth_provider.dart';
import 'package:kipgo/models/profile.dart';
import 'package:kipgo/screens/auth/auth_screen.dart';
import 'package:kipgo/screens/auth/main_app_bottom_navigation.dart';
import 'package:provider/provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/edit_profile.dart';
import 'package:kipgo/screens/settings/change_password_screen.dart';
import 'package:kipgo/screens/settings/chat.dart';
import 'package:kipgo/screens/settings/delete_account_screen.dart';
import 'package:kipgo/screens/settings/terms_and_conditions_screen.dart';
import 'package:kipgo/screens/settings/vehicle_details_screen.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/screens/widgets/change_theme_button_widget.dart';
import 'package:kipgo/screens/widgets/language_picker_widget.dart';
import 'package:kipgo/utils/colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _openAuth() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );

    if (!mounted) return;

    if (result == true) {
      setState(() {});
    }
  }

  Future<void> _logout(AppLocalizations loc) async {
    bool isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: isDark
              ? AppColors.darkAccent
              : Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 76,
                  width: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.tertiary.withValues(alpha: .12),
                  ),
                  child: Icon(
                    Icons.logout_outlined,
                    size: 40,
                    color: AppColors.tertiary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  loc.signOut,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                Text(loc.areYouSureSignOut),
                const SizedBox(height: 40),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          style: TextButton.styleFrom(
                            // backgroundColor: AppColors.primary,
                            foregroundColor: isDark
                                ? AppColors.lightLayer
                                : AppColors.primary,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            loc.cancel,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: FilledButton(
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.tertiary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            loc.signOut,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed != true || !mounted) return;

    await context.read<AuthProvider>().logout(context);

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainAppBottomNavigation()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final auth = context.watch<AuthProvider>();
    final loc = AppLocalizations.of(context)!;

    final profile = auth.profile;
    final isLoggedIn = auth.isLoggedIn;

    final primaryColor = isDark ? AppColors.darkLayer : AppColors.primary;

    final cardColor = isDark ? AppColors.darkAccent : Colors.grey.shade50;

    final dividerColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBarWidget(
        title: loc.settings.toUpperCase(),
        showLanguage: false,
      ),
      body: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
          children: [
            // ============================================================
            // ACCOUNT HEADER
            // ============================================================
            if (isLoggedIn && profile != null) ...[
              _buildProfileCard(
                context,
                profile,
                isDark,
                primaryColor,
                cardColor,
              ),
            ] else ...[
              _buildGuestCard(context, isDark, primaryColor, cardColor),
            ],

            const SizedBox(height: 26),

            // ============================================================
            // ACCOUNT
            // ============================================================
            if (isLoggedIn && profile != null) ...[
              _buildSectionTitle(context, loc.accountTitle),

              const SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    if (profile.role == 'driver') ...[
                      _buildSettingItem(
                        context,
                        icon: Icons.directions_car_outlined,
                        title: loc.vehicleDetails,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const VehicleDetailsScreen(),
                            ),
                          );
                        },
                      ),
                      Divider(height: 1, color: dividerColor),
                    ],

                    _buildSettingItem(
                      context,
                      icon: Icons.lock_outline_rounded,
                      title: loc.changePassword,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ChangePasswordScreen(),
                          ),
                        );
                      },
                    ),

                    Divider(height: 1, color: dividerColor),

                    _buildSettingItem(
                      context,
                      icon: Icons.delete_outline_rounded,
                      title: loc.deleteAccount,
                      iconColor: Colors.red,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DeleteAccountScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),
            ],

            // ============================================================
            // APP PREFERENCES
            // ============================================================
            _buildSectionTitle(context, loc.appTitle),

            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  // Language
                  _buildPreferenceItem(
                    context,
                    icon: Carbon.ibm_watson_language_translator,
                    title: loc.changeLanguage,
                    trailing: const LanguagePickerWidget(),
                  ),

                  Divider(height: 1, color: dividerColor),

                  // Theme
                  _buildPreferenceItem(
                    context,
                    icon: Ph.moon_stars,
                    title: loc.enableDarkMode,
                    trailing: const ChangeThemeButtonWidget(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            // ============================================================
            // SUPPORT
            // ============================================================
            _buildSectionTitle(context, loc.supportTitle),

            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  if (isLoggedIn) ...[
                    _buildSettingItem(
                      context,
                      icon: Icons.chat_bubble_outline_rounded,
                      title: loc.chatWithUs,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SupportChatScreen(),
                          ),
                        );
                      },
                    ),

                    Divider(height: 1, color: dividerColor),
                  ],

                  _buildSettingItem(
                    context,
                    icon: Icons.description_outlined,
                    title: loc.termsAndConditions,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TermsAndConditionsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            // ============================================================
            // LOGIN / LOGOUT
            // ============================================================
            if (isLoggedIn)
              _buildLogoutButton(context, loc)
            else
              _buildSignInButton(context, primaryColor, isDark, loc),

            const SizedBox(height: 24),

            // ============================================================
            // VERSION / BRANDING
            // ============================================================
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  // =====================================================================
  // PROFILE CARD
  // =====================================================================

  Widget _buildProfileCard(
    BuildContext context,
    Profile profile,
    bool isDark,
    Color primaryColor,
    Color cardColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withValues(alpha: .08)),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 70,
            height: 70,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: primaryColor.withValues(alpha: .25),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: profile.personal.photoUrl.isEmpty
                  ? Image.asset('assets/images/avatar.png', fit: BoxFit.cover)
                  : Image.network(
                      profile.personal.photoUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;

                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/image_not_found.png',
                          fit: BoxFit.cover,
                        );
                      },
                    ),
            ),
          ),

          const SizedBox(width: 14),

          // User information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  profile.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.blueGrey),
                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _roleLabel(profile.role, AppLocalizations.of(context)!),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Edit
          Material(
            color: primaryColor.withValues(alpha: .08),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(Icons.edit_outlined, size: 18, color: primaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================================
  // GUEST CARD
  // =====================================================================

  Widget _buildGuestCard(
    BuildContext context,
    bool isDark,
    Color primaryColor,
    Color cardColor,
  ) {
    final loc = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: primaryColor.withValues(alpha: .08)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withValues(alpha: .08),
            ),
            child: Icon(
              Icons.person_outline_rounded,
              size: 32,
              color: primaryColor,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            loc.makeYourKipgoJourneyYours,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            loc.signInOrCreateAccount,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              height: 1.55,
              color: isDark ? Colors.white70 : Colors.blueGrey,
            ),
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _openAuth,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                loc.signInOrRegister,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================================
  // SECTION TITLE
  // =====================================================================

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: .2,
      ),
    );
  }

  // =====================================================================
  // SETTING ITEM
  // =====================================================================

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    final color = iconColor ?? Theme.of(context).iconTheme.color;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color?.withValues(alpha: .08),
              ),
              child: Icon(icon, size: 19, color: color),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),

            Icon(
              Icons.chevron_right_rounded,
              size: 21,
              color: Colors.blueGrey.withValues(alpha: .6),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================================
  // PREFERENCE ITEM
  // =====================================================================

  Widget _buildPreferenceItem(
    BuildContext context, {
    required String icon,
    required String title,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: .07),
            ),
            child: Center(
              child: Iconify(
                icon,
                size: 19,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),

          trailing,
        ],
      ),
    );
  }

  // =====================================================================
  // SIGN IN BUTTON
  // =====================================================================

  Widget _buildSignInButton(
    BuildContext context,
    Color primaryColor,
    bool isDark,
    AppLocalizations loc,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withValues(alpha: .12),
            primaryColor.withValues(alpha: .04),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primaryColor.withValues(alpha: .10)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withValues(alpha: .10),
            ),
            child: Icon(Icons.login_rounded, color: primaryColor, size: 20),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.alreadyHaveAnAccountTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  loc.signInToAccessYourAccount,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.blueGrey),
                ),
              ],
            ),
          ),

          TextButton(
            onPressed: _openAuth,
            child: Text(
              loc.signIn,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================================
  // LOGOUT
  // =====================================================================

  Widget _buildLogoutButton(BuildContext context, AppLocalizations loc) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: .055),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.red.withValues(alpha: .08)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _logout(loc),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withValues(alpha: .09),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  size: 19,
                  color: Colors.red,
                ),
              ),

              const SizedBox(width: 13),

              Text(
                loc.logOut,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================================
  // FOOTER
  // =====================================================================

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        Image.asset('assets/images/splash12.png', width: 36, height: 36),

        const SizedBox(height: 6),

        Text(
          'Kipgo',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.blueGrey,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          AppLocalizations.of(context)!.travelMadeEasy,
          style: GoogleFonts.poppins(fontSize: 10, color: Colors.blueGrey),
        ),
      ],
    );
  }

  String _roleLabel(String? role, AppLocalizations loc) {
    switch (role) {
      case 'driver':
        return loc.driver;
      case 'rider':
      case 'customer':
        return loc.customer;
      case 'rental_admin':
        return loc.rentalOwner;
      default:
        return loc.kipgoMember;
    }
  }
}
