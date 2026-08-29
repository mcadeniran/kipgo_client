import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kipgo/controllers/auth_provider.dart';
import 'package:kipgo/controllers/car_rating_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/booking_model.dart';
import 'package:kipgo/models/car_rating_model.dart';
import 'package:kipgo/screens/widgets/reusable_toast.dart';
import 'package:kipgo/utils/car_properties_translations.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class CarReviewPage extends StatefulWidget {
  final BookingModel booking;

  const CarReviewPage({super.key, required this.booking});

  @override
  State<CarReviewPage> createState() => _CarReviewPageState();
}

class _CarReviewPageState extends State<CarReviewPage> {
  final PageController _pageController = PageController();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  int _currentPage = 0;

  // Vehicle ratings
  int _cleanliness = 0;
  int _comfort = 0;
  int _condition = 0;
  int _valueForMoney = 0;
  int _vehicleOverall = 0;

  // Rental company ratings
  int _communication = 0;
  int _pickupExperience = 0;
  int _professionalism = 0;
  int _returnExperience = 0;
  int _rentalOverall = 0;

  final List<String> _pros = [];
  final List<String> _cons = [];

  final List<File> _photos = [];

  bool? _wouldRecommend;
  bool? _wouldRentAgain;
  bool _isAnonymous = false;

  bool _isPickingPhoto = false;

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  bool get _isLastPage => _currentPage == 3;

  bool get _canContinue {
    switch (_currentPage) {
      case 0:
        return _vehicleOverall > 0 &&
            _cleanliness > 0 &&
            _comfort > 0 &&
            _condition > 0 &&
            _valueForMoney > 0;

      case 1:
        return _rentalOverall > 0 &&
            _communication > 0 &&
            _pickupExperience > 0 &&
            _professionalism > 0 &&
            _returnExperience > 0;

      case 2:
        return _titleController.text.trim().isNotEmpty &&
            _reviewController.text.trim().isNotEmpty;

      case 3:
        return _wouldRecommend != null && _wouldRentAgain != null;

      default:
        return false;
    }
  }

