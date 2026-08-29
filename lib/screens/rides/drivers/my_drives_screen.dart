import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kipgo/controllers/locale_provider.dart';
import 'package:kipgo/screens/widgets/format_currency.dart';
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
      _loadDrives();
    });
  }

  Future<void> _loadDrives() async {
    if (!mounted) return;

    final profile = context.read<ProfileProvider>().profile;

    if (profile == null) return;

    await context.read<DriveHistoryProvider>().fetchDriverRides(profile.id);
  }

  Future<void> _refresh() async {
    if (!mounted) return;

    final profile = context.read<ProfileProvider>().profile;

    if (profile == null) return;

    await context.read<DriveHistoryProvider>().fetchDriverRides(profile.id);
  }

  @override
  Widget build(BuildContext context) {
    final driveProvider = context.watch<DriveHistoryProvider>();
    final isDark = context.read<ThemeProvider>().isDarkMode;
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBarWidget(title: loc.myDrives.toUpperCase()),
      body: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: RefreshIndicator.adaptive(
          onRefresh: _refresh,
          child: driveProvider.isLoading
              ? const Center(child: CircularProgressIndicator.adaptive())
              : driveProvider.driverRides.isEmpty
              ? _buildEmptyState(context, isDark: isDark)
              : ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(12, 20, 12, 32),
                  children: [
                    _buildHeader(
                      context,
                      driveProvider.driverRides.length,
                      isDark,
                    ),

                    const SizedBox(height: 24),

                    _buildSectionTitle(context, loc.myDrives),

                    const SizedBox(height: 12),

                    ...List.generate(driveProvider.driverRides.length, (index) {
                      final drive = driveProvider.driverRides[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _buildDriveCard(
                          context,
                          drive: drive,
                          driveNumber: driveProvider.driverRides.length - index,
                          isDark: isDark,
                        ),
                      );
                    }),
                  ],
                ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------------

  Widget _buildHeader(BuildContext context, int totalDrives, bool isDark) {
    final loc = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.82),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.20),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.local_taxi_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(width: 16),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.myDrives,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  loc.myDrivingHistory,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Total
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                totalDrives.toString(),
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                loc.drives,
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.70),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION TITLE
  // ---------------------------------------------------------------------------

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        Container(
          width: 32,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.tertiary,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // DRIVE CARD
  // ---------------------------------------------------------------------------

  Widget _buildDriveCard(
    BuildContext context, {
    required RideHistory drive,
    required int driveNumber,
    required bool isDark,
  }) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final status = _getStatusData(context, drive.status);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RideDetailsScreen(
                title: loc.driveDetails,
                isRider: false,
                history: drive,
              ),
            ),
          );
        },
        child: Ink(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkAccent : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : AppColors.border.withValues(alpha: 0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.04),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // -----------------------------------------------------------
                // TOP ROW
                // -----------------------------------------------------------
                Row(
                  children: [
                    _buildDriveNumber(driveNumber, isDark),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            timeago.format(drive.time),
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDriveDate(drive.time, context),
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.50,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    _buildStatusPill(
                      context,
                      label: status.label,
                      color: status.color,
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // -----------------------------------------------------------
                // ROUTE
                // -----------------------------------------------------------
                _buildRoute(context, drive: drive, isDark: isDark),

                const SizedBox(height: 16),

                // -----------------------------------------------------------
                // DIVIDER
                // -----------------------------------------------------------
                Divider(
                  height: 1,
                  thickness: 0.7,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.07)
                      : AppColors.border.withValues(alpha: 0.35),
                ),

                const SizedBox(height: 14),

                // -----------------------------------------------------------
                // BOTTOM INFO
                // -----------------------------------------------------------
                Row(
                  children: [
                    _buildInfoItem(
                      context,
                      icon: Icons.person_outline_rounded,
                      label: drive.username,
                      isDark: isDark,
                    ),

                    const Spacer(),

                    _buildInfoItem(
                      context,
                      icon: Icons.payments_outlined,
                      label: formatCurrency(
                        amount: drive.fare,
                        currencyCode: 'TRY',
                        context: context,
                      ),
                      isDark: isDark,
                      highlight: true,
                    ),

                    const SizedBox(width: 8),

                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.black.withValues(alpha: 0.035),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.50,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DRIVE NUMBER
  // ---------------------------------------------------------------------------

  Widget _buildDriveNumber(int number, bool isDark) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          '#$number',
          style: GoogleFonts.poppins(
            color: isDark ? AppColors.lightLayer : AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ROUTE
  // ---------------------------------------------------------------------------

  Widget _buildRoute(
    BuildContext context, {
    required RideHistory drive,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline
        SizedBox(
          width: 26,
          child: Column(
            children: [
              Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? Colors.white : AppColors.primary,
                    width: 2,
                  ),
                ),
              ),

              Container(
                width: 1.5,
                height: 35,
                color: isDark ? Colors.white24 : AppColors.border,
              ),

              Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color: AppColors.tertiary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? Colors.white : AppColors.tertiary,
                    width: 2,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                drive.originAddress,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 27),

              Text(
                drive.destinationAddress,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // STATUS PILL
  // ---------------------------------------------------------------------------

  Widget _buildStatusPill(
    BuildContext context, {
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // INFO ITEM
  // ---------------------------------------------------------------------------

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isDark,
    bool highlight = false,
  }) {
    final theme = Theme.of(context);

    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 17,
            color: highlight
                ? AppColors.tertiary
                : (isDark ? AppColors.lightLayer : AppColors.primary),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
                color: highlight
                    ? AppColors.tertiary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.70),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STATUS DATA
  // ---------------------------------------------------------------------------

  _DriveStatusData _getStatusData(BuildContext context, String status) {
    final loc = AppLocalizations.of(context)!;

    switch (status) {
      case 'accepted':
        return _DriveStatusData(loc.rideAccepted, Colors.blue);

      case 'arrived':
        return _DriveStatusData(loc.rideArrived, Colors.orange);

      case 'ontrip':
        return _DriveStatusData(loc.rideOnTrip, AppColors.primary);

      case 'ended':
        return _DriveStatusData(loc.rideEnded, Colors.green);

      case 'cancelled':
        return _DriveStatusData(loc.cancelled, AppColors.tertiary);

      default:
        return _DriveStatusData(loc.rideUnknown, Colors.grey);
    }
  }

  // ---------------------------------------------------------------------------
  // DATE
  // ---------------------------------------------------------------------------

  // String _formatDriveDate(DateTime date) {
  //   return MaterialLocalizations.of(context).formatMediumDate(date);
  // }

  String _formatDriveDate(DateTime date, BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
    return DateFormat('EEE, MMM d, yyyy', '$locale').format(date);
  }

  // ---------------------------------------------------------------------------
  // EMPTY STATE
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState(BuildContext context, {required bool isDark}) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return RefreshIndicator.adaptive(
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.18),

          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(
                  alpha: isDark ? 0.20 : 0.07,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_taxi_outlined,
                size: 48,
                color: isDark ? AppColors.lightLayer : AppColors.primary,
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            loc.noDrivesYet,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              loc.yourCompletedDrivesWillAppearHere,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                height: 1.5,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DriveStatusData {
  final String label;
  final Color color;

  const _DriveStatusData(this.label, this.color);
}
