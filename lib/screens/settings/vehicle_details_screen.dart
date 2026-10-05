import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/profile.dart';
import 'package:kipgo/screens/settings/docs/car_with_plate_section.dart';
import 'package:kipgo/screens/settings/docs/driver_licence_section.dart';
import 'package:kipgo/screens/settings/docs/selfie_with_licence_section.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/screens/widgets/error_message.dart';
import 'package:kipgo/screens/widgets/input_decorator.dart';
import 'package:kipgo/screens/widgets/success_message_widget.dart';
import 'package:kipgo/utils/colors.dart';

class VehicleDetailsScreen extends StatefulWidget {
  const VehicleDetailsScreen({super.key});

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  final vehicleEditKey = GlobalKey<FormState>();

  final TextEditingController colourController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();
  final TextEditingController numberPlateController = TextEditingController();

  late Profile profile;

  bool documentSubmitted = false;
  String localError = '';
  String localSuccess = '';
  bool isLoading = false;

  Future<void> updateVehicleDetails() async {
    setState(() {
      isLoading = true;
      localError = '';
      localSuccess = '';
    });

    try {
      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(profile.id)
          .update({
            'vehicle.colour': colourController.text.trim(),
            'vehicle.licence': licenseController.text.trim(),
            'vehicle.model': modelController.text.trim(),
            'vehicle.numberPlate': numberPlateController.text.trim(),
            'account.isApproved': false,
          });

      if (!mounted) return;

      setState(() {
        localSuccess = AppLocalizations.of(
          context,
        )!.vehicleDetailsUpdateSuccess;
        documentSubmitted = true;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        localError =
            '${AppLocalizations.of(context)!.vehicleDetailsUpdateFailure}: $e';
      });
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    profile = Provider.of<ProfileProvider>(context, listen: false).profile!;

    colourController.text = profile.vehicle.colour;
    modelController.text = profile.vehicle.model;
    licenseController.text = profile.vehicle.licence;
    numberPlateController.text = profile.vehicle.numberPlate;

    documentSubmitted =
        profile.vehicle.colour.isNotEmpty &&
        profile.vehicle.model.isNotEmpty &&
        profile.vehicle.licence.isNotEmpty &&
        profile.vehicle.numberPlate.isNotEmpty;
  }

  @override
  void dispose() {
    colourController.dispose();
    modelController.dispose();
    licenseController.dispose();
    numberPlateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    final backgroundColor = theme.scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBarWidget(
        title: AppLocalizations.of(context)!.vehicleDetails.toUpperCase(),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              12,
              18,
              12,
              MediaQuery.of(context).padding.bottom + 28,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildVerificationHeader(context, isDark),

                const SizedBox(height: 24),

                _sectionTitle(
                  context,
                  icon: Icons.directions_car_outlined,
                  title: AppLocalizations.of(context)!.vehicleDetails,
                ),

                const SizedBox(height: 12),

                _buildVehicleForm(context, isDark),

                const SizedBox(height: 28),

                _sectionTitle(
                  context,
                  icon: Icons.verified_user_outlined,
                  title: AppLocalizations.of(context)!.documentStatus,
                ),

                const SizedBox(height: 8),

                Text(
                  AppLocalizations.of(context)!.pleaseUploadTheRequired,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white60 : Colors.black54,
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 14),

                Consumer<ProfileProvider>(
                  builder: (context, p, _) {
                    if (p.isLoading) {
                      return _buildDocumentsLoading(isDark);
                    }

                    return Column(
                      children: [
                        documentTile(
                          title: AppLocalizations.of(
                            context,
                          )!.driverLicencePicture,
                          status: p.profile!.vehicle.licenceStatus,
                          page: DriverLicenceSection(),
                        ),
                        const SizedBox(height: 12),
                        documentTile(
                          title: AppLocalizations.of(
                            context,
                          )!.carWithRegistrationNumberPicture,
                          status: p.profile!.vehicle.registrationStatus,
                          page: CarWithPlateSection(),
                        ),
                        const SizedBox(height: 12),
                        documentTile(
                          title: AppLocalizations.of(
                            context,
                          )!.selfieWithLicence,
                          status: p.profile!.vehicle.selfieStatus,
                          page: SelfieWithLicenceSection(),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),

                _buildInformationCard(context, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationHeader(BuildContext context, bool isDark) {
    return Consumer<ProfileProvider>(
      builder: (context, p, _) {
        if (p.isLoading) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: _cardDecoration(isDark),
            child: const Center(child: CircularProgressIndicator.adaptive()),
          );
        }

        final vehicle = p.profile!.vehicle;
        final isApproved = p.profile!.account.isApproved;

        final String statusText;
        final Color statusColor;
        final IconData statusIcon;

        if (isApproved) {
          statusText = AppLocalizations.of(context)!.approved;
          statusColor = Colors.green;
          statusIcon = Icons.verified_rounded;
        } else if (vehicle.licenceStatus.isEmpty &&
            vehicle.registrationStatus.isEmpty &&
            vehicle.selfieStatus.isEmpty) {
          statusText = AppLocalizations.of(context)!.notSubmitted;
          statusColor = Colors.red;
          statusIcon = Icons.info_outline_rounded;
        } else if (vehicle.licenceStatus.isEmpty ||
            vehicle.registrationStatus.isEmpty ||
            vehicle.selfieStatus.isEmpty) {
          statusText = AppLocalizations.of(context)!.missingDocuments;
          statusColor = Colors.red;
          statusIcon = Icons.warning_amber_rounded;
        } else if (vehicle.licenceStatus == 'Rejected' ||
            vehicle.registrationStatus == 'Rejected' ||
            vehicle.selfieStatus == 'Rejected') {
          statusText = AppLocalizations.of(context)!.documentRejected;
          statusColor = Colors.red;
          statusIcon = Icons.cancel_outlined;
        } else {
          statusText = AppLocalizations.of(context)!.pending;
          statusColor = AppColors.secondary;
          statusIcon = Icons.hourglass_top_rounded;
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      AppColors.darkAccent,
                      AppColors.darkLayer.withValues(alpha: 0.8),
                    ]
                  : [AppColors.lightAccent, Colors.white],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : AppColors.border.withValues(alpha: 0.7),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                offset: const Offset(0, 8),
                color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.06),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, color: statusColor, size: 29),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.documentStatus,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white54 : Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      statusText,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (isApproved)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.green,
                    size: 18,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVehicleForm(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(isDark),
      child: Form(
        key: vehicleEditKey,
        autovalidateMode: AutovalidateMode.onUnfocus,
        child: Column(
          children: [
            _premiumField(
              context: context,
              controller: modelController,
              hint: AppLocalizations.of(context)!.carModel,
              icon: Icons.directions_car_outlined,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppLocalizations.of(context)!.carModelRequired;
                }

                if (value.trim().length < 6) {
                  return AppLocalizations.of(context)!.carModelLengthError;
                }

                return null;
              },
            ),

            const SizedBox(height: 14),

            _premiumField(
              context: context,
              controller: colourController,
              hint: AppLocalizations.of(context)!.colour,
              icon: Icons.palette_outlined,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppLocalizations.of(context)!.carColourRequired;
                }

                if (value.trim().length < 3) {
                  return AppLocalizations.of(context)!.carColourLengthError;
                }

                return null;
              },
            ),

            const SizedBox(height: 14),

            _premiumField(
              context: context,
              controller: licenseController,
              hint: AppLocalizations.of(context)!.licenceNumber,
              icon: Icons.badge_outlined,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppLocalizations.of(context)!.licenceNumberRequired;
                }

                if (value.trim().length < 5) {
                  return AppLocalizations.of(context)!.licenceNumberLengthError;
                }

                return null;
              },
            ),

            const SizedBox(height: 14),

            _premiumField(
              context: context,
              controller: numberPlateController,
              hint: AppLocalizations.of(context)!.carRegistrationNumberHint,
              icon: Icons.confirmation_number_outlined,
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppLocalizations.of(
                    context,
                  )!.carRegistrationNumberRequired;
                }

                if (value.trim().length < 5) {
                  return AppLocalizations.of(
                    context,
                  )!.carRegistrationNumberLengthError;
                }

                return null;
              },
            ),

            if (localError.isNotEmpty) ...[
              const SizedBox(height: 14),
              ErrorMessageWidget(localErrorMessage: localError),
            ],

            if (localSuccess.isNotEmpty) ...[
              const SizedBox(height: 14),
              SuccessMessageWidget(successMessage: localSuccess),
            ],

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        if (vehicleEditKey.currentState!.validate()) {
                          vehicleEditKey.currentState!.save();
                          updateVehicleDetails();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primary.withValues(
                    alpha: 0.45,
                  ),
                  disabledForegroundColor: Colors.white60,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isLoading
                      ? const SizedBox(
                          key: ValueKey('loading'),
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          key: const ValueKey('button'),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.save_outlined, size: 20),
                            const SizedBox(width: 9),
                            Text(
                              AppLocalizations.of(
                                context,
                              )!.submitVehicleDetails,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
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
    );
  }

  Widget _premiumField({
    required BuildContext context,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required TextInputAction textInputAction,
    required String? Function(String?) validator,
  }) {
    final isDark = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    return TextFormField(
      controller: controller,
      enableInteractiveSelection: true,
      textInputAction: textInputAction,
      keyboardType: TextInputType.text,
      maxLines: 1,
      validator: validator,
      decoration: inputDecoration(context: context, hint: hint).copyWith(
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 13, right: 8),
          child: Icon(
            icon,
            size: 21,
            color: isDark
                ? Colors.white60
                : AppColors.primary.withValues(alpha: 0.70),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 46,
          minHeight: 46,
        ),
      ),
    );
  }

  Widget _sectionTitle(
    BuildContext context, {
    required IconData icon,
    required String title,
  }) {
    final isDark = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.lightLayer.withValues(alpha: .08)
                : AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            color: isDark ? AppColors.lightLayer : AppColors.primary,
            size: 21,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsLoading(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(isDark),
      child: const Center(child: CircularProgressIndicator.adaptive()),
    );
  }

  Widget _buildInformationCard(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkAccent
            : AppColors.primary.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : AppColors.primary.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: isDark ? Colors.white70 : AppColors.primary,
              size: 21,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.yourStatusStaysPending,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppLocalizations.of(context)!.ifYouUpdateDocument,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white60 : Colors.black54,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? AppColors.darkAccent : Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.07)
            : AppColors.border.withValues(alpha: 0.55),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.14 : 0.035),
          blurRadius: 18,
          offset: const Offset(0, 7),
        ),
      ],
    );
  }

  Widget documentTile({
    required String title,
    required String status,
    required Widget page,
  }) {
    final isDark = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    final isNotSubmitted = status.isEmpty;
    final isSubmitted = status == 'Submitted';
    final isAccepted = status == 'Accepted';
    // final isRejected = status == 'Rejected';

    final Color statusColor = isNotSubmitted
        ? Colors.grey
        : isSubmitted
        ? AppColors.secondary
        : isAccepted
        ? Colors.green
        : Colors.red;

    final IconData statusIcon = isNotSubmitted
        ? Icons.cloud_upload_outlined
        : isSubmitted
        ? Icons.hourglass_top_rounded
        : isAccepted
        ? Icons.check_circle_rounded
        : Icons.cancel_rounded;

    final String statusText = isNotSubmitted
        ? AppLocalizations.of(context)!.notSubmitted
        : isSubmitted
        ? AppLocalizations.of(context)!.submitted
        : isAccepted
        ? AppLocalizations.of(context)!.accepted
        : AppLocalizations.of(context)!.rejected;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkAccent : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : AppColors.border.withValues(alpha: 0.55),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(statusIcon, color: statusColor, size: 24),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          statusText,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : AppColors.primary.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: isDark ? Colors.white70 : AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// class VehicleDetailsScreen extends StatefulWidget {
//   const VehicleDetailsScreen({super.key});

//   @override
//   State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
// }

// class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
//   final vehicleEditKey = GlobalKey<FormState>();
//   TextEditingController colourController = TextEditingController();
//   TextEditingController modelController = TextEditingController();
//   TextEditingController licenseController = TextEditingController();
//   TextEditingController numberPlateController = TextEditingController();

//   late Profile profile;
//   bool documentSubmitted = false;

//   String localError = '';
//   String localSuccess = '';

//   bool isLoading = false;

//   Future<void> updateVehicleDetails() async {
//     setState(() {
//       isLoading = true;
//       localError = '';
//       localSuccess = '';
//     });

//     try {
//       await FirebaseFirestore.instance
//           .collection('profiles')
//           .doc(profile.id)
//           .update({
//             'vehicle.colour': colourController.text,
//             'vehicle.licence': licenseController.text,
//             'vehicle.model': modelController.text,
//             'vehicle.numberPlate': numberPlateController.text,
//             'account.isApproved': false,
//           });
//       setState(() {
//         localSuccess = AppLocalizations.of(
//           context,
//         )!.vehicleDetailsUpdateSuccess;
//         documentSubmitted = true;
//       });
//     } catch (e) {
//       setState(() {
//         localError =
//             '${AppLocalizations.of(context)!.vehicleDetailsUpdateFailure}: $e';
//       });
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     profile = Provider.of<ProfileProvider>(context, listen: false).profile!;

//     colourController.text = profile.vehicle.colour;
//     modelController.text = profile.vehicle.model;
//     licenseController.text = profile.vehicle.licence;
//     numberPlateController.text = profile.vehicle.numberPlate;

//     if (profile.vehicle.colour == '' ||
//         profile.vehicle.model == '' ||
//         profile.vehicle.licence == '' ||
//         profile.vehicle.numberPlate == '') {
//       documentSubmitted = false;
//     } else {
//       documentSubmitted = true;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.primary,
//       appBar: AppBarWidget(
//         title: AppLocalizations.of(context)!.vehicleDetails.toUpperCase(),
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
//           padding: EdgeInsets.only(
//             top: 10,
//             bottom: MediaQuery.of(context).padding.bottom > 20
//                 ? MediaQuery.of(context).padding.bottom
//                 : 20,
//           ),
//           clipBehavior: Clip.hardEdge,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(20),
//               topRight: Radius.circular(20),
//             ),
//             color: Theme.of(context).scaffoldBackgroundColor,
//           ),
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
//             keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
//             child: Column(
//               children: [
//                 // SizedBox(height: 20),
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "${AppLocalizations.of(context)!.documentStatus}: ",
//                       style: TextStyle(fontWeight: FontWeight.w500),
//                     ),
//                     Consumer<ProfileProvider>(
//                       builder: (context, p, _) {
//                         if (p.isLoading) {
//                           return Center(
//                             child: CircularProgressIndicator.adaptive(),
//                           );
//                         } else {
//                           String s1 = p.profile!.vehicle.licenceStatus;
//                           String s2 = p.profile!.vehicle.registrationStatus;
//                           String s3 = p.profile!.vehicle.selfieStatus;
//                           bool status = p.profile!.account.isApproved;
//                           return Expanded(
//                             child: Text(
//                               status == true
//                                   ? AppLocalizations.of(context)!.approved
//                                   : s1 == '' && s2 == '' && s3 == ''
//                                   ? AppLocalizations.of(context)!.notSubmitted
//                                   : s1 == '' || s2 == '' || s3 == ''
//                                   ? AppLocalizations.of(
//                                       context,
//                                     )!.missingDocuments
//                                   : s1 == 'Rejected' ||
//                                         s2 == 'Rejected' ||
//                                         s3 == 'Rejected'
//                                   ? AppLocalizations.of(
//                                       context,
//                                     )!.documentRejected
//                                   : AppLocalizations.of(context)!.pending,
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: status == true
//                                     ? Colors.green
//                                     : s1 == '' && s2 == '' && s3 == ''
//                                     ? Colors.red
//                                     : s1 == '' || s2 == '' || s3 == ''
//                                     ? Colors.red
//                                     : AppColors.secondary,
//                               ),
//                             ),
//                           );
//                         }
//                       },
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 20),
//                 Form(
//                   key: vehicleEditKey,
//                   autovalidateMode: AutovalidateMode.onUnfocus,
//                   child: Column(
//                     children: [
//                       TextFormField(
//                         controller: modelController,
//                         enableInteractiveSelection: true,
//                         textInputAction: TextInputAction.next,
//                         minLines: 1,
//                         keyboardType: TextInputType.text,
//                         maxLines: 1,
//                         decoration: inputDecoration(
//                           context: context,
//                           hint: AppLocalizations.of(context)!.carModel,
//                         ),
//                         validator: (value) {
//                           if (value == '') {
//                             return AppLocalizations.of(
//                               context,
//                             )!.carModelRequired;
//                           } else if (value != null && value.length < 6) {
//                             return AppLocalizations.of(
//                               context,
//                             )!.carModelLengthError;
//                           } else {
//                             return null;
//                           }
//                         },
//                       ),
//                       SizedBox(height: 16),
//                       TextFormField(
//                         controller: colourController,
//                         enableInteractiveSelection: true,
//                         textInputAction: TextInputAction.next,
//                         minLines: 1,
//                         keyboardType: TextInputType.text,
//                         maxLines: 1,
//                         decoration: inputDecoration(
//                           context: context,
//                           hint: AppLocalizations.of(context)!.colour,
//                         ),
//                         validator: (value) {
//                           if (value == '') {
//                             return AppLocalizations.of(
//                               context,
//                             )!.carColourRequired;
//                           } else if (value != null && value.length < 3) {
//                             return AppLocalizations.of(
//                               context,
//                             )!.carColourLengthError;
//                           } else {
//                             return null;
//                           }
//                         },
//                       ),
//                       SizedBox(height: 16),
//                       TextFormField(
//                         controller: licenseController,
//                         enableInteractiveSelection: true,
//                         textInputAction: TextInputAction.next,
//                         minLines: 1,
//                         keyboardType: TextInputType.text,
//                         maxLines: 1,
//                         decoration: inputDecoration(
//                           context: context,
//                           hint: AppLocalizations.of(context)!.licenceNumber,
//                         ),
//                         validator: (value) {
//                           if (value == '') {
//                             return AppLocalizations.of(
//                               context,
//                             )!.licenceNumberRequired;
//                           } else if (value != null && value.length < 5) {
//                             return AppLocalizations.of(
//                               context,
//                             )!.licenceNumberLengthError;
//                           } else {
//                             return null;
//                           }
//                         },
//                       ),
//                       SizedBox(height: 16),
//                       TextFormField(
//                         controller: numberPlateController,
//                         enableInteractiveSelection: true,
//                         textInputAction: TextInputAction.next,
//                         minLines: 1,
//                         keyboardType: TextInputType.text,
//                         maxLines: 1,
//                         decoration: inputDecoration(
//                           context: context,
//                           hint: AppLocalizations.of(
//                             context,
//                           )!.carRegistrationNumberHint,
//                         ),
//                         validator: (value) {
//                           if (value == '') {
//                             return AppLocalizations.of(
//                               context,
//                             )!.carRegistrationNumberRequired;
//                           } else if (value != null && value.length < 5) {
//                             return AppLocalizations.of(
//                               context,
//                             )!.carRegistrationNumberLengthError;
//                           } else {
//                             return null;
//                           }
//                         },
//                       ),
//                       if (localError != '') ...[
//                         SizedBox(height: 16),
//                         ErrorMessageWidget(localErrorMessage: localError),
//                       ],
//                       if (localSuccess != '') ...[
//                         SizedBox(height: 16),
//                         SuccessMessageWidget(successMessage: localSuccess),
//                       ],
//                       SizedBox(height: 16),
//                       ElevatedButton(
//                         onPressed: isLoading
//                             ? null
//                             : () {
//                                 if (vehicleEditKey.currentState!.validate()) {
//                                   vehicleEditKey.currentState!
//                                       .save(); // ensures phone is saved
//                                   updateVehicleDetails();
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
//                           AppLocalizations.of(context)!.submitVehicleDetails,
//                         ),
//                       ),
//                       SizedBox(height: 20),
//                       Divider(thickness: 0.5, color: AppColors.border),
//                       SizedBox(height: 20),
//                       Text(
//                         AppLocalizations.of(context)!.pleaseUploadTheRequired,
//                         style: TextStyle(fontSize: 16),
//                       ),
//                       SizedBox(height: 10),
//                       Consumer<ProfileProvider>(
//                         builder: (context, p, _) {
//                           return Column(
//                             children: [
//                               documentTile(
//                                 title: AppLocalizations.of(
//                                   context,
//                                 )!.driverLicencePicture,
//                                 status: p.profile!.vehicle.licenceStatus,
//                                 page: DriverLicenceSection(),
//                               ),
//                               SizedBox(height: 10),
//                               documentTile(
//                                 title: AppLocalizations.of(
//                                   context,
//                                 )!.carWithRegistrationNumberPicture,
//                                 status: p.profile!.vehicle.registrationStatus,
//                                 page: CarWithPlateSection(),
//                               ),
//                               SizedBox(height: 10),
//                               documentTile(
//                                 title: AppLocalizations.of(
//                                   context,
//                                 )!.selfieWithLicence,
//                                 status: p.profile!.vehicle.selfieStatus,
//                                 page: SelfieWithLicenceSection(),
//                               ),
//                             ],
//                           );
//                         },
//                       ),
//                       SizedBox(height: 20),
//                       Divider(thickness: 0.5, color: AppColors.border),
//                       SizedBox(height: 20),
//                       Text(
//                         AppLocalizations.of(context)!.yourStatusStaysPending,
//                       ),
//                       SizedBox(height: 10),
//                       Text(AppLocalizations.of(context)!.ifYouUpdateDocument),
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