  Future<void> _next() async {
    FocusScope.of(context).unfocus();

    if (!_canContinue) {
      _showValidationMessage();
      return;
    }

    if (_isLastPage) {
      await _submit();
      return;
    }

    await _pageController.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _back() async {
    FocusScope.of(context).unfocus();

    if (_currentPage == 0) {
      Navigator.pop(context);
      return;
    }

    await _pageController.previousPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _showValidationMessage() {
    final loc = AppLocalizations.of(context)!;

    ReusableToast.error(
      context,
      loc.error,
      _currentPage == 0
          ? loc.pleaseRateCarAspect
          : _currentPage == 1
          ? loc.pleaseRateCompanyAspect
          : _currentPage == 2
          ? loc.pleaseAddTitleAndReview
          : loc.pleaseCompleteAllRequiredFields,
    );
  }

  Future<void> _pickPhotos() async {
    if (_isPickingPhoto || _photos.length >= 5) return;

    setState(() {
      _isPickingPhoto = true;
    });

    try {
      final remaining = 5 - _photos.length;

      final images = await _picker.pickMultiImage(
        imageQuality: 82,
        maxWidth: 1800,
        limit: remaining,
      );

      if (images.isNotEmpty) {
        final newFiles = images
            .map((image) => File(image.path))
            .take(remaining)
            .toList();

        setState(() {
          _photos.addAll(newFiles);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPickingPhoto = false;
        });
      }
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
    });
  }

  Future<void> _submit() async {
    final provider = context.read<CarRatingProvider>();

    final user = Provider.of<AuthProvider>(context, listen: false).profile;

    if (user == null) {
      return;
    }

    final details = RatingDetails(
      cons: List<String>.from(_cons),
      isAnonymous: _isAnonymous,
      ratingPhoto: const [],
      pros: List<String>.from(_pros),
      review: _reviewController.text.trim(),
      title: _titleController.text.trim(),
      wouldRecommend: _wouldRecommend!,
      wouldRentAgain: _wouldRentAgain!,
    );

    final rental = RatingRental(
      communication: _communication,
      overall: _rentalOverall,
      pickupExperience: _pickupExperience,
      professionalism: _professionalism,
      returnExperience: _returnExperience,
    );

    final vehicle = RatingVehicle(
      cleanliness: _cleanliness,
      comfort: _comfort,
      condition: _condition,
      overall: _vehicleOverall,
      valueForMoney: _valueForMoney,
    );

    await provider.submitReview(
      booking: widget.booking,
      details: details,
      rental: rental,
      vehicle: vehicle,
      photos: _photos,
      userId: user.id,
      userName: user.username,
      photoUrl: user.personal.photoUrl,
    );

    if (!mounted) return;

    if (provider.success) {
      await _showSuccessDialog();
      if (!mounted) return;

      provider.clearSuccess();
    } else if (provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error!),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showSuccessDialog() async {
    final loc = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Dialog(
          backgroundColor: theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 76,
                  width: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.secondary.withValues(alpha: .12),
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 40,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  loc.thankYou,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  loc.yourReviewSubmitted,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white60 : Colors.black54,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop(true);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      loc.done,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!;
    return ChangeNotifierProvider(
      create: (_) => CarRatingProvider(),
      child: Consumer<CarRatingProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: theme.scaffoldBackgroundColor,
              surfaceTintColor: Colors.transparent,
              leading: IconButton(
                onPressed: provider.isSubmitting ? null : _back,
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.leaveReview,
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                  ),
                  Text(
                    loc.stepCount((_currentPage + 1), 4),
                    // 'Step ${_currentPage + 1} of 4',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white54 : Colors.black45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            body: Column(
              children: [
                _buildProgressIndicator(isDark),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: [
                      _buildVehiclePage(isDark, loc),
                      _buildRentalPage(isDark, loc),
                      _buildDetailsPage(isDark, loc),
                      _buildFinalPage(isDark, loc),
                    ],
                  ),
                ),
                _buildBottomBar(isDark, provider, loc),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
      child: Row(
        children: List.generate(4, (index) {
          final active = index <= _currentPage;

          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.only(right: index == 3 ? 0 : 5),
              height: 4,
              decoration: BoxDecoration(
                color: active
                    ? (isDark ? AppColors.lightLayer : AppColors.primary)
                    : (isDark ? Colors.white12 : Colors.black12),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildVehiclePage(bool isDark, AppLocalizations loc) {
    return _buildScrollablePage(
      children: [
        _buildBookingHeader(isDark, loc, context),
        const SizedBox(height: 24),
        _buildSectionIntro(
          icon: Icons.directions_car_filled_rounded,
          title: loc.howWasTheCar,
          subtitle: loc.tellUsAboutVehicle,
          isDark: isDark,
        ),
        const SizedBox(height: 24),
        _buildRatingCard(
          title: loc.overallRating,
          subtitle: loc.yourOverallExperienceCar,
          value: _vehicleOverall,
          onChanged: (value) {
            setState(() => _vehicleOverall = value);
          },
          isDark: isDark,
          emphasized: true,
        ),
        const SizedBox(height: 12),
        _buildRatingCard(
          title: loc.cleanliness,
          subtitle: loc.howCleanWasTheVehicle,
          value: _cleanliness,
          onChanged: (value) {
            setState(() => _cleanliness = value);
          },
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildRatingCard(
          title: loc.comfort,
          subtitle: loc.howComfortable,
          value: _comfort,
          onChanged: (value) {
            setState(() => _comfort = value);
          },
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildRatingCard(
          title: loc.condition,
          subtitle: loc.howWellMaintained,
          value: _condition,
          onChanged: (value) {
            setState(() => _condition = value);
          },
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildRatingCard(
          title: loc.valueForMoney,
          subtitle: loc.wasTheRentalWorth,
          value: _valueForMoney,
          onChanged: (value) {
            setState(() => _valueForMoney = value);
          },
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildRentalPage(bool isDark, AppLocalizations loc) {
    return _buildScrollablePage(
      children: [
        _buildCompanyHeader(isDark, loc),
        const SizedBox(height: 24),
        _buildSectionIntro(
          icon: Icons.business_rounded,
          title: loc.howWasTheRentalCompany,
          subtitle: loc.yourFeedbackHelpsImproveRental,
          isDark: isDark,
        ),
        const SizedBox(height: 24),
        _buildRatingCard(
          title: loc.overallRating,
          subtitle: loc.yourOverallExperienceCompany,
          value: _rentalOverall,
          onChanged: (value) {
            setState(() => _rentalOverall = value);
          },
          isDark: isDark,
          emphasized: true,
        ),
        const SizedBox(height: 12),
        _buildRatingCard(
          title: loc.communication,
          subtitle: loc.howResponsiveAndHelpful,
          value: _communication,
          onChanged: (value) {
            setState(() => _communication = value);
          },
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildRatingCard(
          title: loc.pickupExperience,
          subtitle: loc.howSmoothWasThePickup,
          value: _pickupExperience,
          onChanged: (value) {
            setState(() => _pickupExperience = value);
          },
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildRatingCard(
          title: loc.professionalism,
          subtitle: loc.howProfessional,
          value: _professionalism,
          onChanged: (value) {
            setState(() => _professionalism = value);
          },
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildRatingCard(
          title: loc.returnExperience,
          subtitle: loc.howSmoothWasReturning,
          value: _returnExperience,
          onChanged: (value) {
            setState(() => _returnExperience = value);
          },
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildDetailsPage(bool isDark, AppLocalizations loc) {
    return _buildScrollablePage(
      children: [
        _buildSectionIntro(
          icon: Icons.rate_review_rounded,
          title: loc.tellUsMore,
          subtitle: loc.shareTheDetailsForFutureRenters,
          isDark: isDark,
        ),
        const SizedBox(height: 24),
        _buildTextField(
          controller: _titleController,
          label: loc.reviewTitle,
          hint: loc.giveShortTitle,
          maxLength: 80,
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _reviewController,
          label: loc.yourReview,
          hint: loc.whatDidYouLike,
          maxLength: 1000,
          maxLines: 6,
          isDark: isDark,
        ),
        const SizedBox(height: 26),
        _buildTagSection(
          title: loc.whatDidYouLikeQ,
          subtitle: loc.selectEverything,
          tags: [
            loc.clean,
            loc.comfortable,
            loc.wellMaintained,
            loc.smoothDrive,
            loc.fuelEfficient,
            loc.greatValue,
            loc.easyPickup,
            loc.friendlyStaff,
          ],
          selected: _pros,
          onChanged: (value) {
            setState(() {
              if (_pros.contains(value)) {
                _pros.remove(value);
              } else {
                _pros.add(value);
              }
            });
          },
          isDark: isDark,
          positive: true,
        ),
        const SizedBox(height: 24),
        _buildTagSection(
          title: loc.whatCouldBeBetter,
          subtitle: loc.optionalHelpFutureRenters,
          tags: [
            loc.pickupTookTooLong,
            loc.carShowedSomeWear,
            loc.limitedFeatures,
            loc.expensive,
            loc.difficultReturn,
            loc.communication,
            loc.location,
            loc.openingHours,
          ],
          selected: _cons,
          onChanged: (value) {
            setState(() {
              if (_cons.contains(value)) {
                _cons.remove(value);
              } else {
                _cons.add(value);
              }
            });
          },
          isDark: isDark,
          positive: false,
        ),
        const SizedBox(height: 24),
        _buildPhotoSection(isDark, loc),
      ],
    );
  }

  Widget _buildFinalPage(bool isDark, AppLocalizations loc) {
    return _buildScrollablePage(
      children: [
        _buildSectionIntro(
          icon: Icons.auto_awesome_rounded,
          title: loc.oneLastThing,
          subtitle: loc.yourAnswersHelp,
          isDark: isDark,
        ),
        const SizedBox(height: 28),
        _buildYesNoCard(
          title: loc.wouldRecommendQ,
          icon: Icons.thumb_up_alt_rounded,
          value: _wouldRecommend,
          onChanged: (value) {
            setState(() => _wouldRecommend = value);
          },
          isDark: isDark,
          loc: loc,
        ),
        const SizedBox(height: 16),
        _buildYesNoCard(
          title: loc.wouldRentAgainQ,
          icon: Icons.replay_rounded,
          value: _wouldRentAgain,
          onChanged: (value) {
            setState(() => _wouldRentAgain = value);
          },
          isDark: isDark,
          loc: loc,
        ),
        const SizedBox(height: 24),
        _buildAnonymousCard(isDark, loc),
        const SizedBox(height: 24),
        _buildReviewSummary(isDark, loc),
      ],
    );
  }

  Widget _buildScrollablePage({required List<Widget> children}) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildBookingHeader(
    bool isDark,
    AppLocalizations loc,
    BuildContext context,
  ) {
    final car = widget.booking.car;

    return _buildEntityCard(
      imageUrl: car.carImage,
      title: '${car.brand} ${car.model}',
      subtitle:
          '${car.year} •  ${carPropertiesTranslations(context, car.transmission)}',
      trailing: loc.yourRental,
      isDark: isDark,
    );
  }

  Widget _buildCompanyHeader(bool isDark, AppLocalizations loc) {
    return _buildEntityCard(
      imageUrl: widget.booking.shop.logo,
      title: widget.booking.shop.name,
      subtitle: '${widget.booking.shop.city}, ${widget.booking.shop.district}',
      trailing: loc.rentalCompany,
      isDark: isDark,
      isCompany: true,
    );
  }

  Widget _buildEntityCard({
    required String imageUrl,
    required String title,
    required String subtitle,
    required String trailing,
    required bool isDark,
    bool isCompany = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkAccent : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: .06)
              : Colors.black.withValues(alpha: .05),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 68,
              width: 76,
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) {
                        return _imagePlaceholder(isDark, isCompany);
                      },
                    )
                  : _imagePlaceholder(isDark, isCompany),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.lightLayer.withValues(alpha: 0.08)
                  : AppColors.primary.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              trailing,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.lightLayer : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder(bool isDark, bool company) {
    return Container(
      color: isDark
          ? AppColors.lightLayer.withValues(alpha: .08)
          : AppColors.primary.withValues(alpha: .06),
      child: Icon(
        company ? Icons.business_rounded : Icons.directions_car_rounded,
        color: isDark ? AppColors.lightLayer : AppColors.primary,
        size: 30,
      ),
    );
  }

  Widget _buildSectionIntro({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.lightLayer.withValues(alpha: 0.25)
                : AppColors.primary.withValues(alpha: .09),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: isDark ? AppColors.lightLayer : AppColors.primary,
            size: 23,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingCard({
    required String title,
    required String subtitle,
    required int value,
    required ValueChanged<int> onChanged,
    required bool isDark,
    bool emphasized = false,
  }) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkAccent : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: value > 0
              ? AppColors.primary.withValues(alpha: .16)
              : (isDark
                    ? Colors.white.withValues(alpha: .06)
                    : Colors.black.withValues(alpha: .05)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: emphasized ? 15 : 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (value > 0) _ratingLabel(value, loc, isDark),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11.5,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
          const SizedBox(height: 13),
          _buildStars(
            value: value,
            onChanged: onChanged,
            size: emphasized ? 30 : 27,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _ratingLabel(int value, AppLocalizations loc, bool isDark) {
    final labels = {
      1: loc.poor,
      2: loc.fair,
      3: loc.good,
      4: loc.veryGood,
      5: loc.excellent,
    };

    return Text(
      labels[value] ?? '',
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: isDark ? AppColors.lightLayer : AppColors.primary,
      ),
    );
  }

  Widget _buildStars({
    required int value,
    required ValueChanged<int> onChanged,
    required double size,
    required bool isDark,
  }) {
    return Row(
      children: List.generate(5, (index) {
        final rating = index + 1;
        final selected = rating <= value;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(rating),
          child: Padding(
            padding: const EdgeInsets.only(right: 7),
            child: AnimatedScale(
              duration: const Duration(milliseconds: 120),
              scale: selected ? 1.0 : .94,
              child: Icon(
                selected ? Icons.star_rounded : Icons.star_border_rounded,
                size: size,
                color: selected
                    ? AppColors.secondary
                    : (isDark ? Colors.white24 : Colors.black26),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 9),
        TextField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          onChanged: (_) => setState(() {}),
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: isDark ? AppColors.darkAccent : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white10
                    : Colors.black.withValues(alpha: .07),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white10
                    : Colors.black.withValues(alpha: .07),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: AppColors.primary.withValues(alpha: .4),
                width: 1.3,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagSection({
    required String title,
    required String subtitle,
    required List<String> tags,
    required List<String> selected,
    required ValueChanged<String> onChanged,
    required bool isDark,
    required bool positive,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 11.5,
            color: isDark ? Colors.white54 : Colors.black45,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags.map((tag) {
            final isSelected = selected.contains(tag);

            return FilterChip(
              label: Text(
                tag,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
              selected: isSelected,
              onSelected: (_) => onChanged(tag),
              showCheckmark: false,
              avatar: Icon(
                isSelected
                    ? Icons.check_rounded
                    : positive
                    ? Icons.add_rounded
                    : Icons.remove_rounded,
                size: 16,
                color: isSelected
                    ? (isDark ? AppColors.lightLayer : AppColors.primary)
                    : (isDark ? Colors.white54 : Colors.black45),
              ),
              selectedColor: isDark
                  ? AppColors.lightLayer.withValues(alpha: 0.2)
                  : AppColors.primary.withValues(alpha: .1),
              backgroundColor: isDark ? AppColors.darkAccent : Colors.white,
              side: BorderSide(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: .3)
                    : (isDark
                          ? Colors.white10
                          : Colors.black.withValues(alpha: .07)),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPhotoSection(bool isDark, AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                loc.addPhotos,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
            ),
            Text(
              '${_photos.length}/5',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          loc.showFutureRenters,
          style: TextStyle(
            fontSize: 11.5,
            color: isDark ? Colors.white54 : Colors.black45,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 92,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              if (_photos.length < 5)
                GestureDetector(
                  onTap: _pickPhotos,
                  child: Container(
                    height: 92,
                    width: 92,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.lightLayer.withValues(alpha: 0.08)
                          : AppColors.primary.withValues(alpha: .07),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: .18),
                      ),
                    ),
                    child: _isPickingPhoto
                        ? const Center(
                            child: SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo_rounded,
                                color: isDark
                                    ? AppColors.lightLayer
                                    : AppColors.primary,
                                size: 24,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                loc.add,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.lightLayer
                                      : AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ...List.generate(_photos.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 9),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.file(
                          _photos[index],
                          height: 92,
                          width: 92,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: () => _removePhoto(index),
                          child: Container(
                            height: 25,
                            width: 25,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: .65),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildYesNoCard({
    required String title,
    required IconData icon,
    required bool? value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
    required AppLocalizations loc,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkAccent : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: .06)
              : Colors.black.withValues(alpha: .05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.lightLayer.withValues(alpha: .08)
                      : AppColors.primary.withValues(alpha: .08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 19,
                  color: isDark ? AppColors.lightLayer : AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildChoiceButton(
                  label: loc.yes,
                  selected: value == true,
                  icon: Icons.thumb_up_alt_rounded,
                  onTap: () => onChanged(true),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildChoiceButton(
                  label: loc.no,
                  selected: value == false,
                  icon: Icons.thumb_down_alt_rounded,
                  onTap: () => onChanged(false),
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceButton({
    required String label,
    required bool selected,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 50,
        decoration: BoxDecoration(
          color: selected
              ? (isDark
                    ? AppColors.lightLayer.withValues(alpha: .1)
                    : AppColors.primary.withValues(alpha: .1))
              : (isDark
                    ? Colors.white.withValues(alpha: .03)
                    : Colors.black.withValues(alpha: .025)),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: .35)
                : (isDark
                      ? Colors.white10
                      : Colors.black.withValues(alpha: .06)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 17,
              color: selected
                  ? (isDark ? AppColors.lightLayer : AppColors.primary)
                  : (isDark ? Colors.white54 : Colors.black45),
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected
                    ? (isDark ? AppColors.lightLayer : AppColors.primary)
                    : (isDark ? Colors.white70 : Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnonymousCard(bool isDark, AppLocalizations loc) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkAccent : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: .06)
              : Colors.black.withValues(alpha: .05),
        ),
      ),
      child: SwitchListTile.adaptive(
        value: _isAnonymous,
        onChanged: (value) {
          setState(() => _isAnonymous = value);
        },
        title: Text(
          loc.postAnonymously,
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
        ),
        subtitle: Text(
          loc.yourNameAndProfileWillBeHidden,
          style: TextStyle(
            fontSize: 11.5,
            color: isDark ? Colors.white54 : Colors.black45,
          ),
        ),
        secondary: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.lightLayer.withValues(alpha: .08)
                : AppColors.primary.withValues(alpha: .08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.visibility_off_rounded,
            size: 19,
            color: isDark ? AppColors.lightLayer : AppColors.primary,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      ),
    );
  }

  Widget _buildReviewSummary(bool isDark, AppLocalizations loc) {
    final average = [
      _vehicleOverall,
      _cleanliness,
      _comfort,
      _condition,
      _valueForMoney,
      _rentalOverall,
      _communication,
      _pickupExperience,
      _professionalism,
      _returnExperience,
    ].where((value) => value > 0);

    final score = average.isEmpty
        ? 0
        : average.reduce((a, b) => a + b) / average.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: .82)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                score == 0 ? '—' : score.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.almostThere,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  loc.yourFeedbackCanHelp,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .75),
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
    bool isDark,
    CarRatingProvider provider,
    AppLocalizations loc,
  ) {
    // final bool submitting = provider.isSubmitting;
    final bool submitting = context.watch<CarRatingProvider>().isSubmitting;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? .2 : .06),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: FilledButton(
          onPressed: submitting ? null : _next,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: .55),
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(17),
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: submitting
                ? Row(
                    key: ValueKey('submitting'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        loc.submitting,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  )
                : Row(
                    key: const ValueKey('normal'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLastPage ? loc.submitReview : loc.continueAction,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _isLastPage
                            ? Icons.check_rounded
                            : Icons.arrow_forward_rounded,
                        size: 18,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
