import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:kipgo/controllers/car_rating_provider.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/profile.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/screens/widgets/input_decorator.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class CarRatingPage extends StatefulWidget {
  final String bookingId;
  final String carId;
  final String shopId;

  const CarRatingPage({
    super.key,
    required this.bookingId,
    required this.carId,
    required this.shopId,
  });

  @override
  State<CarRatingPage> createState() => _CarRatingPageState();
}

class _CarRatingPageState extends State<CarRatingPage> {
  double carRating = 2.5;
  double companyRating = 2.5;
  final TextEditingController reviewController = TextEditingController();
  late Profile user;
  late AppLocalizations loc;

  @override
  void initState() {
    super.initState();
    user = Provider.of<ProfileProvider>(context, listen: false).profile!;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loc = AppLocalizations.of(context)!;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CarRatingProvider>(context);

    return Scaffold(
      appBar: AppBarWidget(title: loc.rateYourExperience),
      backgroundColor: AppColors.primary,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Container(
          width: double.maxFinite,
          height: double.maxFinite,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(loc.rateCar),
                StarRating(
                  starCount: 5,
                  rating: carRating,
                  allowHalfRating: true,
                  color: Colors.amber,
                  size: 32,
                  onRatingChanged: (val) => setState(() => carRating = val),
                ),

                const SizedBox(height: 20),

                Text(loc.rateCompany),
                StarRating(
                  starCount: 5,
                  rating: companyRating,
                  allowHalfRating: true,
                  color: Colors.amber,
                  size: 32,
                  onRatingChanged: (val) => setState(() => companyRating = val),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: reviewController,
                  maxLines: 3,
                  decoration: inputDecoration(
                    context: context,
                    hint: loc.writeAReview,
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
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
                  onPressed: provider.loading
                      ? null
                      : () async {
                          await provider.submitRating(
                            bookingId: widget.bookingId,
                            carId: widget.carId,
                            shopId: widget.shopId,
                            userId: user.id,
                            userName: user.username,
                            userImage: user.personal.photoUrl,
                            carRating: carRating,
                            companyRating: companyRating,
                            review: reviewController.text,
                          );

                          Navigator.pop(context);
                        },
                  child: provider.loading
                      ? const CircularProgressIndicator()
                      : Text(loc.submit),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
