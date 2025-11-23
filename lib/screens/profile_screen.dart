import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kipgo/controllers/drive_history_provider.dart';
import 'package:kipgo/controllers/ride_history_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/edit_profile.dart';
import 'package:kipgo/screens/rides/drivers/my_drives_screen.dart';
import 'package:kipgo/screens/rides/riders/ride_history_screen.dart';
import 'package:kipgo/screens/settings/vehicle_details_screen.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/utils/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String userId = Provider.of<ProfileProvider>(
        context,
        listen: false,
      ).profile!.id;
      final provider = Provider.of<RideHistoryProvider>(context, listen: false);
      provider.fetchUserRides(userId);
      final driverProvider = Provider.of<DriveHistoryProvider>(
        context,
        listen: false,
      );
      driverProvider.fetchDriverRides(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    final rideProvider = Provider.of<RideHistoryProvider>(context);
    // final driverProvider = Provider.of<DriveHistoryProvider>(context);
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBarWidget(
        title: AppLocalizations.of(context)!.myProfile.toUpperCase(),
      ),

      body: Consumer<ProfileProvider>(
        builder: (context, userProvider, _) {
          if (userProvider.isLoading) {
            return CircularProgressIndicator();
          }
          final profile = userProvider.profile;

          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 46,
                    backgroundColor: isDark
                        ? AppColors.darkLayer
                        : AppColors.primary,
                    child: CircleAvatar(
                      radius: 44,
                      backgroundColor: Theme.of(
                        context,
                      ).scaffoldBackgroundColor,
                      child: Container(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: profile!.personal.photoUrl == ''
                            ? Image.asset(
                                'assets/images/avatar.png',
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                profile.personal.photoUrl,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(AppLocalizations.of(context)!.personalDetails),
                    TextButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      ),
                      icon: Icon(Icons.edit),
                      label: Text(AppLocalizations.of(context)!.edit),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  margin: EdgeInsets.only(top: 2),
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border, width: 0.5),
                    color: isDark ? AppColors.darkAccent : Colors.grey[50],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      detailsRow(
                        title: AppLocalizations.of(context)!.username,
                        details: profile.username,
                      ),
                      const SizedBox(height: 10),
                      detailsRow(
                        title: AppLocalizations.of(context)!.email,
                        details: profile.email,
                      ),
                      const SizedBox(height: 10),
                      detailsRow(
                        title: AppLocalizations.of(context)!.firstName,
                        details: profile.personal.firstName,
                      ),
                      const SizedBox(height: 10),
                      detailsRow(
                        title: AppLocalizations.of(context)!.surname,
                        details: profile.personal.lastName,
                      ),
                      const SizedBox(height: 10),
                      detailsRow(
                        title: AppLocalizations.of(context)!.phone,
                        details: profile.personal.phone,
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                "${AppLocalizations.of(context)!.totalRidesTaken}:",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 5),
                              rideProvider.isLoading
                                  ? CircularProgressIndicator.adaptive()
                                  : Text(
                                      rideProvider.userRides.length.toString(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                            ],
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RideHistoryScreen(),
                                ),
                              );
                            },
                            icon: Icon(Icons.chevron_right_outlined),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (profile.role == 'driver') ...[
                  SizedBox(height: 26),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(AppLocalizations.of(context)!.vehicleDetails),
                      TextButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const VehicleDetailsScreen(),
                          ),
                        ),
                        icon: Icon(Icons.edit),
                        label: Text(AppLocalizations.of(context)!.edit),
                      ),
                    ],
                  ),

                  Container(
                    padding: EdgeInsets.all(8),
                    margin: EdgeInsets.only(top: 2),
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border, width: 0.5),
                      color: isDark ? AppColors.darkAccent : Colors.grey[50],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        detailsRow(
                          title: AppLocalizations.of(context)!.carModel,
                          details: profile.vehicle.model,
                        ),
                        const SizedBox(height: 10),
                        detailsRow(
                          title: AppLocalizations.of(context)!.colour,
                          details: profile.vehicle.colour,
                        ),
                        const SizedBox(height: 10),
                        detailsRow(
                          title: AppLocalizations.of(
                            context,
                          )!.registrationNumber,
                          details: profile.vehicle.numberPlate,
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${AppLocalizations.of(context)!.totalRidesDriven}:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 5),
                                Consumer<DriveHistoryProvider>(
                                  builder: (context, dhp, _) {
                                    return dhp.isLoading
                                        ? CircularProgressIndicator.adaptive()
                                        : Text(
                                            dhp.driverRides.length.toString(),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          );
                                  },
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const MyDrivesScreen(),
                                  ),
                                );
                              },
                              icon: Icon(Icons.chevron_right_outlined),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Row detailsRow({required String title, required String details}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 5),
        Expanded(
          child: Text(
            details,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }
}
