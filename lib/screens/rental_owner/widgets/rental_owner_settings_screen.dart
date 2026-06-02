import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/carbon.dart';
import 'package:kipgo/controllers/auth_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/settings/terms_and_conditions_screen.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/screens/widgets/change_theme_button_widget.dart';
import 'package:kipgo/screens/widgets/language_picker_widget.dart';
import 'package:kipgo/screens/widgets/setting_widget.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class RentalOwnerSettingsScreen extends StatelessWidget {
  const RentalOwnerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    void logout() async {
      Provider.of<AuthProvider>(context, listen: false).logout(context);
    }

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBarWidget(
        title: AppLocalizations.of(context)!.settings.toUpperCase(),
        showLanguage: false,
      ),
      body: Container(
        clipBehavior: Clip.hardEdge,
        padding: const EdgeInsets.all(12),
        height: double.maxFinite,
        width: double.maxFinite,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Consumer<AuthProvider>(
          builder: (context, rs, _) {
            bool isActive = rs.rentalShop!.isActive;
            return rs.isLoading
                ? Center(
                    child: Center(child: CircularProgressIndicator.adaptive()),
                  )
                : rs.rentalShop == null
                ? Center(
                    child: Text(AppLocalizations.of(context)!.profileNotFound),
                  )
                : ListView(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        margin: const EdgeInsets.only(top: 18),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkAccent
                              : Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor: isDark
                                      ? AppColors.darkLayer
                                      : AppColors.primary,
                                  child: CircleAvatar(
                                    radius: 38,
                                    backgroundColor: Theme.of(
                                      context,
                                    ).scaffoldBackgroundColor,
                                    child: Container(
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      width: 68,
                                      height: 68,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: rs.rentalShop!.logo == ''
                                          ? Image.asset(
                                              'assets/images/avatar.png',
                                              fit: BoxFit.cover,
                                            )
                                          : Image.network(
                                              rs.rentalShop!.logo,
                                              fit: BoxFit.cover,
                                              loadingBuilder:
                                                  (context, child, progress) {
                                                    if (progress == null) {
                                                      return child;
                                                    }
                                                    return const Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    );
                                                  },
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Image.asset(
                                                    'assets/images/image_not_found.png',
                                                    fit: BoxFit.cover,
                                                  ),
                                            ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      rs.rentalShop!.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    Text(
                                      rs.rentalShop!.email,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                    SizedBox(height: 8),
                                    Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: isActive
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        color: isActive
                                            ? Colors.green.withValues(
                                                alpha: 0.2,
                                              )
                                            : Colors.red.withValues(alpha: 0.2),
                                      ),
                                      child: Text(
                                        rs.rentalShop!.isActive
                                            ? AppLocalizations.of(
                                                context,
                                              )!.active
                                            : AppLocalizations.of(
                                                context,
                                              )!.hidden,
                                        style: TextStyle(
                                          color: isActive
                                              ? Colors.green
                                              : Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        AppLocalizations.of(context)!.appTitle,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkAccent
                              : Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,

                              children: [
                                Row(
                                  children: [
                                    Iconify(
                                      Carbon.ibm_watson_language_translator,
                                      color: Theme.of(context).iconTheme.color,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.changeLanguage,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                                LanguagePickerWidget(),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,

                              children: [
                                Row(
                                  children: [
                                    Icon(CupertinoIcons.moon_stars, size: 18),
                                    const SizedBox(width: 12),
                                    Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.enableDarkMode,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                                ChangeThemeButtonWidget(),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        AppLocalizations.of(context)!.supportTitle,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkAccent
                              : Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            SettingWidget(
                              title: AppLocalizations.of(
                                context,
                              )!.termsAndConditions,
                              icon: Icons.article,
                              page: const TermsAndConditionsScreen(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkAccent
                              : Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: logout,
                          child: Row(
                            children: [
                              Icon(
                                Icons.login_outlined,
                                color: Colors.red,
                                size: 18,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                AppLocalizations.of(context)!.logOut,
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }
}
