import 'package:flutter/material.dart';

class PendingBooking extends StatelessWidget {
  const PendingBooking({super.key});

  @override
  Widget build(BuildContext context) {
    List bookingHistory = [
      // BookingHistoryCard(
      //   bookingId: "KPG-29302",
      //   carName: "BMW X5",
      //   carImage: "assets/images/bmw.webp",
      //   pickupDate: DateTime(2024, 6, 10),
      //   dropoffDate: DateTime(2024, 6, 12),
      //   rentalDays: 2,
      //   deliveryType: "Pickup",
      //   totalPrice: 4850,
      //   status: "Pending",
      // ),

      // /// 🔸 2. Approved
      // BookingHistoryCard(
      //   bookingId: "KPG-29303",
      //   carName: "BMW X5",
      //   carImage: "assets/images/bmw.webp",
      //   pickupDate: DateTime(2024, 6, 15),
      //   dropoffDate: DateTime(2024, 6, 18),
      //   rentalDays: 3,
      //   deliveryType: "Delivery",
      //   totalPrice: 7200,
      //   status: "Pending",
      // ),

      // /// 🔸 3. Ongoing (Currently active rental)
      // BookingHistoryCard(
      //   bookingId: "KPG-29304",
      //   carName: "BMW X5",
      //   carImage: "assets/images/bmw.webp",
      //   pickupDate: DateTime(2024, 5, 20),
      //   dropoffDate: DateTime(2024, 5, 25),
      //   rentalDays: 5,
      //   deliveryType: "Pickup",
      //   totalPrice: 11800,
      //   status: "Pending",
      // ),

      // /// 🔸 4. Completed
      // BookingHistoryCard(
      //   bookingId: "KPG-29305",
      //   carName: "BMW X5",
      //   carImage: "assets/images/bmw.webp",
      //   pickupDate: DateTime(2024, 4, 24),
      //   dropoffDate: DateTime(2024, 4, 26),
      //   rentalDays: 2,
      //   deliveryType: "Pickup",
      //   totalPrice: 4850,
      //   status: "Pending",
      // ),

      // /// 🔸 5. Cancelled (User cancelled)
      // BookingHistoryCard(
      //   bookingId: "KPG-29306",
      //   carName: "BMW X5",
      //   carImage: "assets/images/bmw.webp",
      //   pickupDate: DateTime(2024, 7, 2),
      //   dropoffDate: DateTime(2024, 7, 4),
      //   rentalDays: 2,
      //   deliveryType: "Delivery",
      //   totalPrice: 5100,
      //   status: "Pending",
      // ),

      // /// 🔸 6. Rejected (Owner rejected booking)
      // BookingHistoryCard(
      //   bookingId: "KPG-29307",
      //   carName: "BMW X5",
      //   carImage: "assets/images/bmw.webp",
      //   pickupDate: DateTime(2024, 3, 10),
      //   dropoffDate: DateTime(2024, 3, 12),
      //   rentalDays: 2,
      //   deliveryType: "Pickup",
      //   totalPrice: 4600,
      //   status: "Pending",
      // ),

      // /// 🔸 7. Refunded (After cancellation or dispute)
      // BookingHistoryCard(
      //   bookingId: "KPG-29308",
      //   carName: "BMW X5",
      //   carImage: "assets/images/bmw.webp",
      //   pickupDate: DateTime(2024, 2, 5),
      //   dropoffDate: DateTime(2024, 2, 8),
      //   rentalDays: 3,
      //   deliveryType: "Delivery",
      //   totalPrice: 7500,
      //   status: "Pending",
      // ),
    ];
    return bookingHistory.isEmpty
        ? Center(child: Text('You do not have any pending booking.'))
        : ListView.separated(
            itemBuilder: (context, index) {
              return bookingHistory[index];
            },
            separatorBuilder: (context, _) => SizedBox(height: 5),
            itemCount: bookingHistory.length,
          );
  }
}
