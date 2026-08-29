import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/icons/ion.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/widgets/change_language_mini_widget.dart';
import 'package:kipgo/screens/widgets/error_message.dart';
import 'package:kipgo/screens/widgets/input_decorator.dart';
import 'package:kipgo/screens/widgets/success_message_widget.dart';
import 'package:kipgo/services/auth_service.dart';
import 'package:kipgo/utils/colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final resetPasswordKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final authService = AuthService();

  bool loading = false;

  String? message;
  String? error;

  Future<void> submitEmail() async {
    if (!mounted) return;

    FocusScope.of(context).unfocus();

    setState(() {
      loading = true;
      message = null;
      error = null;
    });

    try {
      final (success, response) = await authService.resetPassword(
        email: emailController.text.trim(),
        context: context,
      );

      if (!mounted) return;

      setState(() {
        loading = false;

        if (success) {
          message = response;
          error = null;
        } else {
          error = response;
          message = null;
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        message = null;
        error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.primary,

      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },

          child: Stack(
            children: [
              // ------------------------------------------------------------
              // Decorative background
              // ------------------------------------------------------------
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

              // ------------------------------------------------------------
              // Main content
              // ------------------------------------------------------------
              SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,

                padding: const EdgeInsets.only(bottom: 24),

                child: Column(
                  children: [
                    // ------------------------------------------------------
                    // Back button
                    // ------------------------------------------------------
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),

                      child: Row(
                        children: [
                          Material(
                            color: Colors.white.withValues(alpha: 0.12),
                            shape: const CircleBorder(),

                            child: InkWell(
                              customBorder: const CircleBorder(),

                              onTap: () {
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                }
                              },

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

                    const SizedBox(height: 32),

                    // ------------------------------------------------------
                    // Logo
                    // ------------------------------------------------------
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

                    // ------------------------------------------------------
                    // Heading
                    // ------------------------------------------------------
                    Text(
                          l10n.forgotPasswordTitle.toUpperCase(),

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

                    // const SizedBox(height: 8),

                    // Text(
                    //   l10n.forgotPasswordDescription,

                    //   textAlign: TextAlign.center,

                    //   style: GoogleFonts.openSans(
                    //     fontSize: 14,
                    //     color: Colors.white.withValues(alpha: 0.75),
                    //     height: 1.5,
                    //   ),
                    // ).animate().fadeIn(duration: 500.ms, delay: 150.ms),
                    const SizedBox(height: 30),

                    // ------------------------------------------------------
                    // Reset password card
                    // ------------------------------------------------------
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

                      child: Form(
                        key: resetPasswordKey,

                        autovalidateMode: AutovalidateMode.onUnfocus,

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,

                          children: [
                            // ------------------------------------------------
                            // Icon
                            // ------------------------------------------------
                            Center(
                                  child: Container(
                                    width: 64,
                                    height: 64,

                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.08,
                                      ),
                                      shape: BoxShape.circle,
                                    ),

                                    child: Icon(
                                      Icons.lock_reset_rounded,
                                      color: AppColors.primary,
                                      size: 30,
                                    ),
                                  ),
                                )
                                .animate()
                                .fadeIn(duration: 400.ms)
                                .scale(
                                  begin: const Offset(0.8, 0.8),
                                  end: const Offset(1, 1),
                                ),

                            const SizedBox(height: 20),

                            // ------------------------------------------------
                            // Form heading
                            // ------------------------------------------------
                            Text(
                              l10n.resetPassword,

                              textAlign: TextAlign.center,

                              style: GoogleFonts.poppins(
                                fontSize: 21,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkAccent,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              l10n.forgotPasswordDescription,

                              textAlign: TextAlign.center,

                              style: GoogleFonts.openSans(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                height: 1.5,
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ------------------------------------------------
                            // Email label
                            // ------------------------------------------------
                            Text(
                              l10n.email,

                              style: GoogleFonts.openSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkAccent,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // ------------------------------------------------
                            // Email field
                            // ------------------------------------------------
                            TextFormField(
                              controller: emailController,

                              keyboardType: TextInputType.emailAddress,

                              textInputAction: TextInputAction.done,

                              style: GoogleFonts.openSans(
                                fontSize: 14,
                                color: AppColors.darkAccent,
                              ),

                              onFieldSubmitted: (_) {
                                if (!loading &&
                                    resetPasswordKey.currentState!.validate()) {
                                  submitEmail();
                                }
                              },

                              decoration:
                                  inputDecoration(
                                    context: context,
                                    hint: l10n.enterEmail,
                                    prefixIcon: Ion.ios_email_outline,
                                    useTheme: false,
                                  ).copyWith(
                                    filled: true,
                                    fillColor: const Color(0xFFF7F7FA),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                  ),

                              validator: (email) {
                                final value = email?.trim() ?? '';

                                if (value.isEmpty ||
                                    !EmailValidator.validate(value)) {
                                  return l10n.enterAValidEmail;
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 18),

                            // ------------------------------------------------
                            // Success message
                            // ------------------------------------------------
                            if (message != null) ...[
                              SuccessMessageWidget(successMessage: message!),

                              const SizedBox(height: 12),
                            ],

                            // ------------------------------------------------
                            // Error message
                            // ------------------------------------------------
                            if (error != null) ...[
                              ErrorMessageWidget(localErrorMessage: error!),

                              const SizedBox(height: 12),
                            ],

                            // ------------------------------------------------
                            // Send reset link
                            // ------------------------------------------------
                            SizedBox(
                              height: 52,

                              child: ElevatedButton(
                                onPressed: loading
                                    ? null
                                    : () {
                                        FocusScope.of(context).unfocus();

                                        final isValid = resetPasswordKey
                                            .currentState!
                                            .validate();

                                        if (isValid) {
                                          submitEmail();
                                        }
                                      },

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

                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),

                                  child: loading
                                      ? const SizedBox(
                                          key: ValueKey('loading'),

                                          width: 22,
                                          height: 22,

                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : Text(
                                          l10n.sendResetLink,

                                          key: const ValueKey('send'),

                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // ------------------------------------------------
                            // Back to login
                            // ------------------------------------------------
                            TextButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                              },

                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                size: 18,
                              ),

                              label: Text(
                                l10n.backToLogin,

                                style: GoogleFonts.openSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ],
                        ),
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
