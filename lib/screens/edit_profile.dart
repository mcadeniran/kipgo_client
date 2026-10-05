import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/screens/widgets/phone_otp_widget.dart';
import 'package:kipgo/screens/widgets/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/profile.dart';
import 'package:kipgo/screens/settings/edit_profile_picture_screen.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/screens/widgets/error_message.dart';
import 'package:kipgo/screens/widgets/input_decorator.dart';
import 'package:kipgo/screens/widgets/success_message_widget.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:recaptcha_enterprise_flutter/recaptcha.dart';
import 'package:recaptcha_enterprise_flutter/recaptcha_action.dart';
import 'package:recaptcha_enterprise_flutter/recaptcha_client.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final profileEditKey = GlobalKey<FormState>();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  late String photoUrl;
  late Profile profile;

  String initialCountry = 'TR';
  PhoneNumber number = PhoneNumber();

  bool isLoading = false;

  PhoneNumber? parsedPhoneNumber;
  PhoneNumber? initialPhone;

  String localError = '';
  String localSuccess = '';

  Future<void> updateProfile() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      localError = '';
      localSuccess = '';
    });

    try {
      final oldPhone = profile.personal.phone;
      final newPhone =
          parsedPhoneNumber?.phoneNumber ?? phoneController.text.trim();

      final phoneChanged = oldPhone.isNotEmpty && oldPhone != newPhone;

      if (phoneChanged) {
        await unlinkPhoneIfExists();
      }

      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(profile.id)
          .update({
            'account.isProfileCompleted': true,
            'personal.phone': newPhone,
            'personal.firstName': firstNameController.text.trim(),
            'personal.lastName': lastNameController.text.trim(),
            'personal.isPhoneVerified': phoneChanged
                ? false
                : profile.personal.isPhoneVerified,
          });

      if (!mounted) return;

      setState(() {
        localSuccess = AppLocalizations.of(context)!.profileUpdateSuccess;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        localError = '${AppLocalizations.of(context)!.profileUpdateFailure}$e';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> unlinkPhoneIfExists() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    for (final provider in user.providerData) {
      if (provider.providerId == PhoneAuthProvider.PROVIDER_ID) {
        await user.unlink(PhoneAuthProvider.PROVIDER_ID);

        debugPrint('📴 Old phone provider unlinked');
        break;
      }
    }
  }

  @override
  void initState() {
    super.initState();

    profile = Provider.of<ProfileProvider>(context, listen: false).profile!;

    firstNameController.text = profile.personal.firstName;
    lastNameController.text = profile.personal.lastName;
    phoneController.text = profile.personal.phone;

    photoUrl = profile.personal.photoUrl;

    number = PhoneNumber(phoneNumber: profile.personal.phone);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      if (profile.personal.phone.isNotEmpty) {
        try {
          final numb = await PhoneNumber.getRegionInfoFromPhoneNumber(
            profile.personal.phone,
          );

          if (!mounted) return;

          setState(() {
            initialPhone = PhoneNumber(
              isoCode: numb.isoCode,
              phoneNumber: profile.personal.phone,
            );
          });
        } catch (e) {
          debugPrint('Phone region parsing failed: $e');

          if (!mounted) return;

          setState(() {
            initialPhone = PhoneNumber(
              isoCode: 'TR',
              phoneNumber: profile.personal.phone,
            );
          });
        }
      } else {
        setState(() {
          initialPhone = PhoneNumber(isoCode: 'TR', phoneNumber: '');
        });
      }
    });
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();

    super.dispose();
  }

  Future<void> _openProfilePicture() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfilePictureScreen()),
    );

    if (!mounted) return;

    final updatedProfile = Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).profile;

    if (updatedProfile != null) {
      setState(() {
        profile = updatedProfile;
        photoUrl = updatedProfile.personal.photoUrl;
      });
    }
  }

  Future<void> _verifyPhone(BuildContext context, Profile profile) async {
    final userProvider = Provider.of<ProfileProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          ProgressDialog(message: AppLocalizations.of(context)!.pleaseWait),
    );

    setState(() {
      localError = '';
      localSuccess = '';
    });

    try {
      final siteKey = Platform.isAndroid
          ? '6LcSEVksAAAAAB3iC7dVERxfub7c-9zrMeXh72BA'
          : '6LfsFlksAAAAAFtmqSllV2AM5loygoimyWcCBfW3';

      final RecaptchaClient client = await Recaptcha.fetchClient(siteKey);

      debugPrint('SENDING OTP CODE');

      await client.execute(RecaptchaAction.LOGIN());

      await FirebaseAuth.instance.verifyPhoneNumber(
        codeAutoRetrievalTimeout: (e) {
          debugPrint('SMS TIMEOUT: $e');
        },
        phoneNumber: userProvider.profile!.personal.phone,
        codeSent: (verificationId, forceResendingToken) {
          debugPrint('SENT OTP CODE');

          if (!context.mounted) return;

          Navigator.pop(context);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PhoneOtpWidget(
                phoneNumber: userProvider.profile!.personal.phone,
                verificationId: verificationId,
                profile: profile,
              ),
            ),
          );
        },
        verificationCompleted: (_) {},
        verificationFailed: (error) {
          if (!context.mounted) return;

          Navigator.pop(context);

          setState(() {
            localError = error.code;
          });

          debugPrint(error.message);
        },
      );
    } catch (e) {
      if (!context.mounted) return;

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      setState(() {
        localError = e.toString();
      });

      debugPrint('Phone verification error: $e');
    }
  }

  InputDecoration _premiumInputDecoration({
    required BuildContext context,
    required String hint,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final isDark = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    return inputDecoration(context: context, hint: hint).copyWith(
      prefixIcon: Icon(
        icon,
        size: 21,
        color: isDark
            ? Colors.white70
            : AppColors.primary.withValues(alpha: 0.75),
      ),
      filled: true,
      fillColor: isDark
          ? AppColors.darkAccent.withValues(alpha: 0.45)
          : AppColors.lightAccent,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.border.withValues(alpha: isDark ? 0.45 : 0.75),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.border.withValues(alpha: isDark ? 0.45 : 0.75),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark ? Colors.tealAccent : AppColors.primary,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.redAccent.withValues(alpha: 0.8)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      hintStyle: TextStyle(color: theme.hintColor, fontSize: 14),
    );
  }

  Widget _sectionHeader({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    final isDark = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.lightLayer.withValues(alpha: 0.08)
                : AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: isDark ? AppColors.lightLayer : AppColors.primary,
            size: 21,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).textTheme.bodySmall?.color?.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _profileAvatar(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    final hasPhoto = profile.personal.photoUrl.isNotEmpty;

    return GestureDetector(
      onTap: _openProfilePicture,
      child: Hero(
        tag: 'avatarImageChange',
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 126,
              height: 126,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    isDark ? AppColors.lightLayer : AppColors.primary,
                    isDark ? AppColors.tertiary : AppColors.tertiary,
                  ],
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: ClipOval(
                  child: hasPhoto
                      ? Image.network(
                          profile.personal.photoUrl,
                          width: 116,
                          height: 116,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) {
                              return child;
                            }

                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/image_not_found.png',
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Image.asset(
                          'assets/images/avatar.png',
                          width: 116,
                          height: 116,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),

            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                    color: Colors.black.withValues(alpha: 0.20),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _verificationBadge({
    required BuildContext context,
    required bool verified,
  }) {
    final isDark = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    final loc = AppLocalizations.of(context)!;

    final Color color = verified ? Colors.green : Colors.amber.shade700;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.16 : 0.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            verified ? Icons.verified_rounded : Icons.warning_amber_rounded,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            verified ? loc.verified : loc.notVerified,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({required BuildContext context, required Widget child}) {
    final isDark = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkAccent : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : AppColors.border.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.045),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDark = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    final profileProvider = Provider.of<ProfileProvider>(context);

    final currentProfile = profileProvider.profile ?? profile;

    final hasPhone = currentProfile.personal.phone.isNotEmpty;

    final phoneVerified = currentProfile.personal.isPhoneVerified;

    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBarWidget(
        title: AppLocalizations.of(context)!.editProfile.toUpperCase(),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 22, 12, 32),
              child: Form(
                key: profileEditKey,
                autovalidateMode: AutovalidateMode.onUnfocus,
                child: Column(
                  children: [
                    // ─────────────────────────────
                    // PROFILE HEADER
                    // ─────────────────────────────
                    _profileAvatar(context),

                    const SizedBox(height: 14),

                    Text(
                      '${firstNameController.text} ${lastNameController.text}'
                          .trim(),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      AppLocalizations.of(context)!.editProfile,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withValues(
                          alpha: 0.60,
                        ),
                      ),
                    ),

                    const SizedBox(height: 26),

                    // ─────────────────────────────
                    // PERSONAL INFORMATION
                    // ─────────────────────────────
                    _infoCard(
                      context: context,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionHeader(
                            context: context,
                            icon: Icons.person_outline_rounded,
                            title: loc.personalInfo,
                            subtitle: loc.keepYourProfileDetails,
                          ),

                          const SizedBox(height: 20),

                          TextFormField(
                            controller: firstNameController,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.text,
                            maxLines: 1,
                            decoration: _premiumInputDecoration(
                              context: context,
                              hint: AppLocalizations.of(context)!.firstName,
                              icon: Icons.person_outline_rounded,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return AppLocalizations.of(
                                  context,
                                )!.firstNameRequiredError;
                              }

                              if (value.trim().length < 2) {
                                return AppLocalizations.of(
                                  context,
                                )!.firstNameLengthError;
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          TextFormField(
                            controller: lastNameController,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.text,
                            maxLines: 1,
                            decoration: _premiumInputDecoration(
                              context: context,
                              hint: AppLocalizations.of(context)!.surname,
                              icon: Icons.badge_outlined,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return AppLocalizations.of(
                                  context,
                                )!.lastNameRequiredError;
                              }

                              if (value.trim().length < 2) {
                                return AppLocalizations.of(
                                  context,
                                )!.lastNameLengthError;
                              }

                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ─────────────────────────────
                    // PHONE INFORMATION
                    // ─────────────────────────────
                    _infoCard(
                      context: context,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionHeader(
                            context: context,
                            icon: Icons.phone_outlined,
                            title: loc.phoneNumber,
                            subtitle: loc.forAccountVerification,
                          ),

                          const SizedBox(height: 18),

                          initialPhone == null
                              ? const Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : InternationalPhoneNumberInput(
                                  onInputChanged: (PhoneNumber number) {
                                    parsedPhoneNumber = number;
                                  },
                                  onInputValidated: (bool isValid) {},
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return AppLocalizations.of(
                                        context,
                                      )!.phoneNumberRequiredError;
                                    }

                                    if (value.length < 10) {
                                      return AppLocalizations.of(
                                        context,
                                      )!.phoneNumberInvalidError;
                                    }

                                    return null;
                                  },
                                  selectorConfig: const SelectorConfig(
                                    selectorType:
                                        PhoneInputSelectorType.BOTTOM_SHEET,
                                    useBottomSheetSafeArea: true,
                                    setSelectorButtonAsPrefixIcon: true,
                                    useEmoji: true,
                                    leadingPadding: 10,
                                  ),
                                  ignoreBlank: false,
                                  autoValidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  initialValue: initialPhone,
                                  textFieldController: phoneController,
                                  formatInput: true,
                                  keyboardType: TextInputType.phone,
                                  inputDecoration: _premiumInputDecoration(
                                    context: context,
                                    hint: AppLocalizations.of(context)!.phone,
                                    icon: Icons.phone_rounded,
                                  ),
                                  onSaved: (PhoneNumber number) {
                                    parsedPhoneNumber = number;
                                  },
                                  spaceBetweenSelectorAndTextField: 0,
                                ),

                          if (hasPhone) ...[
                            const SizedBox(height: 14),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                _verificationBadge(
                                  context: context,
                                  verified: phoneVerified,
                                ),
                              ],
                            ),

                            if (!phoneVerified)
                              Center(
                                child: TextButton.icon(
                                  onPressed: () =>
                                      _verifyPhone(context, currentProfile),
                                  icon: const Icon(
                                    Icons.verified_user_outlined,
                                    size: 17,
                                  ),
                                  label: Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.verifyPhoneNumber,
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: isDark
                                        ? Colors.tealAccent
                                        : AppColors.primary,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                  ),
                                ),
                              ),

                            if (phoneVerified) ...[
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(11),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.035)
                                      : AppColors.primary.withValues(
                                          alpha: 0.035,
                                        ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.info_outline_rounded,
                                      size: 16,
                                      color: theme.textTheme.bodySmall?.color
                                          ?.withValues(alpha: 0.55),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.changingYourPhoneNumber,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              fontStyle: FontStyle.italic,
                                              color: theme
                                                  .textTheme
                                                  .bodySmall
                                                  ?.color
                                                  ?.withValues(alpha: 0.60),
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),

                    // ─────────────────────────────
                    // FEEDBACK
                    // ─────────────────────────────
                    if (localError.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      ErrorMessageWidget(localErrorMessage: localError),
                    ],

                    if (localSuccess.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      SuccessMessageWidget(successMessage: localSuccess),
                    ],

                    const SizedBox(height: 24),

                    // ─────────────────────────────
                    // UPDATE BUTTON
                    // ─────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                FocusScope.of(context).unfocus();

                                if (profileEditKey.currentState!.validate()) {
                                  profileEditKey.currentState!.save();

                                  updateProfile();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.primary.withValues(
                            alpha: 0.45,
                          ),
                          disabledForegroundColor: Colors.white70,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: isLoading
                              ? const SizedBox(
                                  key: ValueKey('loading'),
                                  width: 23,
                                  height: 23,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Row(
                                  key: const ValueKey('button'),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.check_circle_outline_rounded,
                                      size: 21,
                                    ),
                                    const SizedBox(width: 9),
                                    Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.updateProfile,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// class EditProfileScreen extends StatefulWidget {
//   const EditProfileScreen({super.key});

//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<EditProfileScreen> {
//   final profileEditKey = GlobalKey<FormState>();
//   TextEditingController firstNameController = TextEditingController();
//   TextEditingController lastNameController = TextEditingController();
//   TextEditingController phoneController = TextEditingController();
//   late String photoUrl;
//   late Profile profile;
//   String initialCountry = 'TR';
//   PhoneNumber number = PhoneNumber();
//   bool isLoading = false;
//   PhoneNumber? parsedPhoneNumber;
//   PhoneNumber? initialPhone;

//   String localError = '';
//   String localSuccess = '';

//   Future<void> updateProfile() async {
//     setState(() {
//       isLoading = true;
//       localError = '';
//       localSuccess = '';
//     });

//     try {
//       final oldPhone = profile.personal.phone;
//       final newPhone = parsedPhoneNumber?.phoneNumber ?? phoneController.text;

//       final phoneChanged = oldPhone.isNotEmpty && oldPhone != newPhone;

//       if (phoneChanged) {
//         // 🔥 unlink old phone auth
//         await unlinkPhoneIfExists();
//       }

//       await FirebaseFirestore.instance
//           .collection('profiles')
//           .doc(profile.id)
//           .update({
//             'account.isProfileCompleted': true,
//             'personal.phone': newPhone,
//             'personal.firstName': firstNameController.text,
//             'personal.lastName': lastNameController.text,
//             'personal.isPhoneVerified': phoneChanged
//                 ? false
//                 : profile.personal.isPhoneVerified,
//           });
//       setState(() {
//         localSuccess = AppLocalizations.of(context)!.profileUpdateSuccess;
//       });
//     } catch (e) {
//       setState(() {
//         localError = '${AppLocalizations.of(context)!.profileUpdateFailure}$e';
//       });
//     } finally {
//       if (context.mounted) {
//         setState(() => isLoading = false);
//       }
//     }
//   }

//   Future<void> unlinkPhoneIfExists() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return;

//     for (final provider in user.providerData) {
//       if (provider.providerId == PhoneAuthProvider.PROVIDER_ID) {
//         await user.unlink(PhoneAuthProvider.PROVIDER_ID);
//         debugPrint("📴 Old phone provider unlinked");
//         break;
//       }
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     profile = Provider.of<ProfileProvider>(context, listen: false).profile!;

//     firstNameController.text = profile.personal.firstName;
//     lastNameController.text = profile.personal.lastName;
//     phoneController.text = profile.personal.phone;
//     photoUrl = profile.personal.photoUrl;
//     number = PhoneNumber(phoneNumber: profile.personal.phone);

//     // final e164 = profile.personal.phone;
//     // initialPhone = PhoneNumber(
//     //   isoCode: 'TR',
//     //   phoneNumber: profile.personal.phone,
//     // );
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       if (profile.personal.phone != '') {
//         PhoneNumber numb = await PhoneNumber.getRegionInfoFromPhoneNumber(
//           profile.personal.phone,
//         );

//         setState(() {
//           initialPhone = PhoneNumber(
//             isoCode: numb.isoCode,
//             phoneNumber: profile.personal.phone,
//           );
//         });
//       } else {
//         setState(() {
//           initialPhone = PhoneNumber(
//             isoCode: 'TR',
//             phoneNumber: profile.personal.phone,
//           );
//         });
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     bool isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
//     return Scaffold(
//       backgroundColor: AppColors.primary,
//       appBar: AppBarWidget(
//         title: AppLocalizations.of(context)!.editProfile.toUpperCase(),
//       ),
//       body: GestureDetector(
//         onTap: () {
//           FocusScopeNode currentFocus = FocusScope.of(context);
//           if (!currentFocus.hasPrimaryFocus) {
//             currentFocus.unfocus();
//           }
//         },
//         child: Container(
//           width: double.maxFinite,
//           height: double.maxFinite,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(20),
//               topRight: Radius.circular(20),
//             ),
//             color: Theme.of(context).scaffoldBackgroundColor,
//           ),
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(12),
//             keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
//             child: Column(
//               children: [
//                 SizedBox(height: 20),
//                 Center(
//                   child: Stack(
//                     children: [
//                       Hero(
//                         tag: 'avatarImageChange',
//                         child: ClipOval(
//                           child: Material(
//                             color: Colors.transparent,
//                             child: profile.personal.photoUrl == ''
//                                 ? Ink.image(
//                                     image: const AssetImage(
//                                       'assets/images/avatar.png',
//                                     ),
//                                     fit: BoxFit.cover,
//                                     width: 120,
//                                     height: 120,
//                                     child: InkWell(
//                                       onTap: () {
//                                         Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (_) =>
//                                                 const EditProfilePictureScreen(),
//                                           ),
//                                         );
//                                       },
//                                     ),
//                                   )
//                                 : SizedBox(
//                                     // image: NetworkImage(photoUrl),
//                                     // fit: BoxFit.cover,
//                                     width: 120,
//                                     height: 120,
//                                     child: InkWell(
//                                       onTap: () {
//                                         Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                             builder: (_) =>
//                                                 const EditProfilePictureScreen(),
//                                           ),
//                                         );
//                                       },
//                                       child: Image.network(
//                                         profile.personal.photoUrl,
//                                         fit: BoxFit.cover,
//                                         loadingBuilder:
//                                             (context, child, progress) {
//                                               if (progress == null) {
//                                                 return child;
//                                               }
//                                               return const Center(
//                                                 child:
//                                                     CircularProgressIndicator(),
//                                               );
//                                             },
//                                         errorBuilder:
//                                             (
//                                               context,
//                                               error,
//                                               stackTrace,
//                                             ) => Image.asset(
//                                               'assets/images/image_not_found.png',
//                                               fit: BoxFit.cover,
//                                             ),
//                                       ),
//                                     ),
//                                   ),
//                           ),
//                         ),
//                       ),
//                       Positioned(
//                         bottom: 0,
//                         right: 4,
//                         child: ClipOval(
//                           child: Container(
//                             color: Colors.white,
//                             padding: const EdgeInsets.all(3),
//                             child: ClipOval(
//                               child: Container(
//                                 padding: const EdgeInsets.all(8),
//                                 color: AppColors.primary,
//                                 child: InkWell(
//                                   onTap: () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (_) =>
//                                             const EditProfilePictureScreen(),
//                                       ),
//                                     );
//                                   },
//                                   child: const Icon(
//                                     Icons.edit,
//                                     color: Colors.white,
//                                     size: 20,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 Form(
//                   key: profileEditKey,
//                   autovalidateMode: AutovalidateMode.onUnfocus,
//                   child: Column(
//                     children: [
//                       TextFormField(
//                         controller: firstNameController,
//                         enableInteractiveSelection: true,
//                         textInputAction: TextInputAction.next,
//                         minLines: 1,
//                         keyboardType: TextInputType.text,
//                         maxLines: 1,
//                         decoration: inputDecoration(
//                           context: context,
//                           hint: AppLocalizations.of(context)!.firstName,
//                         ),
//                         validator: (value) {
//                           if (value == '') {
//                             return AppLocalizations.of(
//                               context,
//                             )!.firstNameRequiredError;
//                           } else if (value != null && value.length < 2) {
//                             return AppLocalizations.of(
//                               context,
//                             )!.firstNameLengthError;
//                           } else {
//                             return null;
//                           }
//                         },
//                       ),
//                       SizedBox(height: 16),
//                       TextFormField(
//                         controller: lastNameController,
//                         enableInteractiveSelection: true,
//                         textInputAction: TextInputAction.next,
//                         minLines: 1,
//                         keyboardType: TextInputType.text,
//                         maxLines: 1,
//                         decoration: inputDecoration(
//                           context: context,
//                           hint: AppLocalizations.of(context)!.surname,
//                         ),
//                         validator: (value) {
//                           if (value == '') {
//                             return AppLocalizations.of(
//                               context,
//                             )!.lastNameRequiredError;
//                           } else if (value != null && value.length < 2) {
//                             return AppLocalizations.of(
//                               context,
//                             )!.lastNameLengthError;
//                           } else {
//                             return null;
//                           }
//                         },
//                       ),
//                       SizedBox(height: 16),
//                       initialPhone == null
//                           ? const CircularProgressIndicator() // while parsing
//                           : Consumer<ProfileProvider>(
//                               builder: (context, userProvider, _) {
//                                 return Column(
//                                   children: [
//                                     Row(
//                                       // mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         SizedBox(
//                                           width:
//                                               userProvider
//                                                       .profile!
//                                                       .personal
//                                                       .phone ==
//                                                   ''
//                                               ? MediaQuery.of(
//                                                           context,
//                                                         ).size.width *
//                                                         1 -
//                                                     24
//                                               : MediaQuery.of(
//                                                       context,
//                                                     ).size.width *
//                                                     0.8,
//                                           child: InternationalPhoneNumberInput(
//                                             onInputChanged: (PhoneNumber number) {
//                                               parsedPhoneNumber =
//                                                   number; // ✅ save latest parsed phone number
//                                             },
//                                             onInputValidated: (bool isValid) {
//                                               // print("Is valid: $isValid");
//                                             },
//                                             validator: (value) {
//                                               if (value == null ||
//                                                   value.isEmpty) {
//                                                 return AppLocalizations.of(
//                                                   context,
//                                                 )!.phoneNumberRequiredError;
//                                               }
//                                               if (value.length < 10) {
//                                                 return AppLocalizations.of(
//                                                   context,
//                                                 )!.phoneNumberInvalidError;
//                                               }
//                                               return null;
//                                             },
//                                             selectorConfig: SelectorConfig(
//                                               selectorType:
//                                                   PhoneInputSelectorType
//                                                       .BOTTOM_SHEET,
//                                               useBottomSheetSafeArea: true,
//                                               setSelectorButtonAsPrefixIcon:
//                                                   true,
//                                               useEmoji: true,
//                                               leadingPadding: 10,
//                                             ),
//                                             ignoreBlank: false,
//                                             autoValidateMode: AutovalidateMode
//                                                 .onUserInteraction,
//                                             initialValue: initialPhone,
//                                             textFieldController:
//                                                 phoneController,
//                                             formatInput: true,
//                                             keyboardType: TextInputType.phone,
//                                             inputDecoration: inputDecoration(
//                                               context: context,
//                                               hint: AppLocalizations.of(
//                                                 context,
//                                               )!.phone,
//                                             ),
//                                             onSaved: (PhoneNumber number) {
//                                               parsedPhoneNumber = number;
//                                             },
//                                             spaceBetweenSelectorAndTextField: 0,
//                                           ),
//                                         ),
//                                         if (userProvider
//                                                 .profile!
//                                                 .personal
//                                                 .phone !=
//                                             '') ...[
//                                           SizedBox(width: 5),
//                                           if (userProvider
//                                               .profile!
//                                               .personal
//                                               .isPhoneVerified) ...[
//                                             IconButton(
//                                               onPressed: () {},
//                                               icon: Iconify(
//                                                 Ic.baseline_verified,
//                                                 color: Colors.green[800],
//                                                 size: 28,
//                                               ),
//                                             ),
//                                           ],
//                                           if (!userProvider
//                                               .profile!
//                                               .personal
//                                               .isPhoneVerified) ...[
//                                             IconButton(
//                                               onPressed: () {},
//                                               icon: Iconify(
//                                                 Mdi.alert_octagram,
//                                                 color: Colors.amber[800],
//                                                 size: 28,
//                                               ),
//                                             ),
//                                           ],
//                                         ],
//                                       ],
//                                     ),
//                                     if (userProvider.profile!.personal.phone !=
//                                             '' &&
//                                         userProvider
//                                             .profile!
//                                             .personal
//                                             .isPhoneVerified) ...[
//                                       SizedBox(height: 5),
//                                       Align(
//                                         alignment: Alignment.centerRight,
//                                         child: Text(
//                                           AppLocalizations.of(
//                                             context,
//                                           )!.changingYourPhoneNumber,
//                                           style: TextStyle(
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.bold,
//                                             fontStyle: FontStyle.italic,
//                                             color: isDark
//                                                 ? Colors.white54
//                                                 : Colors.black45,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                     if (userProvider.profile!.personal.phone !=
//                                             '' &&
//                                         !userProvider
//                                             .profile!
//                                             .personal
//                                             .isPhoneVerified) ...[
//                                       // SizedBox(height: 10),
//                                       Align(
//                                         alignment: Alignment.centerRight,
//                                         child: TextButton(
//                                           onPressed: () async {
//                                             showDialog(
//                                               context: context,
//                                               builder:
//                                                   ((BuildContext context) =>
//                                                       ProgressDialog(
//                                                         message:
//                                                             AppLocalizations.of(
//                                                               context,
//                                                             )!.pleaseWait,
//                                                       )),
//                                             );
//                                             setState(() {
//                                               localError = '';
//                                               localSuccess = '';
//                                             });
//                                             final siteKey = Platform.isAndroid
//                                                 ? "6LcSEVksAAAAAB3iC7dVERxfub7c-9zrMeXh72BA"
//                                                 : "6LfsFlksAAAAAFtmqSllV2AM5loygoimyWcCBfW3";

//                                             RecaptchaClient client =
//                                                 await Recaptcha.fetchClient(
//                                                   siteKey,
//                                                 );
//                                             debugPrint("SENDING OTP CODE");
//                                             await client.execute(
//                                               RecaptchaAction.LOGIN(),
//                                             );
//                                             await FirebaseAuth.instance.verifyPhoneNumber(
//                                               codeAutoRetrievalTimeout: (e) {
//                                                 debugPrint("SMS TIMEOUT: $e");
//                                               },
//                                               phoneNumber: userProvider
//                                                   .profile!
//                                                   .personal
//                                                   .phone,
//                                               codeSent:
//                                                   (
//                                                     verificationId,
//                                                     forceResendingToken,
//                                                   ) {
//                                                     debugPrint("SENT OTP CODE");
//                                                     Navigator.pop(context);
//                                                     Navigator.push(
//                                                       context,
//                                                       MaterialPageRoute(
//                                                         builder: (_) =>
//                                                             PhoneOtpWidget(
//                                                               phoneNumber:
//                                                                   userProvider
//                                                                       .profile!
//                                                                       .personal
//                                                                       .phone,
//                                                               verificationId:
//                                                                   verificationId,
//                                                               profile: profile,
//                                                             ),
//                                                       ),
//                                                     );
//                                                   },
//                                               verificationCompleted: (_) {},
//                                               verificationFailed: (error) {
//                                                 Navigator.pop(context);
//                                                 // throw Exception(error.message);
//                                                 setState(() {
//                                                   localError = error.code;
//                                                 });
//                                                 debugPrint(error.message);
//                                               },
//                                             );
//                                           },
//                                           child: Text(
//                                             AppLocalizations.of(
//                                               context,
//                                             )!.verifyPhoneNumber,
//                                             style: TextStyle(
//                                               decoration:
//                                                   TextDecoration.underline,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ],
//                                 );
//                               },
//                             ),
//                       if (localError != '') ...[
//                         SizedBox(height: 16),
//                         ErrorMessageWidget(localErrorMessage: localError),
//                       ],
//                       if (localSuccess != '') ...[
//                         SizedBox(height: 16),
//                         SuccessMessageWidget(successMessage: localSuccess),
//                       ],
//                       SizedBox(height: 26),
//                       ElevatedButton(
//                         onPressed: isLoading
//                             ? null
//                             : () {
//                                 if (profileEditKey.currentState!.validate()) {
//                                   profileEditKey.currentState!
//                                       .save(); // ensures phone is saved
//                                   updateProfile();
//                                 }
//                               },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppColors.primary,
//                           foregroundColor: Colors.white,
//                           disabledBackgroundColor: AppColors.primary.withValues(
//                             alpha: 0.5,
//                           ),
//                           disabledForegroundColor: Colors.white54,
//                           minimumSize: const Size.fromHeight(50),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         child: Text(
//                           AppLocalizations.of(context)!.updateProfile,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
