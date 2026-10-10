import 'package:flutter/material.dart';
import 'package:kipgo/controllers/admin_dashboard_service.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/models/admin_dashboard_model.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/screens/widgets/notification_icon_button.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

import 'package:kipgo/l10n/app_localizations.dart';
import 'package:shimmer/shimmer.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminDashboardService _service = AdminDashboardService();

  AdminDashboardModel _dashboard = const AdminDashboardModel.empty();

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final dashboard = await _service.getDashboard();

      if (!mounted) return;

      setState(() {
        _dashboard = dashboard;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('AdminDashboardScreen._loadDashboard error: $e');

      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _greeting(AppLocalizations loc) {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return loc.goodMorning;
    }

    if (hour < 18) {
      return loc.goodAfternoon;
    }

    return loc.goodEvening;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBarWidget(
        title: loc.kipgoControlCenter.toUpperCase(),
        subtitle: loc.administration,
        showLanguage: false,
        actions: const [NotificationIconButton()],
      ),
      backgroundColor: isDark ? AppColors.darkAccent : const Color(0xFFF7F8FC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboard,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 20, 12, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildHeader(context, loc, isDark),

                    const SizedBox(height: 22),

                    _buildWelcomeCard(context, loc, isDark),

                    const SizedBox(height: 24),

                    _buildSectionTitle(context, loc.overview),

                    const SizedBox(height: 12),

                    if (_isLoading)
                      _buildLoadingStats(isDark)
                    else if (_error != null)
                      _buildErrorCard(context, loc, isDark)
                    else
                      _buildStatsGrid(context, loc, isDark),

                    const SizedBox(height: 26),

                    _buildSectionTitle(context, loc.operations),

                    const SizedBox(height: 12),

                    _buildOperations(context, loc, isDark),

                    const SizedBox(height: 26),

                    _buildSectionTitle(context, loc.todayAtAGlance),

                    const SizedBox(height: 12),

                    _buildActivitySummary(context, loc, isDark),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations loc, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.administration,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: isDark
                      ? Colors.white60
                      : AppColors.primary.withValues(alpha: .65),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                loc.kipgoControlCenter,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkAccent : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: .06)
                  : AppColors.primary.withValues(alpha: .06),
            ),
          ),
          child: Icon(
            Icons.admin_panel_settings_outlined,
            color: isDark ? AppColors.darkLayer : AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard(
    BuildContext context,
    AppLocalizations loc,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .20),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(loc),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  loc.manageKipgoFromOnePlace,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  loc.monitorOperationsAndSupport,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.insights_rounded,
              color: Colors.white,
              size: 29,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
    );
  }

  Widget _buildLoadingStats(bool isDark) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.55,
      children: List.generate(
        6,
        (_) => Shimmer.fromColors(
          direction: ShimmerDirection.ltr,
          baseColor: isDark ? AppColors.darkAccent : AppColors.lightAccent,
          highlightColor: isDark
              ? AppColors.darkLayer.withValues(alpha: .3)
              : AppColors.border,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkAccent : Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(
    BuildContext context,
    AppLocalizations loc,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkAccent : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.red.withValues(alpha: .15)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: .08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.error_outline_rounded, color: Colors.red),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              loc.failedToLoadDashboard,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(onPressed: _loadDashboard, child: Text(loc.retry)),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(
    BuildContext context,
    AppLocalizations loc,
    bool isDark,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.55,
      children: [
        _StatCard(
          title: loc.todaysRides,
          value: '${_dashboard.todayRides}',
          icon: Icons.local_taxi_outlined,
          isDark: isDark,
        ),
        _StatCard(
          title: loc.rentalBookings,
          value: '${_dashboard.todayRentalBookings}',
          icon: Icons.directions_car_outlined,
          isDark: isDark,
        ),
        _StatCard(
          title: loc.shuttleBookings,
          value: '${_dashboard.todayShuttleBookings}',
          icon: Icons.airport_shuttle_outlined,
          isDark: isDark,
        ),
        _StatCard(
          title: loc.totalUsers,
          value: '${_dashboard.totalUsers}',
          icon: Icons.people_outline,
          isDark: isDark,
        ),
        _StatCard(
          title: loc.onlineDrivers,
          value: '${_dashboard.onlineDrivers}',
          icon: Icons.person_pin_circle_outlined,
          isDark: isDark,
        ),
        _StatCard(
          title: loc.unansweredSupport,
          value: '${_dashboard.unansweredSupport}',
          icon: Icons.mark_unread_chat_alt_outlined,
          isDark: isDark,
          emphasize: _dashboard.unansweredSupport > 0,
        ),
      ],
    );
  }

  Widget _buildOperations(
    BuildContext context,
    AppLocalizations loc,
    bool isDark,
  ) {
    return Column(
      children: [
        _OperationCard(
          title: loc.taxi,
          subtitle: loc.manageRidesAndDrivers,
          icon: Icons.local_taxi_outlined,
          isDark: isDark,
          onTap: () {},
        ),
        const SizedBox(height: 10),
        _OperationCard(
          title: loc.carRental,
          subtitle: loc.manageRentalBookings,
          icon: Icons.directions_car_outlined,
          isDark: isDark,
          onTap: () {},
        ),
        const SizedBox(height: 10),
        _OperationCard(
          title: loc.shuttle,
          subtitle: loc.manageShuttleOperations,
          icon: Icons.airport_shuttle_outlined,
          isDark: isDark,
          onTap: () {},
        ),
        const SizedBox(height: 10),
        _OperationCard(
          title: loc.hotels,
          subtitle: loc.hotelOperationsComingSoon,
          icon: Icons.hotel_outlined,
          isDark: isDark,
          comingSoon: true,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildActivitySummary(
    BuildContext context,
    AppLocalizations loc,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkAccent : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: .05)
              : AppColors.primary.withValues(alpha: .05),
        ),
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: loc.completedRides,
            value: '${_dashboard.completedRides}',
            icon: Icons.check_circle_outline,
            isDark: isDark,
          ),
          const Divider(height: 24),
          _SummaryRow(
            label: loc.completedRentalBookings,
            value: '${_dashboard.completedRentalBookings}',
            icon: Icons.directions_car_filled_outlined,
            isDark: isDark,
          ),
          const Divider(height: 24),
          _SummaryRow(
            label: loc.completedShuttleTrips,
            value: '${_dashboard.completedShuttleBookings}',
            icon: Icons.airport_shuttle_outlined,
            isDark: isDark,
          ),
          const Divider(height: 24),
          _SummaryRow(
            label: loc.totalTodayActivity,
            value: '${_dashboard.totalTodayActivity}',
            icon: Icons.analytics_outlined,
            isDark: isDark,
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final bool isDark;
  final bool emphasize;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.isDark,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkAccent : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: emphasize
              ? Colors.orange.withValues(alpha: .18)
              : isDark
              ? Colors.white.withValues(alpha: .05)
              : AppColors.primary.withValues(alpha: .05),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: .025),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: emphasize
                    ? Colors.orange
                    : isDark
                    ? AppColors.darkLayer
                    : AppColors.primary,
              ),
              const Spacer(),
              if (emphasize)
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isDark ? Colors.white60 : Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _OperationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isDark;
  final bool comingSoon;
  final VoidCallback onTap;

  const _OperationCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isDark,
    required this.onTap,
    this.comingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: comingSoon ? null : onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkAccent : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: .05)
                : AppColors.primary.withValues(alpha: .05),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.lightLayer.withValues(alpha: .08)
                    : AppColors.primary.withValues(alpha: .07),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isDark ? AppColors.lightLayer : AppColors.primary,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            if (comingSoon)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  AppLocalizations.of(context)!.soon,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isDark;
  final bool bold;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.isDark,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 21,
          color: isDark ? AppColors.darkLayer : AppColors.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}
