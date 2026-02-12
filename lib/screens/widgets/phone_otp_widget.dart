import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/profile.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/screens/widgets/error_message.dart';
import 'package:kipgo/utils/colors.dart';

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
    if (otpCode.length != 6) return;

    setState(() => verifying = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: newId ?? widget.verificationId,
        smsCode: otpCode,
      );

      final user = FirebaseAuth.instance.currentUser!;
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

      Navigator.pop(context, true); // success
    } on FirebaseAuthException catch (e) {
      setState(() {
        verifying = false;
        localError = e.message!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBarWidget(title: AppLocalizations.of(context)!.otp),
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
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.otpVerification,
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    AppLocalizations.of(
                      context,
                    )!.enterOtpCodeSent(widget.phoneNumber.toString()),
                  ),
                  SizedBox(height: 30),
                  OtpTextField(
                    numberOfFields: 6,
                    fieldWidth: 50,
                    // fieldHeight: 50,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    borderColor: AppColors.primary,
                    focusedBorderColor: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                    showFieldAsBox: true,
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    onCodeChanged: (String code) {
                      //handle validation or checks here
                    },
                    //runs when every textfield is filled
                    onSubmit: (String code) {
                      otpCode = code;
                    }, // end onSubmit
                  ),
                  SizedBox(height: 30),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      foregroundColor: Colors.white,
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: Colors.grey,
                    ),
                    onPressed: verifying ? null : _verifyOtp,
                    child: verifying
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(AppLocalizations.of(context)!.verify),
                  ),
                  if (localError != '') ...[
                    SizedBox(height: 16),
                    ErrorMessageWidget(localErrorMessage: localError),
                  ],
                  SizedBox(height: 30),
                  Text(
                    AppLocalizations.of(context)!.didntReceiveOTPCode,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black38,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.verifyPhoneNumber(
                        phoneNumber: widget.phoneNumber,
                        codeAutoRetrievalTimeout: (_) {},
                        codeSent: (newId, _) {
                          setState(() {
                            newId = newId;
                            localError = '';
                          });
                        },
                        verificationCompleted: (_) {},
                        verificationFailed: (_) {},
                      );
                    },
                    child: Text(AppLocalizations.of(context)!.resendCode),
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
