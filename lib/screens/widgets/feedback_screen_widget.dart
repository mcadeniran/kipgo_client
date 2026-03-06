import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/screens/widgets/input_decorator.dart';
import 'package:kipgo/utils/colors.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBarWidget(title: AppLocalizations.of(context)!.sendFeedback),
        backgroundColor: AppColors.primary,
        body: Container(
          padding: const EdgeInsets.all(16),
          height: double.maxFinite,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: controller,
                  maxLines: 5,
                  // decoration: const InputDecoration(
                  //   hintText: "Tell us what we can improve...",
                  //   border: OutlineInputBorder(),
                  // ),
                  decoration: inputDecoration(
                    context: context,
                    hint: AppLocalizations.of(context)!.tellUsWhatWeCanImprove,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    // Save to Firestore
                    await FirebaseFirestore.instance
                        .collection("app_feedback")
                        .add({
                          "message": controller.text.trim(),
                          "userId": FirebaseAuth.instance.currentUser!.uid,
                          "createdAt": FieldValue.serverTimestamp(),
                        });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(context)!.thanksForYourFeedback,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    foregroundColor: Colors.white,
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: Text(AppLocalizations.of(context)!.submit),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