//   Container documentTile({
//     required String title,
//     required String status,
//     required Widget page,
//   }) {
//     bool isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
//     return Container(
//       width: double.maxFinite,
//       padding: EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: isDark ? AppColors.darkAccent : Colors.grey[50],
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: AppColors.border),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Expanded(
//             child: Row(
//               children: [
//                 Icon(
//                   status == ''
//                       ? Icons.upload_file
//                       : status == 'Submitted'
//                       ? Icons.timelapse
//                       : status == 'Accepted'
//                       ? Icons.check_circle
//                       : Icons.cancel,
//                   color: status == ''
//                       ? Colors.grey
//                       : status == 'Submitted'
//                       ? AppColors.secondary
//                       : status == 'Accepted'
//                       ? Colors.green
//                       : Colors.red,
//                 ),
//                 SizedBox(width: 8),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(title, style: TextStyle(fontSize: 16)),
//                       Text(
//                         status == ''
//                             ? AppLocalizations.of(context)!.notSubmitted
//                             : status == 'Submitted'
//                             ? AppLocalizations.of(context)!.submitted
//                             : status == 'Accepted'
//                             ? AppLocalizations.of(context)!.accepted
//                             : AppLocalizations.of(context)!.rejected,
//                         style: TextStyle(
//                           color: status == ''
//                               ? Colors.grey
//                               : status == 'Submitted'
//                               ? AppColors.secondary
//                               : status == 'Accepted'
//                               ? Colors.green
//                               : Colors.red,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           IconButton.outlined(
//             padding: EdgeInsets.all(0),
//             visualDensity: VisualDensity.compact,
//             iconSize: 28,
//             onPressed: () {
//               Navigator.push(context, MaterialPageRoute(builder: (_) => page));
//             },
//             icon: Icon(Icons.chevron_right_outlined),
//           ),
//         ],
//       ),
//     );
//   }
// }
