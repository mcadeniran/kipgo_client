import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/auth/main_app_bottom_navigation.dart';
import 'package:kipgo/screens/widgets/change_language_mini_widget.dart';
import 'package:kipgo/screens/widgets/error_message.dart';
import 'package:kipgo/services/role_based_auth_gate.dart';
import 'package:kipgo/utils/colors.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isEmailVerified = false;

  String? error;

  Timer? timer;
  Timer? resendTimer;

  String email = '';

  bool canResendEmail = false;
  bool isCheckingVerification = false;
  bool isSendingEmail = false;

  int resendCountdown = 10;

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    isEmailVerified = user.emailVerified;
    email = user.email ?? '';

    if (!isEmailVerified) {
      sendVerificationEmail();

      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    resendTimer?.cancel();
    super.dispose();
  }

  // --------------------------------------------------------------------------
  // Send verification email
  // --------------------------------------------------------------------------
  Future<void> sendVerificationEmail() async {
    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    if (isSendingEmail) {
      return;
    }

    setState(() {
      isSendingEmail = true;
      canResendEmail = false;
      resendCountdown = 10;
      error = null;
    });

    try {
      await user.sendEmailVerification();

      if (!mounted) return;

      setState(() {
        isSendingEmail = false;
        canResendEmail = false;
        resendCountdown = 10;
      });

      startResendCountdown();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        isSendingEmail = false;
        canResendEmail = false;
        error = e.message ?? e.toString();
      });

      startResendCountdown();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSendingEmail = false;
        canResendEmail = false;
        error = e.toString().replaceFirst('Exception: ', '');
      });

      startResendCountdown();
    }
  }

  // --------------------------------------------------------------------------
  // Resend countdown
  // --------------------------------------------------------------------------
  void startResendCountdown() {
    resendTimer?.cancel();

    if (!mounted) return;

    setState(() {
      resendCountdown = 10;
      canResendEmail = false;
    });

    resendTimer = Timer.periodic(const Duration(seconds: 1), (countdownTimer) {
      if (!mounted) {
        countdownTimer.cancel();
        return;
      }

      if (resendCountdown <= 1) {
        countdownTimer.cancel();

        setState(() {
          resendCountdown = 0;
          canResendEmail = true;
        });
      } else {
        setState(() {
          resendCountdown--;
        });
      }
    });
  }

  // --------------------------------------------------------------------------
  // Check whether the user has verified their email
  // --------------------------------------------------------------------------
  Future<void> checkEmailVerified() async {
    if (!mounted || isCheckingVerification) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      timer?.cancel();
      return;
    }

    try {
      isCheckingVerification = true;

      await user.reload();

      final refreshedUser = FirebaseAuth.instance.currentUser;

      if (refreshedUser == null) {
        return;
      }

      final verified = refreshedUser.emailVerified;

      if (!mounted) return;

      if (verified) {
        timer?.cancel();
        resendTimer?.cancel();

        setState(() {
          isEmailVerified = true;
          isCheckingVerification = false;
        });
      } else {
        isCheckingVerification = false;
      }
    } catch (e) {
      if (!mounted) return;

      isCheckingVerification = false;

      setState(() {
        error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // --------------------------------------------------------------------------
  // Manual verification check
  // --------------------------------------------------------------------------
  Future<void> manuallyCheckVerification() async {
    if (isCheckingVerification) {
      return;
    }

    setState(() {
      error = null;
      isCheckingVerification = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        if (!mounted) return;

        setState(() {
          isCheckingVerification = false;
          error = 'Unable to find your account.';
        });

        return;
      }

      await user.reload();

      final refreshedUser = FirebaseAuth.instance.currentUser;

      if (!mounted) return;

      if (refreshedUser?.emailVerified == true) {
        timer?.cancel();
        resendTimer?.cancel();

        setState(() {
          isEmailVerified = true;
          isCheckingVerification = false;
        });
      } else {
        setState(() {
          isCheckingVerification = false;
          error = AppLocalizations.of(context)!.pleaseVerifyYourEmail;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isCheckingVerification = false;
        error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // --------------------------------------------------------------------------
  // Sign out
  // --------------------------------------------------------------------------
  Future<void> cancelVerification() async {
    timer?.cancel();
    resendTimer?.cancel();

    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainAppBottomNavigation()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (isEmailVerified) {
      return const RoleBasedAuthGate();
    }

    return Scaffold(
      backgroundColor: AppColors.primary,

      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },

          child: Stack(
            children: [
              // ----------------------------------------------------------------
              // Decorative background
              // ----------------------------------------------------------------
              Positioned(
                top: -100,
                right: -80,
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),

              Positioned(
                bottom: -120,
                left: -100,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.secondary.withValues(alpha: 0.10),
                  ),
                ),
              ),

              // ----------------------------------------------------------------
              // Main content
              // ----------------------------------------------------------------
              SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,

                padding: const EdgeInsets.only(bottom: 24),

                child: Column(
                  children: [
                    // ----------------------------------------------------------------
                    // Top bar
                    // ----------------------------------------------------------------
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),

                      child: Row(
                        children: [
                          Material(
                            color: Colors.white.withValues(alpha: 0.12),
                            shape: const CircleBorder(),

                            child: InkWell(
                              customBorder: const CircleBorder(),

                              onTap: cancelVerification,

                              child: const SizedBox(
                                width: 44,
                                height: 44,

                                child: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ----------------------------------------------------------------
                    // Logo
                    // ----------------------------------------------------------------
                    Hero(
                          tag: 'AuthLogo',

                          child: Image.asset(
                            'assets/images/kipgo_transparent.png',
                            height: 48,
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .scale(
                          begin: const Offset(0.85, 0.85),
                          end: const Offset(1, 1),
                          duration: 500.ms,
                        ),

                    const SizedBox(height: 22),

                    // ----------------------------------------------------------------
                    // Page title
                    // ----------------------------------------------------------------
                    Text(
                          l10n.verifyEmail.toUpperCase(),

                          textAlign: TextAlign.center,

                          style: GoogleFonts.poppins(
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                            color: Colors.white,
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 100.ms)
                        .slideY(begin: 0.15, end: 0, duration: 500.ms),

                    const SizedBox(height: 8),

                    Text(
                      l10n.pleaseVerifyYourEmail,

                      textAlign: TextAlign.center,

                      style: GoogleFonts.openSans(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.75),
                        height: 1.5,
                      ),
                    ).animate().fadeIn(duration: 500.ms, delay: 150.ms),

                    const SizedBox(height: 30),

                    // ----------------------------------------------------------------
                    // Verification card
                    // ----------------------------------------------------------------
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),

                      padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(24),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.16),
                            blurRadius: 30,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,

                        children: [
                          // --------------------------------------------------------
                          // Email icon
                          // --------------------------------------------------------
                          Center(
                                child: Container(
                                  width: 76,
                                  height: 76,

                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.08,
                                    ),
                                    shape: BoxShape.circle,
                                  ),

                                  child: Stack(
                                    alignment: Alignment.center,

                                    children: [
                                      Icon(
                                        Icons.mark_email_unread_outlined,
                                        color: AppColors.primary,
                                        size: 38,
                                      ),

                                      Positioned(
                                        right: 13,
                                        top: 11,

                                        child: Container(
                                          width: 15,
                                          height: 15,

                                          decoration: const BoxDecoration(
                                            color: AppColors.secondary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .animate()
                              .fadeIn(duration: 400.ms)
                              .scale(
                                begin: const Offset(0.8, 0.8),
                                end: const Offset(1, 1),
                              ),

                          const SizedBox(height: 22),

                          // --------------------------------------------------------
                          // Heading
                          // --------------------------------------------------------
                          Text(
                            l10n.verifyYourEmail,

                            textAlign: TextAlign.center,

                            style: GoogleFonts.poppins(
                              fontSize: 21,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkAccent,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            l10n.verificationEmailSent(email),

                            textAlign: TextAlign.center,

                            style: GoogleFonts.openSans(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              height: 1.6,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // --------------------------------------------------------
                          // Email pill
                          // --------------------------------------------------------
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),

                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.06),

                              borderRadius: BorderRadius.circular(12),

                              border: Border.all(
                                color: AppColors.primary.withValues(
                                  alpha: 0.10,
                                ),
                              ),
                            ),

                            child: Row(
                              children: [
                                Icon(
                                  Icons.email_outlined,
                                  size: 19,
                                  color: AppColors.primary,
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: Text(
                                    email,

                                    overflow: TextOverflow.ellipsis,

                                    style: GoogleFonts.openSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.darkAccent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // --------------------------------------------------------
                          // Instructions
                          // --------------------------------------------------------
                          Text(
                            l10n.ifYouDontSee,

                            textAlign: TextAlign.center,

                            style: GoogleFonts.openSans(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            l10n.pleaseVerifyYourEmail,

                            textAlign: TextAlign.center,

                            style: GoogleFonts.openSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkAccent,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // --------------------------------------------------------
                          // Error
                          // --------------------------------------------------------
                          if (error != null) ...[
                            ErrorMessageWidget(localErrorMessage: error!),

                            const SizedBox(height: 16),
                          ],

                          // --------------------------------------------------------
                          // I've verified button
                          // --------------------------------------------------------
                          SizedBox(
                            height: 52,

                            child: ElevatedButton.icon(
                              onPressed: isCheckingVerification
                                  ? null
                                  : manuallyCheckVerification,

                              icon: isCheckingVerification
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,

                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.verified_outlined,
                                      size: 21,
                                    ),

                              label: Text(
                                l10n.pleaseVerifyYourEmail,

                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,

                                foregroundColor: Colors.white,

                                disabledBackgroundColor: AppColors.primary
                                    .withValues(alpha: 0.45),

                                disabledForegroundColor: Colors.white70,

                                elevation: 0,

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // --------------------------------------------------------
                          // Resend email
                          // --------------------------------------------------------
                          OutlinedButton.icon(
                            onPressed: canResendEmail && !isSendingEmail
                                ? sendVerificationEmail
                                : null,

                            icon: isSendingEmail
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,

                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.refresh_rounded, size: 20),

                            label: Text(
                              canResendEmail
                                  ? l10n.resendEmail
                                  : '${l10n.resendEmail} (${resendCountdown}s)',

                              style: GoogleFonts.openSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,

                              disabledForegroundColor: Colors.grey.shade400,

                              side: BorderSide(
                                color: AppColors.primary.withValues(
                                  alpha: 0.20,
                                ),
                              ),

                              minimumSize: const Size.fromHeight(48),

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // --------------------------------------------------------
                          // Security / spam note
                          // --------------------------------------------------------
                          Container(
                            padding: const EdgeInsets.all(12),

                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,

                              borderRadius: BorderRadius.circular(12),
                            ),

                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  size: 17,
                                  color: Colors.grey.shade600,
                                ),

                                const SizedBox(width: 8),

                                Expanded(
                                  child: Text(
                                    l10n.ifYouDontSee,

                                    style: GoogleFonts.openSans(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          // --------------------------------------------------------
                          // Cancel / sign out
                          // --------------------------------------------------------
                          TextButton(
                            onPressed: cancelVerification,

                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey.shade700,

                              minimumSize: const Size.fromHeight(46),

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),

                            child: Text(
                              l10n.cancel,

                              style: GoogleFonts.openSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 550.ms, delay: 200.ms).slideY(begin: 0.08, end: 0, duration: 550.ms),

                    const SizedBox(height: 24),

                    // ------------------------------------------------------
                    // Language selector
                    // ------------------------------------------------------
                    ChangeLanguageMiniWidget(),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
