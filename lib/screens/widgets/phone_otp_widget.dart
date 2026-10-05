import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/profile.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/screens/widgets/error_message.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class PhoneOtpWidget extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final Profile profile;

  const PhoneOtpWidget({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
    required this.profile,
  });

  @override
  State<PhoneOtpWidget> createState() => _PhoneOtpWidgetState();
}

class _PhoneOtpWidgetState extends State<PhoneOtpWidget> {
  String otpCode = "";
  bool verifying = false;
  String? newId;

  String localError = '';

  Future<void> _verifyOtp() async {
    if (otpCode.length != 6 || verifying) return;

    FocusScope.of(context).unfocus();

    setState(() {
      verifying = true;
      localError = '';
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: newId ?? widget.verificationId,
        smsCode: otpCode,
      );

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No authenticated user was found.',
        );
      }

      final providers = user.providerData.map((e) => e.providerId);

      if (!providers.contains(PhoneAuthProvider.PROVIDER_ID)) {
        final userCred = await user.linkWithCredential(credential);

        final verifiedPhone = userCred.user?.phoneNumber;

        await FirebaseFirestore.instance
            .collection('profiles')
            .doc(widget.profile.id)
            .update({
              'personal.phone': verifiedPhone,
              'personal.isPhoneVerified': true,
            });
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        verifying = false;
        localError =
            e.message ?? AppLocalizations.of(context)!.phoneNumberInvalidError;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        verifying = false;
        localError = e.toString();
      });
    }
  }

  Future<void> _resendCode() async {
    if (verifying) return;

    FocusScope.of(context).unfocus();

    setState(() {
      localError = '';
      otpCode = '';
    });

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,

        codeAutoRetrievalTimeout: (_) {},

        codeSent: (String verificationId, int? forceResendingToken) {
          if (!mounted) return;

          setState(() {
            newId = verificationId;
            localError = '';
          });
        },

        verificationCompleted: (_) {},

        verificationFailed: (error) {
          if (!mounted) return;

          setState(() {
            localError = error.message ?? error.code;
          });
        },
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        localError = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDark = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    final backgroundColor = theme.scaffoldBackgroundColor;

    final cardColor = isDark ? AppColors.darkAccent : Colors.white;

    final mutedColor = isDark ? Colors.white60 : Colors.black54;

    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.primary,

      appBar: AppBarWidget(
        title: AppLocalizations.of(context)!.otp.toUpperCase(),
      ),

      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },

        child: Container(
          width: double.infinity,
          height: double.infinity,

          decoration: BoxDecoration(
            color: backgroundColor,

            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),

          child: SafeArea(
            top: false,

            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),

              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,

              padding: const EdgeInsets.fromLTRB(20, 28, 20, 35),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,

                children: [
                  // ─────────────────────────────
                  // VERIFICATION ICON
                  // ─────────────────────────────
                  Center(
                    child: Container(
                      width: 82,
                      height: 82,

                      decoration: BoxDecoration(
                        shape: BoxShape.circle,

                        color: AppColors.primary.withValues(
                          alpha: isDark ? 0.18 : 0.08,
                        ),
                      ),

                      child: Container(
                        margin: const EdgeInsets.all(9),

                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 18,
                              offset: const Offset(0, 7),
                            ),
                          ],
                        ),

                        child: const Icon(
                          Icons.phonelink_lock_rounded,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ─────────────────────────────
                  // TITLE
                  // ─────────────────────────────
                  Text(
                    AppLocalizations.of(context)!.otpVerification,
                    textAlign: TextAlign.center,

                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),

                  const SizedBox(height: 9),

                  Text(
                    AppLocalizations.of(
                      context,
                    )!.enterOtpCodeSent(widget.phoneNumber),

                    textAlign: TextAlign.center,

                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: mutedColor,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ─────────────────────────────
                  // PHONE NUMBER CARD
                  // ─────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),

                    decoration: BoxDecoration(
                      color: cardColor,

                      borderRadius: BorderRadius.circular(15),

                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.07)
                            : AppColors.border.withValues(alpha: 0.45),
                      ),
                    ),

                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,

                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(11),
                          ),

                          child: const Icon(
                            Icons.phone_rounded,
                            color: AppColors.primary,
                            size: 19,
                          ),
                        ),

                        const SizedBox(width: 11),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loc.verificationNumber,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: mutedColor,
                                ),
                              ),

                              const SizedBox(height: 2),

                              Text(
                                widget.phoneNumber,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Icon(
                          Icons.verified_user_outlined,
                          color: Colors.green,
                          size: 21,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ─────────────────────────────
                  // OTP LABEL
                  // ─────────────────────────────
                  Text(
                    loc.enterCode,
                    textAlign: TextAlign.center,

                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: mutedColor,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ─────────────────────────────
                  // OTP FIELDS
                  // ─────────────────────────────
                  OtpTextField(
                    numberOfFields: 6,

                    fieldWidth: MediaQuery.of(context).size.width > 500
                        ? 58
                        : (MediaQuery.of(context).size.width - 70) / 6,

                    fieldHeight: 58,

                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    borderColor: isDark ? Colors.white24 : AppColors.border,

                    focusedBorderColor: AppColors.primary,

                    borderWidth: 1.5,

                    // focusedBorderWidth: 2,
                    borderRadius: BorderRadius.circular(14),

                    showFieldAsBox: true,

                    textStyle: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 21,
                      color: isDark ? Colors.white : Colors.black87,
                    ),

                    onCodeChanged: (String code) {
                      setState(() {
                        otpCode = code;
                        localError = '';
                      });
                    },

                    onSubmit: (String code) {
                      otpCode = code;

                      if (otpCode.length == 6) {
                        _verifyOtp();
                      }
                    },
                  ),

                  const SizedBox(height: 12),

                  Text(
                    loc.sixDigitCode,
                    textAlign: TextAlign.center,

                    style: theme.textTheme.bodySmall?.copyWith(
                      color: mutedColor,
                    ),
                  ),

                  // ─────────────────────────────
                  // ERROR
                  // ─────────────────────────────
                  if (localError.isNotEmpty) ...[
                    const SizedBox(height: 18),

                    ErrorMessageWidget(localErrorMessage: localError),
                  ],

                  const SizedBox(height: 28),

                  // ─────────────────────────────
                  // VERIFY BUTTON
                  // ─────────────────────────────
                  SizedBox(
                    height: 56,

                    child: ElevatedButton(
                      onPressed: verifying || otpCode.length != 6
                          ? null
                          : _verifyOtp,

                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,

                        foregroundColor: Colors.white,

                        disabledBackgroundColor: AppColors.primary.withValues(
                          alpha: 0.35,
                        ),

                        disabledForegroundColor: Colors.white70,

                        elevation: verifying ? 0 : 4,

                        shadowColor: AppColors.primary.withValues(alpha: 0.28),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),

                      child: verifying
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 21,
                                  height: 21,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 11),

                                Text(
                                  AppLocalizations.of(context)!.pleaseWait,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.verified_rounded, size: 21),

                                const SizedBox(width: 9),

                                Text(
                                  AppLocalizations.of(context)!.verify,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 26),

                  // ─────────────────────────────
                  // RESEND SECTION
                  // ─────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(18),

                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.035)
                          : AppColors.primary.withValues(alpha: 0.035),

                      borderRadius: BorderRadius.circular(18),
                    ),

                    child: Column(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.didntReceiveOTPCode,

                          textAlign: TextAlign.center,

                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: mutedColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 5),

                        TextButton(
                          onPressed: verifying ? null : _resendCode,

                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,

                            disabledForegroundColor: AppColors.primary
                                .withValues(alpha: 0.35),

                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                          ),

                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.refresh_rounded, size: 19),

                              const SizedBox(width: 7),

                              Text(
                                AppLocalizations.of(context)!.resendCode,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ─────────────────────────────
                  // SECURITY NOTE
                  // ─────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 15,
                        color: mutedColor,
                      ),

                      const SizedBox(width: 6),

                      Text(
                        loc.yourVerificationCodeIsSecure,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: mutedColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// class PhoneOtpWidget extends StatefulWidget {
//   final String phoneNumber;
//   final String verificationId;
//   final Profile profile;
//   const PhoneOtpWidget({
//     super.key,
//     required this.phoneNumber,
//     required this.verificationId,
//     required this.profile,
//   });

//   @override
//   State<PhoneOtpWidget> createState() => _PhoneOtpWidgetState();
// }

// class _PhoneOtpWidgetState extends State<PhoneOtpWidget> {
//   String otpCode = "";
//   bool verifying = false;
//   String? newId;
//   String localError = '';

//   Future<void> _verifyOtp() async {
//     if (otpCode.length != 6) return;

//     setState(() => verifying = true);

//     try {
//       final credential = PhoneAuthProvider.credential(
//         verificationId: newId ?? widget.verificationId,
//         smsCode: otpCode,
//       );

//       final user = FirebaseAuth.instance.currentUser!;
//       final providers = user.providerData.map((e) => e.providerId);

//       if (!providers.contains(PhoneAuthProvider.PROVIDER_ID)) {
//         final userCred = await user.linkWithCredential(credential);
//         final verifiedPhone = userCred.user?.phoneNumber;
//         await FirebaseFirestore.instance
//             .collection('profiles')
//             .doc(widget.profile.id)
//             .update({
//               'personal.phone': verifiedPhone,
//               'personal.isPhoneVerified': true,
//             });
//       }

//       Navigator.pop(context, true); // success
//     } on FirebaseAuthException catch (e) {
//       setState(() {
//         verifying = false;
//         localError = e.message!;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.primary,
//       appBar: AppBarWidget(title: AppLocalizations.of(context)!.otp),
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
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Text(
//                     AppLocalizations.of(context)!.otpVerification,
//                     style: Theme.of(context).textTheme.headlineSmall!.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: 5),
//                   Text(
//                     AppLocalizations.of(
//                       context,
//                     )!.enterOtpCodeSent(widget.phoneNumber.toString()),
//                   ),
//                   SizedBox(height: 30),
//                   OtpTextField(
//                     numberOfFields: 6,
//                     fieldWidth: 50,
//                     // fieldHeight: 50,
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     borderColor: AppColors.primary,
//                     focusedBorderColor: AppColors.primary,
//                     borderRadius: BorderRadius.circular(8),
//                     showFieldAsBox: true,
//                     textStyle: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 20,
//                     ),
//                     onCodeChanged: (String code) {
//                       //handle validation or checks here
//                     },
//                     //runs when every textfield is filled
//                     onSubmit: (String code) {
//                       otpCode = code;
//                     }, // end onSubmit
//                   ),
//                   SizedBox(height: 30),

//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       minimumSize: Size.fromHeight(50),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       foregroundColor: Colors.white,
//                       backgroundColor: AppColors.primary,
//                       disabledBackgroundColor: Colors.grey,
//                     ),
//                     onPressed: verifying ? null : _verifyOtp,
//                     child: verifying
//                         ? CircularProgressIndicator(color: Colors.white)
//                         : Text(AppLocalizations.of(context)!.verify),
//                   ),
//                   if (localError != '') ...[
//                     SizedBox(height: 16),
//                     ErrorMessageWidget(localErrorMessage: localError),
//                   ],
//                   SizedBox(height: 30),
//                   Text(
//                     AppLocalizations.of(context)!.didntReceiveOTPCode,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.black38,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   TextButton(
//                     onPressed: () async {
//                       await FirebaseAuth.instance.verifyPhoneNumber(
//                         phoneNumber: widget.phoneNumber,
//                         codeAutoRetrievalTimeout: (_) {},
//                         codeSent: (newId, _) {
//                           setState(() {
//                             newId = newId;
//                             localError = '';
//                           });
//                         },
//                         verificationCompleted: (_) {},
//                         verificationFailed: (_) {},
//                       );
//                     },
//                     child: Text(AppLocalizations.of(context)!.resendCode),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
