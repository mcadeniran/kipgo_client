import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/main.dart';
import 'package:kipgo/screens/widgets/feedback_screen_widget.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class AppReviewProvider extends ChangeNotifier {
  bool _isRideRatingVisible = false;
  bool _pendingPrompt = false;

  bool get isRideRatingVisible => _isRideRatingVisible;

  void setRideRatingVisible(bool value) {
    _isRideRatingVisible = value;

    if (!value && _pendingPrompt) {
      _showRatingBottomSheet();
    }
  }

  Future<void> checkAndTriggerReview() async {
    debugPrint("CHECKING AND TRIGGERING REVIEW");
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('profiles')
        .doc(uid)
        .get();

    if (!doc.exists) return;

    final data = doc.data()!;
    final shouldShow = data['shouldShowRatingPrompt'] ?? false;

    if (!shouldShow) return;

    final lastRequested = data['appReview']?['lastRequestedAt'];

    if (lastRequested != null) {
      final lastDate = (lastRequested as Timestamp).toDate();
      if (DateTime.now().difference(lastDate).inDays < 30) {
        return;
      }
    }

    if (_isRideRatingVisible) {
      _pendingPrompt = true;
      return;
    }

    _showRatingBottomSheet();
  }

  Future<void> _showRatingBottomSheet() async {
    final ctx = navigatorKey.currentState?.overlay?.context;
    if (ctx == null) return;

    await Future.delayed(const Duration(seconds: 3));

    showModalBottomSheet(
      context: ctx,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const AppRatingBottomSheet(),
    );

    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('profiles').doc(uid).update({
      "shouldShowRatingPrompt": false,
      "appReview.hasRequestedReview": true,
      "appReview.lastRequestedAt": FieldValue.serverTimestamp(),
      "appReview.totalRequests": FieldValue.increment(1),
    });

    _pendingPrompt = false;
  }

  Future<void> openStoreReview() async {
    debugPrint("CALLING OPEN STORE REVIEW");
    final review = InAppReview.instance;

    if (await review.isAvailable()) {
      debugPrint("In App Review Available");
      await review.requestReview();
      // await review.openStoreListing();
    } else {
      debugPrint("In App Review Not Available");
    }
  }
}

class AppRatingBottomSheet extends StatelessWidget {
  const AppRatingBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppLocalizations.of(context)!.areYouEnjoyingKipgo,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.weLoveToHear,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      navigatorKey.currentContext!,
                      MaterialPageRoute(builder: (_) => const FeedbackScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.tertiary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(AppLocalizations.of(context)!.notReally),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await context.read<AppReviewProvider>().openStoreReview();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(AppLocalizations.of(context)!.yes),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
