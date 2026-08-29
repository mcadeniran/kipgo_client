import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/icons/ion.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:kipgo/controllers/auth_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/auth/firebase_auth_error_mapping.dart';
import 'package:kipgo/screens/auth/forgot_password_screen.dart';
import 'package:kipgo/screens/widgets/change_language_mini_widget.dart';
import 'package:kipgo/screens/widgets/error_message.dart';
import 'package:kipgo/screens/widgets/input_decorator.dart';
import 'package:kipgo/services/auth_service.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onSignupPressed;
  final VoidCallback? onAuthenticated;

  const LoginScreen({
    super.key,
    required this.onSignupPressed,
    required this.onAuthenticated,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final signInKey = GlobalKey<FormState>();
  final authService = AuthService();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String localErrorMessage = '';
  bool isLoading = false;
  bool obscurePassword = true;

  Future<void> login() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      localErrorMessage = '';
    });

    final email = emailController.text.trim();
    final password = passwordController.text;

    try {
      await context.read<AuthProvider>().login(
        email: email,
        password: password,
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      widget.onAuthenticated?.call();
    } on FirebaseAuthException catch (e) {
      final userFriendlyMessage = e.toReadableMessage(
        AppLocalizations.of(context)!,
      );

      if (!mounted) return;

      setState(() {
        localErrorMessage = userFriendlyMessage;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        localErrorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
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
                    // Top bar
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
                    // Welcome text
                    // ------------------------------------------------------
                    Text(
                          l10n.welcomeBack.toUpperCase(),

                          textAlign: TextAlign.center,

                          style: GoogleFonts.poppins(
                            fontSize: 26,
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
                      l10n.loginSubtitle,

                      textAlign: TextAlign.center,

                      style: GoogleFonts.openSans(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.75),
                        height: 1.5,
                      ),
                    ).animate().fadeIn(duration: 500.ms, delay: 150.ms),

                    const SizedBox(height: 30),

                    // ------------------------------------------------------
                    // Login card
                    // ------------------------------------------------------
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),

                      padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),

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
                        key: signInKey,

                        autovalidateMode: AutovalidateMode.onUnfocus,

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,

                          children: [
                            // ------------------------------------------------
                            // Card heading
                            // ------------------------------------------------
                            Text(
                              l10n.login,

                              style: GoogleFonts.poppins(
                                fontSize: 21,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkAccent,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              l10n.loginFormSubtitle,

                              style: GoogleFonts.openSans(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                height: 1.5,
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ------------------------------------------------
                            // Email
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

                            TextFormField(
                              controller: emailController,

                              textInputAction: TextInputAction.next,

                              keyboardType: TextInputType.emailAddress,

                              style: GoogleFonts.openSans(
                                fontSize: 14,
                                color: AppColors.darkAccent,
                              ),

                              validator: (email) {
                                if (email == null || email.trim().isEmpty) {
                                  return l10n.enterAValidEmail;
                                }

                                if (!EmailValidator.validate(email.trim())) {
                                  return l10n.enterAValidEmail;
                                }

                                return null;
                              },

                              decoration:
                                  inputDecoration(
                                    context: context,
                                    hint: l10n.email,
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
                            ),

                            const SizedBox(height: 18),

                            // ------------------------------------------------
                            // Password
                            // ------------------------------------------------
                            Text(
                              l10n.password,

                              style: GoogleFonts.openSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkAccent,
                              ),
                            ),

                            const SizedBox(height: 8),

                            TextFormField(
                              controller: passwordController,

                              obscureText: obscurePassword,

                              textInputAction: TextInputAction.done,

                              onFieldSubmitted: (_) {
                                if (!isLoading &&
                                    signInKey.currentState!.validate()) {
                                  login();
                                }
                              },

                              style: GoogleFonts.openSans(
                                fontSize: 14,
                                color: AppColors.darkAccent,
                              ),

                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.passwordLength;
                                }

                                if (value.length < 8) {
                                  return l10n.passwordLength;
                                }

                                return null;
                              },

                              decoration:
                                  inputDecoration(
                                    context: context,
                                    hint: l10n.password,
                                    prefixIcon: Ph.password_thin,
                                    useTheme: false,
                                  ).copyWith(
                                    filled: true,
                                    fillColor: const Color(0xFFF7F7FA),

                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),

                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          obscurePassword = !obscurePassword;
                                        });
                                      },

                                      icon: Icon(
                                        obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,

                                        size: 20,
                                      ),

                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                            ),

                            const SizedBox(height: 8),

                            // ------------------------------------------------
                            // Forgot password
                            // ------------------------------------------------
                            Align(
                              alignment: Alignment.centerRight,

                              child: TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 4,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),

                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const ForgotPasswordScreen(),
                                    ),
                                  );
                                },

                                child: Text(
                                  l10n.forgotPassword,

                                  style: GoogleFonts.openSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),

                            // ------------------------------------------------
                            // Error
                            // ------------------------------------------------
                            if (localErrorMessage.isNotEmpty) ...[
                              const SizedBox(height: 8),

                              ErrorMessageWidget(
                                localErrorMessage: localErrorMessage,
                              ),

                              const SizedBox(height: 6),
                            ],

                            const SizedBox(height: 10),

                            // ------------------------------------------------
                            // Login button
                            // ------------------------------------------------
                            SizedBox(
                              height: 52,

                              child: ElevatedButton(
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

                                onPressed: isLoading
                                    ? null
                                    : () {
                                        FocusScope.of(context).unfocus();

                                        final isValidForm = signInKey
                                            .currentState!
                                            .validate();

                                        if (isValidForm) {
                                          login();
                                        }
                                      },

                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),

                                  child: isLoading
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
                                          l10n.login,

                                          key: const ValueKey('login'),

                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 22),

                            // ------------------------------------------------
                            // Signup divider
                            // ------------------------------------------------
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(color: Colors.grey.shade300),
                                ),

                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),

                                  child: Text(
                                    l10n.orCap,

                                    style: GoogleFonts.openSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ),

                                Expanded(
                                  child: Divider(color: Colors.grey.shade300),
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            // ------------------------------------------------
                            // Create account
                            // ------------------------------------------------
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,

                                side: BorderSide(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.25,
                                  ),
                                ),

                                minimumSize: const Size.fromHeight(48),

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),

                              onPressed: widget.onSignupPressed,

                              child: Text(
                                l10n.dontHaveAnAccount,

                                style: GoogleFonts.openSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
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
