import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/icons/ion.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/auth/forgot_password_screen.dart';
import 'package:kipgo/screens/widgets/change_language_mini_widget.dart';
import 'package:kipgo/screens/widgets/error_message.dart';
import 'package:kipgo/screens/widgets/input_decorator.dart';
import 'package:kipgo/services/auth_service.dart';
import 'package:kipgo/services/role_based_auth_gate.dart';
import 'package:kipgo/utils/colors.dart';

import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

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

  void login() async {
    setState(() {
      isLoading = true;
      localErrorMessage = '';
    });
    final email = emailController.text;
    final password = passwordController.text;
    // final userProvider = Provider.of<ProfileProvider>(context, listen: false);

    try {
      await authService.login(email: email, password: password);
      // await userProvider.refreshProfile();

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => RoleBasedAuthGate()),
          (route) => false,
        );
      }
    } catch (e) {
      localErrorMessage = e.toString().replaceFirst('Exception: ', '');
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
      ),

      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              children: [
                const SizedBox(height: 40),
                Hero(
                  tag: 'AuthLogo',
                  child: Image.asset(
                    'assets/images/kipgo_transparent.png',
                    height: 40,
                  ),
                ),

                const SizedBox(height: 20),
                Text(
                  AppLocalizations.of(context)!.welcomeBack.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ).animate().fadeIn(duration: 500.ms),

                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Form(
                    autovalidateMode: AutovalidateMode.onUnfocus,
                    key: signInKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: emailController,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress,
                          validator: (email) {
                            if (email != null &&
                                !EmailValidator.validate(email)) {
                              return AppLocalizations.of(
                                context,
                              )!.enterAValidEmail;
                            } else {
                              return null;
                            }
                          },
                          style: TextStyle(
                            color: Colors.black87, // Text color
                            fontSize: 14, // Font size
                          ),
                          decoration: inputDecoration(
                            context: context,
                            hint: AppLocalizations.of(context)!.email,
                            prefixIcon: Ion.ios_email_outline,
                            useTheme: false,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          textInputAction: TextInputAction.done,
                          validator: (value) {
                            if (value != null && value.length < 8) {
                              return AppLocalizations.of(
                                context,
                              )!.passwordLength;
                            } else {
                              return null;
                            }
                          },
                          style: TextStyle(
                            color: Colors.black87, // Text color
                            fontSize: 14, // Font size
                          ),
                          decoration:
                              inputDecoration(
                                context: context,
                                hint: AppLocalizations.of(context)!.password,
                                prefixIcon: Ph.password_thin,
                                useTheme: false,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  onPressed: () => setState(
                                    () => obscurePassword = !obscurePassword,
                                  ),
                                  icon: obscurePassword
                                      ? const Icon(Icons.visibility_off)
                                      : const Icon(Icons.visibility),
                                  color: const Color(0XFF757575),
                                ),
                              ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            // onPressed: showForgotPasswordDialog,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: Text(
                              AppLocalizations.of(context)!.forgotPassword,
                            ),
                          ),
                        ),
                        // const SizedBox(height: 10),
                        if (localErrorMessage != '') ...[
                          ErrorMessageWidget(
                            localErrorMessage: localErrorMessage,
                          ),
                          const SizedBox(height: 10),
                        ],
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: AppColors.primary
                                .withValues(alpha: 0.5),
                            disabledForegroundColor: Colors.white54,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: isLoading
                              ? null
                              : () {
                                  final isValidForm = signInKey.currentState!
                                      .validate();
                                  if (isValidForm) {
                                    login();
                                  }
                                },
                          child: Text(AppLocalizations.of(context)!.login),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignupScreen(),
                              ),
                            );
                          },
                          child: Text(
                            AppLocalizations.of(context)!.dontHaveAnAccount,
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // SocialLogin(),
                      ],
                    ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.2),
                  ),
                ),
                SizedBox(height: 20),
                ChangeLanguageMiniWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
