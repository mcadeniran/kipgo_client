import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/ride_history.dart';
import 'package:kipgo/screens/rides/ride_details_screen.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:kipgo/controllers/drive_history_provider.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';

class MyDrivesScreen extends StatefulWidget {
  const MyDrivesScreen({super.key});

  @override
  State<MyDrivesScreen> createState() => _MyDrivesScreenState();
}

class _MyDrivesScreenState extends State<MyDrivesScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String driverId = Provider.of<ProfileProvider>(
        context,
        listen: false,
      ).profile!.id;
      final provider = Provider.of<DriveHistoryProvider>(
        context,
        listen: false,
      );
      provider.fetchDriverRides(driverId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final driveProvider = Provider.of<DriveHistoryProvider>(context);
    bool isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBarWidget(
        title: AppLocalizations.of(context)!.myDrives.toUpperCase(),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: driveProvider.isLoading
            ? Center(child: CircularProgressIndicator.adaptive())
            : driveProvider.driverRides.isEmpty
            ? Center(child: Text(AppLocalizations.of(context)!.noDrivesYet))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: driveProvider.driverRides.length,
                itemBuilder: (context, index) {
                  RideHistory drive = driveProvider.driverRides[index];
                  return Card(
                    color: isDark
                        ? AppColors.darkAccent
                        : AppColors.lightAccent,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RideDetailsScreen(
                              title: AppLocalizations.of(context)!.driveDetails,
                              isRider: false,
                              history: drive,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  timeago.format(drive.time),
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '${AppLocalizations.of(context)!.drive} ${index + 1}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 18,
                                  color: Colors.indigo,
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Text(drive.originAddress)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(
                                  Icons.flag,
                                  size: 18,
                                  color: Colors.redAccent,
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Text(drive.destinationAddress)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  drive.status == 'accepted'
                                      ? AppLocalizations.of(
                                          context,
                                        )!.rideAccepted
                                      : drive.status == 'arrived'
                                      ? AppLocalizations.of(
                                          context,
                                        )!.rideArrived
                                      : drive.status == 'ontrip'
                                      ? AppLocalizations.of(context)!.rideOnTrip
                                      : drive.status == 'ended'
                                      ? AppLocalizations.of(context)!.rideEnded
                                      : AppLocalizations.of(
                                          context,
                                        )!.rideUnknown,
                                  style: TextStyle(
                                    color: drive.status == 'ended'
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Icon(Icons.chevron_right),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
