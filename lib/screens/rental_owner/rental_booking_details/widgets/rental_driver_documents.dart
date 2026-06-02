import 'package:flutter/material.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/booking_model.dart';

class RentalDriverDocuments extends StatelessWidget {
  final BookingModel booking;
  final bool isDark;
  const RentalDriverDocuments({
    super.key,
    required this.booking,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    return booking.source == 'app'
        ? Column(
            children: [
              driverDocumentsCard(
                title: loc.licenseFront,
                url: booking.driver.licenseFront,
                context: context,
              ),
              SizedBox(height: 8),
              driverDocumentsCard(
                title: loc.licenseBack,
                url: booking.driver.licenseBack,
                context: context,
              ),
              SizedBox(height: 8),
              driverDocumentsCard(
                title: loc.id,
                url: booking.driver.idCard,
                context: context,
              ),
              SizedBox(height: 8),
            ],
          )
        : Text(loc.noDocumentSubmitted);
  }

  Row driverDocumentsCard({
    required BuildContext context,
    required String title,
    required String url,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
        url == ''
            ? Text(AppLocalizations.of(context)!.notUploaded)
            : GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => Dialog(child: Image.network(url)),
                  );
                },
                child: Text(
                  AppLocalizations.of(context)!.view,
                  // style: TextStyle(color: Colors.blue),
                ),
              ),
      ],
    );
  }
}
