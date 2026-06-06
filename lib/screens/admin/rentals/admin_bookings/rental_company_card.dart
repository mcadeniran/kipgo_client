import 'package:flutter/material.dart';
import 'package:kipgo/models/booking_model.dart';

class RentalCompanyCard extends StatelessWidget {
  final BookingModel booking;
  final bool isDark;
  const RentalCompanyCard({
    super.key,
    required this.booking,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(booking.shop.name),
              SizedBox(height: 8),
              Text(
                "${booking.shop.address}, ${booking.shop.district}, ${booking.shop.city}",
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(
                    context,
                  ).textTheme.bodySmall!.color!.withValues(alpha: 0.6),
                ),
              ),
              // SizedBox(height: 8),
              // Text(
              //   booking.shop.,
              //   style: Theme.of(context).textTheme.bodySmall!.copyWith(
              //     color: Theme.of(
              //       context,
              //     ).textTheme.bodySmall!.color!.withValues(alpha: 0.6),
              //   ),
              // ),
            ],
          ),
        ),
      ],
    );
  }
}
