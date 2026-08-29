import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/icons/ion.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/widgets/change_language_mini_widget.dart';
import 'package:kipgo/screens/widgets/error_message.dart';
import 'package:kipgo/screens/widgets/input_decorator.dart';
import 'package:kipgo/services/auth_service.dart';
import 'package:kipgo/utils/colors.dart';

class SignupScreen extends StatefulWidget {
  final VoidCallback onBackToLogin;
  final VoidCallback? onAuthenticated;

  const SignupScreen({
    super.key,
    required this.onBackToLogin,
    required this.onAuthenticated,
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final signupKey = GlobalKey<FormState>();
  final authService = AuthService();

  String role = 'rider';

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String localErrorMessage = '';

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureRePassword = true;

  Future<void> signUp() async {
    if (!mounted) return;

    FocusScope.of(context).unfocus();

    setState(() {
      isLoading = true;
      localErrorMessage = '';
    });

    try {
      await authService.signUp(
        email: emailController.text.trim(),
        password: passwordController.text,
        username: nameController.text.trim(),
        role: role,
        context: context,
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      widget.onAuthenticated?.call();
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
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

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
                left: -80,
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
                right: -100,
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
                    // Top bar / Back button
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

                    const SizedBox(height: 26),

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

                    const SizedBox(height: 20),

                    // ------------------------------------------------------
                    // Heading
                    // ------------------------------------------------------
                    Text(
                          loc.register.toUpperCase(),

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
                      loc.signupSubtitle,

                      textAlign: TextAlign.center,

                      style: GoogleFonts.openSans(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.75),
                        height: 1.5,
                      ),
                    ).animate().fadeIn(duration: 500.ms, delay: 150.ms),

                    const SizedBox(height: 28),

                    // ------------------------------------------------------
                    // Signup card
                    // ------------------------------------------------------
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),

                      padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),

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
                        key: signupKey,

                        autovalidateMode: AutovalidateMode.onUnfocus,

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,

                          children: [
                            // ------------------------------------------------
                            // Form heading
                            // ------------------------------------------------
                            Text(
                              loc.register,

                              style: GoogleFonts.poppins(
                                fontSize: 21,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkAccent,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              loc.signupFormSubtitle,

                              style: GoogleFonts.openSans(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                height: 1.5,
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ------------------------------------------------
                            // Username
                            // ------------------------------------------------
                            Text(
                              loc.username,

                              style: GoogleFonts.openSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkAccent,
                              ),
                            ),

                            const SizedBox(height: 8),

                            TextFormField(
                              controller: nameController,

                              textInputAction: TextInputAction.next,

                              textCapitalization: TextCapitalization.words,

                              style: GoogleFonts.openSans(
                                fontSize: 14,
                                color: AppColors.darkAccent,
                              ),

                              decoration:
                                  inputDecoration(
                                    context: context,
                                    useTheme: false,
                                    hint: loc.username,
                                    prefixIcon: Ph.user_thin,
                                  ).copyWith(
                                    filled: true,
                                    fillColor: const Color(0xFFF7F7FA),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                  ),

                              validator: (value) {
                                final username = value?.trim() ?? '';

                                if (username.isEmpty) {
                                  return loc.usernameCannotBeEmpty;
                                }

                                if (username.length < 3) {
                                  return loc.usernameLength;
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 18),

                            // ------------------------------------------------
                            // Email
                            // ------------------------------------------------
                            Text(
                              loc.email,

                              style: GoogleFonts.openSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkAccent,
                              ),
                            ),

                            const SizedBox(height: 8),

                            TextFormField(
                              controller: emailController,

                              keyboardType: TextInputType.emailAddress,

                              textInputAction: TextInputAction.next,

                              style: GoogleFonts.openSans(
                                fontSize: 14,
                                color: AppColors.darkAccent,
                              ),

                              decoration:
                                  inputDecoration(
                                    context: context,
                                    useTheme: false,
                                    hint: loc.email,
                                    prefixIcon: Ion.ios_email_outline,
                                  ).copyWith(
                                    filled: true,
                                    fillColor: const Color(0xFFF7F7FA),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                  ),

                              validator: (value) {
                                final email = value?.trim() ?? '';

                                if (email.isEmpty) {
                                  return loc.enterEmail;
                                }

                                if (!EmailValidator.validate(email)) {
                                  return loc.enterAValidEmail;
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 18),

                            // ------------------------------------------------
                            // Password
                            // ------------------------------------------------
                            Text(
                              loc.password,

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

                              textInputAction: TextInputAction.next,

                              style: GoogleFonts.openSans(
                                fontSize: 14,
                                color: AppColors.darkAccent,
                              ),

                              decoration:
                                  inputDecoration(
                                    context: context,
                                    useTheme: false,
                                    hint: loc.password,
                                    prefixIcon: Ph.password_thin,
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

                              validator: (value) {
                                if (value == null || value.length < 8) {
                                  return loc.passwordLength;
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 7),

                            // Password hint
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  size: 14,
                                  color: Colors.grey.shade500,
                                ),

                                const SizedBox(width: 6),

                                Expanded(
                                  child: Text(
                                    loc.passwordLength,
                                    style: GoogleFonts.openSans(
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            // ------------------------------------------------
                            // Confirm password
                            // ------------------------------------------------
                            Text(
                              loc.confirmPassword,

                              style: GoogleFonts.openSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkAccent,
                              ),
                            ),

                            const SizedBox(height: 8),

                            TextFormField(
                              controller: confirmPasswordController,

                              obscureText: obscureRePassword,

                              textInputAction: TextInputAction.done,

                              style: GoogleFonts.openSans(
                                fontSize: 14,
                                color: AppColors.darkAccent,
                              ),

                              onFieldSubmitted: (_) {
                                if (!isLoading &&
                                    signupKey.currentState!.validate()) {
                                  signUp();
                                }
                              },

                              decoration:
                                  inputDecoration(
                                    context: context,
                                    useTheme: false,
                                    hint: loc.confirmPassword,
                                    prefixIcon: Ph.password_thin,
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
                                          obscureRePassword =
                                              !obscureRePassword;
                                        });
                                      },

                                      icon: Icon(
                                        obscureRePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        size: 20,
                                      ),

                                      color: Colors.grey.shade600,
                                    ),
                                  ),

                              validator: (value) {
                                final confirmPassword = value ?? '';

                                if (confirmPassword.length < 8) {
                                  return loc.enterMinCharacters;
                                }

                                if (passwordController.text !=
                                    confirmPassword) {
                                  return loc.passwordsDoNotMatch;
                                }

                                return null;
                              },
                            ),

                            // ------------------------------------------------
                            // Error message
                            // ------------------------------------------------
                            if (localErrorMessage.isNotEmpty) ...[
                              const SizedBox(height: 16),

                              ErrorMessageWidget(
                                localErrorMessage: localErrorMessage,
                              ),
                            ],

                            const SizedBox(height: 20),

                            // ------------------------------------------------
                            // Create account button
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

                                        final isValid = signupKey.currentState!
                                            .validate();

                                        if (isValid) {
                                          signUp();
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
                                          loc.signUp,

                                          key: const ValueKey('signup'),

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
                            // Login divider
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
                                    loc.orCap,

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
                            // Already have account
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

                              onPressed: widget.onBackToLogin,

                              child: Text(
                                loc.alreadyHaveAnAccount,

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
