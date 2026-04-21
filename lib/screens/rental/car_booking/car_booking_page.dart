import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/booking_step.dart';
import 'package:kipgo/models/car_with_shop_model.dart';
import 'package:kipgo/models/driver_profile.dart';
import 'package:kipgo/models/profile.dart';
import 'package:kipgo/screens/rental/car_booking/booking_success_page.dart';
import 'package:kipgo/screens/rental/car_booking/booking_summary.dart';
import 'package:kipgo/screens/rental/car_booking/driver_booking_details.dart';
import 'package:kipgo/screens/rental/car_booking/driver_documents_step.dart';
import 'package:kipgo/screens/rental/car_booking/driver_selector.dart';
import 'package:kipgo/screens/rental/car_booking/pick_image.dart';
import 'package:kipgo/screens/rental/widgets/premium_booking_stepper.dart';
import 'package:kipgo/screens/rental/car_booking/schedule_booking_details.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:kipgo/utils/invoice_generator.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

enum DeliveryType { pickup, delivery }

class CarBookingPage extends StatefulWidget {
  final CarWithShop car;
  const CarBookingPage({super.key, required this.car});

  @override
  State<CarBookingPage> createState() => _CarBookingPageState();
}

class _CarBookingPageState extends State<CarBookingPage> {
  final _driverFormKey = GlobalKey<FormState>();
  List<DriverProfile> drivers = [];
  DriverProfile? selectedDriver;

  DeliveryType deliveryType = DeliveryType.pickup;
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

  UploadTask? uploadTask;

  bool isBooking = false;

  Future<void> loadDrivers() async {
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

    final uid = profileProvider.profile!.id;

    final snapshot = await FirebaseFirestore.instance
        .collection("profiles")
        .doc(uid)
        .collection("renters")
        .get();

    drivers = snapshot.docs
        .map((doc) => DriverProfile.fromMap(doc.data(), doc.id))
        .toList();

    setState(() {});
  }

  Future<String?> uploadFile(File? pickedFile) async {
    if (pickedFile == null) {
      return null;
    }

    try {
      var fileExtension = p.extension(pickedFile.path);
      var fileId = const Uuid().v4();

      final path =
          'files/${Provider.of<ProfileProvider>(context, listen: false).profile!.id}/$fileId$fileExtension';
      // final file = File(pickedFile.path);

      final ref = FirebaseStorage.instance.ref().child(path);

      setState(() {
        uploadTask = ref.putFile(pickedFile);
      });

      final snapshot = await uploadTask!.whenComplete(() {});
      final urlDownload = await snapshot.ref.getDownloadURL();
      return urlDownload;
    } on FirebaseException catch (e) {
      debugPrint(e.message);
      return null;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    } finally {
      setState(() {
        uploadTask = null;
      });
    }
  }

