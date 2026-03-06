import 'package:flutter/material.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/models/booking_step.dart';
import 'package:kipgo/models/profile.dart';
import 'package:kipgo/screens/rental/widgets/booking_summary.dart';
import 'package:kipgo/screens/rental/widgets/driver_booking_details.dart';
import 'package:kipgo/screens/rental/widgets/premium_booking_stepper.dart';
import 'package:kipgo/screens/rental/widgets/schedule_booking_details.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

enum DeliveryType { pickup, delivery }

class CarBookingPage extends StatefulWidget {
  const CarBookingPage({super.key});

  @override
  State<CarBookingPage> createState() => _CarBookingPageState();
}

class _CarBookingPageState extends State<CarBookingPage> {
  DeliveryType deliveryType = DeliveryType.pickup;
  int currentStep = 0;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  final List<String> genders = ["Male", "Female", "Others"];
  late String selectedGender = genders[0];

  late DateTime pickupDate;
  late DateTime dropoffDate;
  double dailyPrice = 1200;
  double rentalPrice = 0;
  double deliveryPrice = 1000;
  TextEditingController deliveryAddress = TextEditingController();
  TextEditingController additionalNote = TextEditingController();
  int rentalDays = 3;
  int deposit = 1500;

  @override
  void initState() {
    super.initState();
    Profile user = Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).profile!;

    nameController.text =
        "${user.personal.firstName} ${user.personal.lastName}";
    phoneController.text = user.personal.phone;
    emailController.text = user.email;

    pickupDate = DateTime.now();
    dropoffDate = pickupDate.add(Duration(days: 3));

    rentalPrice = 3 * dailyPrice * 1.0;
  }

  @override
  Widget build(BuildContext context) {
    // bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Scaffold(
      appBar: AppBarWidget(title: 'Booking Details'),
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
              title: "Driver",
              content: DriverBookingDetails(
                nameController: nameController,
                emailController: emailController,
                phoneController: phoneController,
                genders: genders,
                selectedGender: selectedGender,
                onGenderChanged: (value) {
                  setState(() {
                    selectedGender = value;
                  });
                },
              ),
            ),
            BookingStep(
              title: "Schedule",
              content: ScheduleBookingDetails(
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
                    deliveryPrice = type == DeliveryType.delivery ? 1000 : 0;
                  });
                },
              ),
            ),
            BookingStep(
              title: "Summary",
              content: BookingSummary(
                name: nameController.text,
                phone: phoneController.text,
                email: emailController.text,
                carName: 'Ford Focus 2022',
                carColour: 'Blue',
                carSeats: 5,
                transmission: 'Automatic',
                pickupDate: pickupDate,
                dropoffDate: dropoffDate,
                rentalDays: rentalDays,
                deliveryType: deliveryType,
                deliveryAddress: deliveryAddress.text,
                additionalNote: additionalNote.text,
                rentalPrice: rentalPrice,
                deliveryPrice: deliveryPrice,
                deposit: deposit,
                tax: 0.25,
                fuelType: 'Petrol',
                dailyPrice: dailyPrice,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
