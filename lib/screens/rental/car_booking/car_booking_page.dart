import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kipgo/controllers/car_booking_provider.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/booking_model.dart';
import 'package:kipgo/models/booking_step.dart';
import 'package:kipgo/models/car_unit.dart';
import 'package:kipgo/models/car_with_shop_model.dart';
import 'package:kipgo/models/profile.dart';
import 'package:kipgo/screens/rental/car_booking/booking_payment_step.dart';
import 'package:kipgo/screens/rental/car_booking/booking_success_page.dart';
import 'package:kipgo/screens/rental/car_booking/booking_summary.dart';
import 'package:kipgo/screens/rental/car_booking/crypto_payment_page.dart';
import 'package:kipgo/screens/rental/car_booking/driver_booking_details.dart';
import 'package:kipgo/screens/rental/car_booking/driver_documents_step.dart';
import 'package:kipgo/screens/rental/car_booking/driver_selector.dart';
import 'package:kipgo/screens/rental/car_booking/pick_image.dart';
import 'package:kipgo/screens/rental/widgets/premium_booking_stepper.dart';
import 'package:kipgo/screens/rental/car_booking/schedule_booking_details.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:kipgo/utils/invoice_generator.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

enum DeliveryType { pickup, delivery }

enum PaymentMethod {
  // card,
  // bankTransfer,
  crypto,
  payOnPickup,
}

class CarBookingPage extends StatefulWidget {
  final CarWithShop car;
  const CarBookingPage({super.key, required this.car});

  @override
  State<CarBookingPage> createState() => _CarBookingPageState();
}

class _CarBookingPageState extends State<CarBookingPage> {
  final _driverFormKey = GlobalKey<FormState>();
  late CarBookingProvider provider;
  // DriverProfile? selectedDriver;

  DeliveryType deliveryType = DeliveryType.pickup;
  PaymentMethod selectedPaymentMethod = PaymentMethod.crypto;
  int currentStep = 0;

  late AppLocalizations loc;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController dobController = TextEditingController();

  final List<String> genders = ["Male", "Female", "Others"];
  late String selectedGender = genders[0];

  late DateTime pickupDate;
  late DateTime dropoffDate;
  late double dailyPrice;
  double rentalPrice = 0;
  late double deliveryPrice;
  TextEditingController deliveryAddress = TextEditingController();
  TextEditingController additionalNote = TextEditingController();
  int rentalDays = 3;
  late double deposit;

  String? licenseFront;
  String? licenseBack;
  String? idCard;

  File? licenseFrontFile;
  File? licenseBackFile;
  File? idCardFile;

  String? licenseFrontUrl;
  String? licenseBackUrl;
  String? idCardUrl;

  bool isLoading = false;

  bool isBooking = false;

