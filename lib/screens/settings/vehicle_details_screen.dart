import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  TextEditingController colourController = TextEditingController();
  TextEditingController modelController = TextEditingController();
  TextEditingController licenseController = TextEditingController();
  TextEditingController numberPlateController = TextEditingController();

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
            'vehicle.colour': colourController.text,
            'vehicle.licence': licenseController.text,
            'vehicle.model': modelController.text,
            'vehicle.numberPlate': numberPlateController.text,
            'account.isApproved': false,
          });
      setState(() {
        localSuccess = AppLocalizations.of(
          context,
        )!.vehicleDetailsUpdateSuccess;
        documentSubmitted = true;
      });
    } catch (e) {
      setState(() {
        localError =
            '${AppLocalizations.of(context)!.vehicleDetailsUpdateFailure}: $e';
      });
    } finally {
      setState(() => isLoading = false);
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

    if (profile.vehicle.colour == '' ||
        profile.vehicle.model == '' ||
        profile.vehicle.licence == '' ||
        profile.vehicle.numberPlate == '') {
      documentSubmitted = false;
    } else {
      documentSubmitted = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBarWidget(
        title: AppLocalizations.of(context)!.vehicleDetails.toUpperCase(),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Container(
          width: double.maxFinite,
          height: double.maxFinite,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              children: [
                SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      "${AppLocalizations.of(context)!.documentStatus}: ",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      documentSubmitted == false
                          ? AppLocalizations.of(context)!.notSubmitted
                          : profile.account.isApproved == true
                          ? AppLocalizations.of(context)!.approved
                          : AppLocalizations.of(context)!.pending,
                      style: TextStyle(
                        color: profile.account.isApproved
                            ? Colors.blue
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Form(
                  key: vehicleEditKey,
                  autovalidateMode: AutovalidateMode.onUnfocus,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: modelController,
                        enableInteractiveSelection: true,
                        textInputAction: TextInputAction.next,
                        minLines: 1,
                        keyboardType: TextInputType.text,
                        maxLines: 1,
                        decoration: inputDecoration(
                          context: context,
                          hint: AppLocalizations.of(context)!.carModel,
                        ),
                        validator: (value) {
                          if (value == '') {
                            return AppLocalizations.of(
                              context,
                            )!.carModelRequired;
                          } else if (value != null && value.length < 6) {
                            return AppLocalizations.of(
                              context,
                            )!.carModelLengthError;
                          } else {
                            return null;
                          }
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: colourController,
                        enableInteractiveSelection: true,
                        textInputAction: TextInputAction.next,
                        minLines: 1,
                        keyboardType: TextInputType.text,
                        maxLines: 1,
                        decoration: inputDecoration(
                          context: context,
                          hint: AppLocalizations.of(context)!.colour,
                        ),
                        validator: (value) {
                          if (value == '') {
                            return AppLocalizations.of(
                              context,
                            )!.carColourRequired;
                          } else if (value != null && value.length < 3) {
                            return AppLocalizations.of(
                              context,
                            )!.carColourLengthError;
                          } else {
                            return null;
                          }
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: licenseController,
                        enableInteractiveSelection: true,
                        textInputAction: TextInputAction.next,
                        minLines: 1,
                        keyboardType: TextInputType.text,
                        maxLines: 1,
                        decoration: inputDecoration(
                          context: context,
                          hint: AppLocalizations.of(context)!.licenceNumber,
                        ),
                        validator: (value) {
                          if (value == '') {
                            return AppLocalizations.of(
                              context,
                            )!.licenceNumberRequired;
                          } else if (value != null && value.length < 5) {
                            return AppLocalizations.of(
                              context,
                            )!.licenceNumberLengthError;
                          } else {
                            return null;
                          }
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: numberPlateController,
                        enableInteractiveSelection: true,
                        textInputAction: TextInputAction.next,
                        minLines: 1,
                        keyboardType: TextInputType.text,
                        maxLines: 1,
                        decoration: inputDecoration(
                          context: context,
                          hint: AppLocalizations.of(
                            context,
                          )!.carRegistrationNumberHint,
                        ),
                        validator: (value) {
                          if (value == '') {
                            return AppLocalizations.of(
                              context,
                            )!.carRegistrationNumberRequired;
                          } else if (value != null && value.length < 6) {
                            return AppLocalizations.of(
                              context,
                            )!.carRegistrationNumberLengthError;
                          } else {
                            return null;
                          }
                        },
                      ),
                      if (localError != '') ...[
                        SizedBox(height: 16),
                        ErrorMessageWidget(localErrorMessage: localError),
                      ],
                      if (localSuccess != '') ...[
                        SizedBox(height: 16),
                        SuccessMessageWidget(successMessage: localSuccess),
                      ],
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                if (vehicleEditKey.currentState!.validate()) {
                                  vehicleEditKey.currentState!
                                      .save(); // ensures phone is saved
                                  updateVehicleDetails();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.primary.withValues(
                            alpha: 0.5,
                          ),
                          disabledForegroundColor: Colors.white54,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.submitVehicleDetails,
                        ),
                      ),
                      SizedBox(height: 20),
                      Divider(thickness: 0.5, color: AppColors.border),
                      SizedBox(height: 20),
                      Text(
                        AppLocalizations.of(context)!.pleaseUploadTheRequired,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      DriverLicenceSection(),
                      SizedBox(height: 10),
                      CarWithPlateSection(),
                      SizedBox(height: 10),
                      SelfieWithLicenceSection(),
                      SizedBox(height: 20),
                      Divider(thickness: 0.5, color: AppColors.border),
                      SizedBox(height: 20),
                      Text(
                        AppLocalizations.of(context)!.yourStatusStaysPending,
                      ),
                      SizedBox(height: 10),
                      Text(AppLocalizations.of(context)!.ifYouUpdateDocument),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
