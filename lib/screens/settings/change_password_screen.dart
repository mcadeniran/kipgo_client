import 'package:flutter/material.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/screens/widgets/error_message.dart';
import 'package:kipgo/screens/widgets/input_decorator.dart';
import 'package:kipgo/screens/widgets/success_message_widget.dart';
import 'package:kipgo/services/auth_service.dart';
import 'package:kipgo/utils/colors.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final changePasswordKey = GlobalKey<FormState>();

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final authService = AuthService();

  bool loading = false;
  String? message;
  String? error;

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // ==========================================================
  // CHANGE PASSWORD
  // ==========================================================

  Future<void> changePassword() async {
    if (loading) return;

    FocusScope.of(context).unfocus();

    setState(() {
      loading = true;
      message = null;
      error = null;
    });

    try {
      final (success, response) = await authService.changePassword(
        currentPassword: currentPasswordController.text.trim(),
        newPassword: newPasswordController.text.trim(),
        context: context,
      );

      if (!mounted) return;

      setState(() {
        loading = false;

        if (success) {
          message = response;
          error = null;

          // Clear password fields after a successful update.
          currentPasswordController.clear();
          newPasswordController.clear();
          confirmPasswordController.clear();
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
        error = e.toString();
      });
    }
  }

  // ==========================================================
  // FORM SUBMISSION
  // ==========================================================

  void _submit() {
    FocusScope.of(context).unfocus();

    final isValid = changePasswordKey.currentState?.validate() ?? false;

    if (!isValid) return;

    changePassword();
  }

  // ==========================================================
  // PASSWORD FIELD
  // ==========================================================

  Widget _buildPasswordField({
    required BuildContext context,
    required String hint,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
    TextInputAction textInputAction = TextInputAction.next,
    String? label,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.82)
                  : AppColors.darkAccent,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          textInputAction: textInputAction,
          autocorrect: false,
          enableSuggestions: false,
          keyboardType: TextInputType.visiblePassword,
          validator: validator,
          decoration: inputDecoration(context: context, hint: hint).copyWith(
            suffixIcon: IconButton(
              onPressed: onToggleVisibility,
              tooltip: obscureText ? loc.showPassword : loc.hidePassword,
              icon: Icon(
                obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 21,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.55)
                    : Colors.blueGrey.shade500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // SECURITY HEADER
  // ==========================================================

  Widget _buildSecurityHeader(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: isDark ? 0.20 : 0.08),
            AppColors.tertiary.withValues(alpha: isDark ? 0.14 : 0.045),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: isDark ? 0.30 : 0.10),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.lightLayer.withValues(alpha: 0.08)
                  : AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.lock_reset_rounded,
              color: isDark ? AppColors.lightLayer : AppColors.primary,
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.securityTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  loc.securityDescription,
                  style: theme.textTheme.bodySmall?.copyWith(
                    height: 1.45,
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: 0.68,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // PASSWORD REQUIREMENTS
  // ==========================================================

  Widget _buildPasswordRequirements(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.035)
            : Colors.grey.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.grey.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: AppColors.secondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              loc.passwordRequirement,
              style: theme.textTheme.bodySmall?.copyWith(
                height: 1.4,
                fontWeight: FontWeight.w500,
                color: theme.textTheme.bodySmall?.color?.withValues(
                  alpha: 0.70,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBarWidget(title: loc.changePasswordTitle.toUpperCase()),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Form(
                  key: changePasswordKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(12, 24, 12, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ==================================================
                        // HEADER
                        // ==================================================
                        _buildSecurityHeader(context),

                        const SizedBox(height: 26),

                        // ==================================================
                        // SECTION TITLE
                        // ==================================================
                        Text(
                          loc.updateYourPassword,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          loc.updateDescription,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withValues(
                              alpha: 0.62,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ==================================================
                        // FORM CARD
                        // ==================================================
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.025)
                                : theme.cardColor,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.07)
                                  : Colors.black.withValues(alpha: 0.06),
                            ),
                            boxShadow: [
                              if (!isDark)
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.035),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ==================================================
                              // CURRENT PASSWORD
                              // ==================================================
                              _buildPasswordField(
                                context: context,
                                controller: currentPasswordController,
                                hint: loc.currentPassword,
                                label: loc.currentPasswordLabel,
                                obscureText: _obscureCurrentPassword,
                                onToggleVisibility: () {
                                  setState(() {
                                    _obscureCurrentPassword =
                                        !_obscureCurrentPassword;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return loc.enterCurrentPassword;
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 20),

                              // ==================================================
                              // NEW PASSWORD
                              // ==================================================
                              _buildPasswordField(
                                context: context,
                                controller: newPasswordController,
                                hint: loc.newPassword,
                                label: loc.newPasswordLabel,
                                obscureText: _obscureNewPassword,
                                onToggleVisibility: () {
                                  setState(() {
                                    _obscureNewPassword = !_obscureNewPassword;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return loc.enterNewPassword;
                                  }

                                  if (value.trim().length < 8) {
                                    return loc.passwordLength;
                                  }

                                  if (value.trim() ==
                                      currentPasswordController.text.trim()) {
                                    return loc.differentPassword;
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 12),

                              _buildPasswordRequirements(context),

                              const SizedBox(height: 20),

                              // ==================================================
                              // CONFIRM PASSWORD
                              // ==================================================
                              _buildPasswordField(
                                context: context,
                                controller: confirmPasswordController,
                                hint: loc.confirmPassword,
                                label: loc.confirmPasswordLabel,
                                obscureText: _obscureConfirmPassword,
                                textInputAction: TextInputAction.done,
                                onToggleVisibility: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return loc.enterConfirmPassword;
                                  }

                                  if (value.trim().length < 8) {
                                    return loc.enterMinCharacters;
                                  }

                                  if (value.trim() !=
                                      newPasswordController.text.trim()) {
                                    return loc.passwordsDoNotMatch;
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 22),

                              // ==================================================
                              // SUCCESS / ERROR
                              // ==================================================
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                child: message != null
                                    ? Padding(
                                        key: const ValueKey('success'),
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: SuccessMessageWidget(
                                          successMessage: message!,
                                        ),
                                      )
                                    : error != null
                                    ? Padding(
                                        key: const ValueKey('error'),
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: ErrorMessageWidget(
                                          localErrorMessage: error!,
                                        ),
                                      )
                                    : const SizedBox.shrink(
                                        key: ValueKey('empty'),
                                      ),
                              ),

                              // ==================================================
                              // UPDATE BUTTON
                              // ==================================================
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: FilledButton(
                                  onPressed: loading ? null : _submit,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: AppColors.primary
                                        .withValues(alpha: 0.45),
                                    disabledForegroundColor: Colors.white
                                        .withValues(alpha: 0.70),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
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
                                              strokeWidth: 2.3,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                        : Row(
                                            key: const ValueKey('idle'),
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.lock_outline_rounded,
                                                size: 19,
                                              ),
                                              const SizedBox(width: 9),
                                              Text(
                                                loc.updatePassword,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ==================================================
                        // SECURITY FOOTER
                        // ==================================================
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_user_outlined,
                                size: 15,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.35)
                                    : Colors.grey.shade500,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                loc.securityFooter,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.38)
                                      : Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