  Future<String> saveDriverProfile() async {
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

    final uid = profileProvider.profile!.id;

    licenseFrontUrl = await provider.uploadFile(
      file: licenseFrontFile,
      userId: uid,
    );
    licenseBackUrl = await provider.uploadFile(
      file: licenseBackFile,
      userId: uid,
    );
    idCardUrl = await provider.uploadFile(file: idCardFile, userId: uid);

    final doc = FirebaseFirestore.instance
        .collection("profiles")
        .doc(uid)
        .collection("renters")
        .doc();

    await doc.set({
      "name": nameController.text,
      "licenseName": nameController.text,
      "email": emailController.text,
      "phone": phoneController.text,
      "gender": selectedGender,
      "dob": dobController.text,
      "licenseFront": licenseFrontUrl,
      "licenseBack": licenseBackUrl,
      "idCard": idCardUrl,
      "createdAt": FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  Future<void> createBooking() async {
    final confirmed = await showBookingConfirmation();

    if (!confirmed) return;
    setState(() {
      isBooking = true;
    });
    // provider.setBooking(true);
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

    final uid = profileProvider.profile!.id;

    String driverId;

    if (provider.selectedDriver == null) {
      driverId = await saveDriverProfile();
    } else {
      driverId = provider.selectedDriver!.id;

      if (hasDriverChanged()) {
        if (licenseFrontFile != null) {
          licenseFrontUrl = await provider.uploadFile(
            file: licenseFrontFile,
            userId: uid,
          );
        } else {
          licenseFrontUrl = provider.selectedDriver!.licenseFrontUrl;
        }

        if (licenseBackFile != null) {
          licenseBackUrl = await provider.uploadFile(
            file: licenseBackFile,
            userId: uid,
          );
        } else {
          licenseBackUrl = provider.selectedDriver!.licenseBackUrl;
        }

        if (idCardFile != null) {
          idCardUrl = await provider.uploadFile(file: idCardFile, userId: uid);
        } else {
          idCardUrl = provider.selectedDriver!.idCardUrl;
        }

        // 🔥 Update ALL fields (text + images)
        await FirebaseFirestore.instance
            .collection("profiles")
            .doc(uid)
            .collection("renters")
            .doc(provider.selectedDriver!.id)
            .update({
              "name": nameController.text,
              "email": emailController.text,
              "phone": phoneController.text,
              "dob": dobController.text,
              "gender": selectedGender,

              "licenseFront": licenseFrontUrl,
              "licenseBack": licenseBackUrl,
              "idCard": idCardUrl,

              "updatedAt": FieldValue.serverTimestamp(),
            });
      } else {
        // ✅ No changes → reuse existing
        licenseFrontUrl = provider.selectedDriver!.licenseFrontUrl;
        licenseBackUrl = provider.selectedDriver!.licenseBackUrl;
        idCardUrl = provider.selectedDriver!.idCardUrl;
      }
    }

    final invoiceNumber = generateInvoiceNumber();

    final double tempDelivery = deliveryType == DeliveryType.delivery
        ? deliveryPrice
        : 0;

    final double preTax = rentalPrice + tempDelivery;

    final double taxAmount = widget.car.shop.taxRate * preTax;

    final double totalPrice = preTax + taxAmount + deposit;

    final bookingId = await provider.createBooking(
      invoiceNumber: invoiceNumber,
      userId: uid,
      driverId: driverId,
      car: widget.car,
      pickupDate: pickupDate,
      dropoffDate: dropoffDate,
      deliveryType: deliveryType.name,
      deliveryAddress: deliveryAddress.text.trim(),
      rentalPrice: rentalPrice,
      deliveryPrice: tempDelivery,
      deposit: deposit,
      note: additionalNote.text.trim(),
      preTax: preTax,
      taxAmount: taxAmount,
      totalPrice: totalPrice,
      name: nameController.text,
      phone: phoneController.text,
      email: emailController.text,
      dob: dobController.text,
      gender: selectedGender,
      licenseFront: licenseFrontUrl!,
      licenseBack: licenseBackUrl!,
      idCard: idCardUrl!,
      paymentMethod: selectedPaymentMethod.name,
      currency: widget.car.car.currency != null
          ? widget.car.car.currency!
          : widget.car.shop.currency,
    );

    if (bookingId == null) {
      setState(() {
        isBooking = false;
      });
      // SHOW ERROR TOAST
      return;
    }

    // provider.setBooking(false);

    if (!mounted) return;
    setState(() {
      isBooking = false;
    });
    if (selectedPaymentMethod == PaymentMethod.crypto) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CryptoPaymentPage(bookingId: bookingId),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BookingSuccessPage(invoiceNumber: invoiceNumber),
        ),
      );
    }
  }

  bool hasDriverChanged() {
    return nameController.text != provider.selectedDriver!.name ||
        emailController.text != provider.selectedDriver!.email ||
        phoneController.text != provider.selectedDriver!.phone ||
        dobController.text != provider.selectedDriver!.dob ||
        selectedGender != provider.selectedDriver!.gender ||
        licenseFrontFile != null ||
        licenseBackFile != null ||
        idCardFile != null;
  }