  Future<String> saveDriverProfile() async {
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

    final uid = profileProvider.profile!.id;

    licenseFrontUrl = await uploadFile(licenseFrontFile);
    licenseBackUrl = await uploadFile(licenseBackFile);
    idCardUrl = await uploadFile(idCardFile);

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

  bool hasDriverChanged() {
    return nameController.text != selectedDriver!.name ||
        emailController.text != selectedDriver!.email ||
        phoneController.text != selectedDriver!.phone ||
        dobController.text != selectedDriver!.dob ||
        selectedGender != selectedDriver!.gender ||
        licenseFrontFile != null ||
        licenseBackFile != null ||
        idCardFile != null;
  }

  Future<void> createBooking() async {
    setState(() => isBooking = true);
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

    final uid = profileProvider.profile!.id;

    String driverId;

    if (selectedDriver == null) {
      driverId = await saveDriverProfile();
    } else {
      driverId = selectedDriver!.id;

      if (hasDriverChanged()) {
        if (licenseFrontFile != null) {
          licenseFrontUrl = await uploadFile(licenseFrontFile);
        } else {
          licenseFrontUrl = selectedDriver!.licenseFrontUrl;
        }

        if (licenseBackFile != null) {
          licenseBackUrl = await uploadFile(licenseBackFile);
        } else {
          licenseBackUrl = selectedDriver!.licenseBackUrl;
        }

        if (idCardFile != null) {
          idCardUrl = await uploadFile(idCardFile);
        } else {
          idCardUrl = selectedDriver!.idCardUrl;
        }

        // 🔥 Update ALL fields (text + images)
        await FirebaseFirestore.instance
            .collection("profiles")
            .doc(uid)
            .collection("renters")
            .doc(selectedDriver!.id)
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
        licenseFrontUrl = selectedDriver!.licenseFrontUrl;
        licenseBackUrl = selectedDriver!.licenseBackUrl;
        idCardUrl = selectedDriver!.idCardUrl;
      }
      // licenseFrontUrl = selectedDriver!.licenseFrontUrl;
      // licenseBackUrl = selectedDriver!.licenseBackUrl;
      // idCardUrl = selectedDriver!.idCardUrl;
    }

    final invoiceNumber = generateInvoiceNumber();

    final double tempDelivery = deliveryType == DeliveryType.delivery
        ? deliveryPrice
        : 0;

    final double preTax = rentalPrice + tempDelivery;

    final double taxAmount = widget.car.shop.taxRate * preTax;

    final double totalPrice = preTax + taxAmount + deposit;

    // if (!_driverFormKey.currentState!.validate()) return;
    // if (!validateDocuments()) return;
    // if (!validateScheduleStep()) return;

    await FirebaseFirestore.instance.collection("bookings").add({
      "invoiceNumber": invoiceNumber,
      "carId": widget.car.car.id,
      "shopId": widget.car.car.shopId,
      "userId": uid,
      "driverId": driverId,

      "car": {
        "brand": widget.car.car.brand,
        "model": widget.car.car.model,
        "year": widget.car.car.year,
        "seats": widget.car.car.seats,
        "transmission": widget.car.car.transmission,
        "carType": widget.car.car.carType,
        "fuel": widget.car.car.fuel,
        "carImage": widget.car.car.images
            .firstWhere(
              (img) => img.isCover == true,
              orElse: () => widget.car.car.images.first,
            )
            .url,
        "pricePerDay": widget.car.finalPrice,
      },

      "pickupDate": Timestamp.fromDate(pickupDate),
      "dropoffDate": Timestamp.fromDate(dropoffDate),

      "deliveryType": deliveryType.name,
      "deliveryAddress": deliveryAddress.text,

      "rentalPrice": rentalPrice,
      "deliveryPrice": deliveryPrice,
      "deposit": deposit,

      "note": additionalNote.text,

      "taxRate": widget.car.shop.taxRate,
      "preTax": preTax,
      "tax": taxAmount,
      "totalPrice": totalPrice,

      "currency": widget.car.car.currency ?? widget.car.shop.currency,

      "shop": {
        "location": {
          "lat": widget.car.shop.location.lat,
          "lng": widget.car.shop.location.lng,
        },
        "address": widget.car.shop.address,
        "city": widget.car.shop.city,
        "district": widget.car.shop.district,
        "name": widget.car.shop.name,
        "logo": widget.car.shop.logo,
      },

      "driver": {
        "name": nameController.text,
        "phone": phoneController.text,
        "email": emailController.text,
        "dob": dobController.text,
        "gender": selectedGender,
        "licenseFront": licenseFrontUrl,
        "licenseBack": licenseBackUrl,
        "idCard": idCardUrl,
      },

      "status": "pending",

      "createdAt": FieldValue.serverTimestamp(),
    });

    setState(() => isBooking = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => BookingSuccessPage(invoiceNumber: invoiceNumber),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Profile user = Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).profile!;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await loadDrivers();

      if (drivers.isEmpty) {
        nameController.text =
            "${user.personal.firstName} ${user.personal.lastName}";
        phoneController.text = user.personal.phone;
        emailController.text = user.email;
      }
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.allDriverDocumentsAreRequired)),
      );
      return false;
    }
    return true;
  }

  bool validateScheduleStep() {
    // 1. Dates check
    if (dropoffDate.isBefore(pickupDate) ||
        dropoffDate.isAtSameMomentAs(pickupDate)) {
      _showError(loc.invalidRentalPeriod);
      return false;
    }

    // 2. Minimum duration
    if (rentalDays < 1) {
      _showError(loc.rentalMustBeAtLeast1Day);
      return false;
    }

    // 3. Delivery validation
    if (deliveryType == DeliveryType.delivery &&
        deliveryAddress.text.trim().isEmpty) {
      _showError(loc.deliveryAddressIsRequired);
      return false;
    }

    return true;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    // bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Scaffold(
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
        child: PremiumBookingStepper(
          steps: [
            BookingStep(
              title: loc.driver,
              content: Form(
                key: _driverFormKey,
                child: Column(
                  children: [
                    DriverSelector(
                      drivers: drivers,
                      selected: selectedDriver,
                      onSelect: (driver) {
                        setState(() {
                          selectedDriver = driver;

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
                          selectedDriver = null;
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
                  onDateChanged: (pickup, dropoff, total) {
                    setState(() {
                      pickupDate = pickup;
                      dropoffDate = dropoff;
                      rentalPrice = total.toDouble();
                      rentalDays = dropoffDate.difference(pickupDate).inDays;
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
                currency: widget.car.car.currency ?? widget.car.shop.currency,
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
    );
  }
}