  Future<bool> showBookingConfirmation() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              shape: BeveledRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(8),
              ),
              surfaceTintColor: Colors.transparent,
              title: Text(loc.confirmBooking),
              content: Text(loc.areYouSureBookingSubmit),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: Text(loc.cancel),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.lightAccent,
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: Text(loc.continueAction),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  void initState() {
    super.initState();
    provider = context.read<CarBookingProvider>();
    Profile user = Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).profile!;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        isLoading = true;
      });
      await provider.loadDrivers(user.id);
      await provider.loadBookings(widget.car.car.id);
      await provider.loadUnits(widget.car.car.id);
      await provider.loadWallet();

      if (provider.drivers.isEmpty) {
        nameController.text =
            "${user.personal.firstName} ${user.personal.lastName}";
        phoneController.text = user.personal.phone;
        emailController.text = user.email;
      }

      setState(() {
        isLoading = false;
      });
    });

    pickupDate = DateTime.now();
    dropoffDate = pickupDate.add(Duration(days: 3));

    dailyPrice = widget.car.finalPrice;
    rentalPrice = 3 * dailyPrice * 1.0;
    deliveryPrice = widget.car.car.deliveryPrice;
    deposit = widget.car.car.deposit;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loc = AppLocalizations.of(context)!;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dobController.dispose();
    deliveryAddress.dispose();
    additionalNote.dispose();
    super.dispose();
  }

  bool validateDocuments() {
    if ((licenseFront == null && licenseFrontUrl == null) ||
        (licenseBack == null && licenseBackUrl == null) ||
        (idCard == null && idCardUrl == null)) {
      toastification.show(
        context: context,
        type: ToastificationType.error,
        title: Text(loc.error),
        description: Text(loc.allDriverDocumentsAreRequired),
      );
      return false;
    }
    return true;
  }

  DateTime normalize(DateTime d) {
    return DateTime(d.year, d.month, d.day);
  }

  bool validateScheduleStep() {
    final normalizedPickup = normalize(pickupDate);
    final normalizedDropoff = normalize(dropoffDate);

    /// --------------------------------------------------------
    /// DATE SELECTION
    /// --------------------------------------------------------

    // Prevent unselected/default dates
    if (dropoffDate.isBefore(pickupDate) ||
        dropoffDate.isAtSameMomentAs(pickupDate)) {
      _showError(loc.invalidRentalPeriod);
      return false;
    }

    if (!normalizedDropoff.isAfter(normalizedPickup)) {
      _showError(loc.invalidRentalPeriod);
      return false;
    }

    /// --------------------------------------------------------
    /// BLOCKED DATE VALIDATION
    /// Revalidate availability before continuing
    /// --------------------------------------------------------

    final blockedDates = getFullyBookedDates(
      units: provider.units,
      bookings: provider.bookings,
    );

    // final normalizedPickup = DateTime(
    //   pickupDate.year,
    //   pickupDate.month,
    //   pickupDate.day,
    // );

    // final normalizedDropoff = DateTime(
    //   dropoffDate.year,
    //   dropoffDate.month,
    //   dropoffDate.day,
    // );

    // Pickup became unavailable
    if (blockedDates.contains(normalizedPickup)) {
      _showError(loc.selectedPickupDateUnavailable);
      return false;
    }

    // Dropoff became unavailable
    if (blockedDates.contains(normalizedDropoff)) {
      _showError(loc.selectedDropoffDateUnavailable);
      return false;
    }

    /// --------------------------------------------------------
    /// RANGE VALIDATION
    /// Ensure no blocked dates inside selected range
    /// --------------------------------------------------------

    DateTime current = normalizedPickup;

    // while (!current.isAfter(normalizedDropoff)) {
    //   if (blockedDates.contains(current)) {
    //     _showError(loc.selectedRangeContainsUnavailableDates);
    //     return false;
    //   }

    //   current = current.add(const Duration(days: 1));
    // }
    while (true) {
      if (blockedDates.contains(current)) {
        _showError(loc.selectedRangeContainsUnavailableDates);
        return false;
      }

      if (current.isAfter(normalizedDropoff)) break;

      current = current.add(const Duration(days: 1));
    }

    /// --------------------------------------------------------
    /// MINIMUM RENTAL DAYS
    /// --------------------------------------------------------
    final rentalDays = normalizedDropoff.difference(normalizedPickup).inDays;
    // if (rentalDays < 3) {
    //   _showError(loc.rentalMustBeAtLeast1Day);
    //   return false;
    // }

    if (rentalDays < 3) {
      _showError(loc.rentalMustBeAtLeast1Day);
      return false;
    }

    /// --------------------------------------------------------
    /// DELIVERY VALIDATION
    /// --------------------------------------------------------

    if (deliveryType == DeliveryType.delivery &&
        deliveryAddress.text.trim().isEmpty) {
      _showError(loc.deliveryAddressIsRequired);
      return false;
    }

    return true;
  }

  Set<DateTime> getFullyBookedDates({
    required List<CarUnit> units,
    required List<BookingModel> bookings,
  }) {
    final Map<DateTime, int> bookingCountPerDay = {};

    DateTime normalizeDate(DateTime date) {
      return DateTime(date.year, date.month, date.day);
    }

    for (final booking in bookings) {
      if (booking.status == 'cancelled' ||
          booking.status == 'rejected' ||
          booking.status == 'expired') {
        continue;
      }

      DateTime current = normalizeDate(booking.pickupDate);

      final dropoff = normalizeDate(booking.dropoffDate);

      while (!current.isAfter(dropoff)) {
        bookingCountPerDay[current] = (bookingCountPerDay[current] ?? 0) + 1;

        current = current.add(const Duration(days: 1));
      }
    }

    final totalAvailableUnits = units
        .where((e) => e.status == "available")
        .length;

    return bookingCountPerDay.entries
        .where((entry) => entry.value >= totalAvailableUnits)
        .map((entry) => normalizeDate(entry.key))
        .toSet();
  }

  void _showError(String msg) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      title: Text(loc.error),
      description: Text(msg),
    );
  }

  @override
  Widget build(BuildContext context) {
    // bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldLeave = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(loc.leaveBookingFlow),
              content: Text(loc.leaveBookingWarning),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: Text(loc.cancel),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: Text(loc.leave),
                ),
              ],
            );
          },
        );

        if (shouldLeave == true && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBarWidget(title: loc.bookingDetails),
        backgroundColor: AppColors.primary,
        body: Container(
          width: double.maxFinite,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: isLoading
              ? Center(child: CircularProgressIndicator.adaptive())
              : PremiumBookingStepper(
                  steps: [
                    BookingStep(
                      title: loc.schedule,
                      content: Form(
                        key: _driverFormKey,
                        child: ScheduleBookingDetails(
                          pickupDate: pickupDate,
                          dropoffDate: dropoffDate,
                          rentalPrice: rentalPrice,
                          deliveryPrice: deliveryPrice,
                          deliveryAddress: deliveryAddress,
                          additionalNote: additionalNote,
                          deliveryType: deliveryType,
                          rentalDays: rentalDays,
                          dailyPrice: dailyPrice,
                          bookings: provider.bookings,
                          units: provider.units,
                          offersDelivery: widget.car.car.offersDelivery,
                          currency: widget.car.car.currency != null
                              ? widget.car.car.currency!
                              : widget.car.shop.currency,
                          onDateChanged: (pickup, dropoff, total) {
                            setState(() {
                              pickupDate = pickup;
                              dropoffDate = dropoff;
                              rentalPrice = total.toDouble();
                              rentalDays = dropoffDate
                                  .difference(pickupDate)
                                  .inDays;
                            });
                          },
                          onDeliveryTypeChanged: (type) {
                            setState(() {
                              deliveryType = type;
                              deliveryPrice = type == DeliveryType.delivery
                                  ? widget.car.car.deliveryPrice
                                  : 0;
                            });
                          },
                        ),
                      ),
                    ),
                    BookingStep(
                      title: loc.driver,
                      content: Form(
                        key: _driverFormKey,
                        child: Column(
                          children: [
                            DriverSelector(
                              drivers: provider.drivers,
                              selected: provider.selectedDriver,
                              onSelect: (driver) {
                                setState(() {
                                  provider.selectedDriver = driver;

                                  nameController.text = driver.name;
                                  emailController.text = driver.email;
                                  phoneController.text = driver.phone;
                                  dobController.text = driver.dob;
                                  licenseFrontUrl = driver.licenseFrontUrl;
                                  licenseBackUrl = driver.licenseBackUrl;
                                  idCardUrl = driver.idCardUrl;
                                  licenseFront = null;
                                  licenseBack = null;
                                  idCard = null;
                                  licenseFrontFile = null;
                                  licenseBackFile = null;
                                  idCardFile = null;
                                  if (genders.contains(driver.gender)) {
                                    selectedGender = driver.gender;
                                  }
                                });
                              },
                              onAddNew: () {
                                setState(() {
                                  provider.selectedDriver = null;
                                });
                              },
                            ),

                            const SizedBox(height: 20),

                            DriverBookingDetails(
                              nameController: nameController,
                              emailController: emailController,
                              phoneController: phoneController,
                              dobController: dobController,
                              genders: genders,
                              selectedGender: selectedGender,
                              onGenderChanged: (value) {
                                setState(() {
                                  selectedGender = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    BookingStep(
                      title: loc.driversDocuments,
                      content: Form(
                        key: _driverFormKey,
                        child: DriverDocumentsStep(
                          licenseFront: licenseFront,
                          licenseBack: licenseBack,
                          idCard: idCard,
                          licenseFrontUrl: licenseFrontUrl,
                          licenseBackUrl: licenseBackUrl,
                          idCardUrl: idCardUrl,
                          onFrontUpload: () async {
                            final file = await pickImage(context);
                            if (file == null) return;

                            setState(() {
                              licenseFrontFile = file;
                              licenseFront = file.path;
                            });
                          },
                          onBackUpload: () async {
                            final file = await pickImage(context);
                            if (file == null) return;

                            setState(() {
                              licenseBackFile = file;
                              licenseBack = file.path;
                            });
                          },

                          onIdUpload: () async {
                            final file = await pickImage(context);
                            if (file == null) return;

                            setState(() {
                              idCardFile = file;
                              idCard = file.path;
                            });
                          },
                        ),
                      ),
                    ),
                    BookingStep(
                      title: loc.summary,
                      content: BookingSummary(
                        name: nameController.text,
                        phone: phoneController.text,
                        email: emailController.text,
                        carName:
                            '${widget.car.car.brand} ${widget.car.car.model} ${widget.car.car.year}',
                        // carColour: 'Blue',
                        carSeats: widget.car.car.seats,
                        transmission: widget.car.car.transmission,
                        pickupDate: pickupDate,
                        dropoffDate: dropoffDate,
                        rentalDays: rentalDays,
                        deliveryType: deliveryType,
                        deliveryAddress: deliveryAddress.text,
                        additionalNote: additionalNote.text,
                        rentalPrice: rentalPrice,
                        deliveryPrice: deliveryPrice,
                        deposit: deposit,
                        tax: widget.car.shop.taxRate,
                        fuelType: widget.car.car.fuel,
                        dailyPrice: dailyPrice,
                        licenseFrontUrl: licenseFrontUrl,
                        licenseBackUrl: licenseBackUrl,
                        idCardUrl: idCardUrl,
                        licenseFrontFile: licenseFrontFile,
                        licenseBackFile: licenseBackFile,
                        idCardFile: idCardFile,
                        currency:
                            widget.car.car.currency ?? widget.car.shop.currency,
                      ),
                    ),
                    BookingStep(
                      title: loc.payment,
                      content: BookingPaymentStep(
                        selectedMethod: selectedPaymentMethod,
                        onChanged: (method) {
                          setState(() {
                            selectedPaymentMethod = method;
                          });
                        },
                        rentalPrice: rentalPrice,
                        deliveryPrice: deliveryPrice,
                        deposit: deposit,
                        tax: widget.car.shop.taxRate,
                        deliveryType: deliveryType,
                        currency:
                            widget.car.car.currency ?? widget.car.shop.currency,
                      ),
                    ),
                  ],
                  onConfirmBooking: createBooking,
                  isLoading: isBooking,
                  driverFormKey: _driverFormKey,
                  validateDocuments: validateDocuments,
                  validateScheduleStep: validateScheduleStep,
                ),
        ),
      ),
    );
  }
}
