import 'package:flutter/material.dart';
import 'package:kipgo/controllers/admin_operations_service.dart';
import 'package:kipgo/controllers/auth_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/admin_operations_model.dart';
import 'package:kipgo/screens/admin/admin_rental_control_screen.dart';
import 'package:kipgo/screens/admin/admin_shuttle_control_screen.dart';
import 'package:kipgo/screens/admin/admin_taxi_control_screen.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:provider/provider.dart';

class AdminOperationsScreen extends StatefulWidget {
  const AdminOperationsScreen({super.key});

  @override
  State<AdminOperationsScreen> createState() => _AdminOperationsScreenState();
}

class _AdminOperationsScreenState extends State<AdminOperationsScreen> {
  late Future<AdminOperationsModel> _operationsFuture;

  @override
  void initState() {
    super.initState();

    _operationsFuture = AdminOperationsService.instance.getOperations();
  }

  void _refresh() {
    setState(() {
      _operationsFuture = AdminOperationsService.instance.getOperations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();

    if (auth.profile?.isAdmin != true) {
      return Scaffold(body: Center(child: Text(l10n.notAuthorized)));
    }

    return Scaffold(
      appBar: AppBarWidget(
        title: l10n.operations.toUpperCase(),
        actions: [
          IconButton(
            tooltip: l10n.refresh,
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<AdminOperationsModel>(
        future: _operationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ErrorState(
              message: l10n.failedToLoadDashboard,
              onRetry: _refresh,
            );
          }

          final operations = snapshot.data;

          if (operations == null) {
            return _ErrorState(message: l10n.noData, onRetry: _refresh);
          }

          return RefreshIndicator(
            onRefresh: () async {
              _refresh();
              await _operationsFuture;
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                _OperationsHeader(
                  totalActivity: operations.totalTodayActivity,
                  attention: operations.totalAttention,
                ),
                const SizedBox(height: 20),

                _SectionTitle(
                  title: l10n.taxi,
                  subtitle: l10n.manageRidesAndDrivers,
                ),
                const SizedBox(height: 10),

                _TaxiOperationsCard(
                  data: operations.taxi,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminTaxiControlScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                _SectionTitle(
                  title: l10n.carRental,
                  subtitle: l10n.manageRentalBookings,
                ),
                const SizedBox(height: 10),

                _RentalOperationsCard(
                  data: operations.rental,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminRentalControlScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                _SectionTitle(
                  title: l10n.shuttle,
                  subtitle: l10n.manageShuttleOperations,
                ),
                const SizedBox(height: 10),

                _ShuttleOperationsCard(
                  data: operations.shuttle,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminShuttleControlScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                _SectionTitle(
                  title: l10n.hotels,
                  subtitle: l10n.hotelOperationsComingSoon,
                ),
                const SizedBox(height: 10),

                _ComingSoonCard(
                  title: l10n.hotels,
                  subtitle: l10n.hotelOperationsComingSoon,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OperationsHeader extends StatelessWidget {
  final int totalActivity;
  final int attention;

  const _OperationsHeader({
    required this.totalActivity,
    required this.attention,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.78),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.admin_panel_settings_rounded,
            color: Colors.white,
            size: 30,
          ),
          const SizedBox(height: 14),
          Text(
            loc.operationsControlRoom,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            loc.monitorKipgo,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _HeaderMetric(
                icon: Icons.bolt_rounded,
                label: loc.today,
                value: '$totalActivity',
              ),
              const SizedBox(width: 24),
              _HeaderMetric(
                icon: Icons.priority_high_rounded,
                label: loc.attention,
                value: '$attention',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _HeaderMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 7),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.58),
          ),
        ),
      ],
    );
  }
}

class _TaxiOperationsCard extends StatelessWidget {
  final AdminTaxiOperations data;
  final VoidCallback onTap;

  const _TaxiOperationsCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _OperationsCard(
      icon: Icons.local_taxi_rounded,
      onTap: onTap,
      children: [
        _MiniMetric(
          icon: Icons.directions_car_rounded,
          label: l10n.todaysRides,
          value: '${data.todayRides}',
        ),
        _MiniMetric(
          icon: Icons.check_circle_outline_rounded,
          label: l10n.completed,
          value: '${data.completedToday}',
        ),
        _MiniMetric(
          icon: Icons.cancel_outlined,
          label: l10n.cancelled,
          value: '${data.cancelledToday}',
        ),
        _MiniMetric(
          icon: Icons.person_pin_circle_outlined,
          label: l10n.onlineDrivers,
          value: '${data.onlineDrivers}',
        ),
      ],
    );
  }
}

class _RentalOperationsCard extends StatelessWidget {
  final AdminRentalOperations data;
  final VoidCallback onTap;

  const _RentalOperationsCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _OperationsCard(
      icon: Icons.directions_car_filled_rounded,
      onTap: onTap,
      children: [
        _MiniMetric(
          icon: Icons.calendar_today_rounded,
          label: l10n.todayBookings,
          value: '${data.todayBookings}',
        ),
        _MiniMetric(
          icon: Icons.pending_actions_rounded,
          label: l10n.pending,
          value: '${data.pending}',
          highlight: data.pending > 0,
        ),
        _MiniMetric(
          icon: Icons.payments_outlined,
          label: l10n.paymentSubmitted,
          value: '${data.paymentSubmitted}',
          highlight: data.paymentSubmitted > 0,
        ),
        _MiniMetric(
          icon: Icons.directions_car_rounded,
          label: l10n.ongoing,
          value: '${data.ongoing}',
        ),
      ],
    );
  }
}

class _ShuttleOperationsCard extends StatelessWidget {
  final AdminShuttleOperations data;
  final VoidCallback onTap;

  const _ShuttleOperationsCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _OperationsCard(
      icon: Icons.airport_shuttle_rounded,
      onTap: onTap,
      children: [
        _MiniMetric(
          icon: Icons.calendar_today_rounded,
          label: l10n.todayBookings,
          value: '${data.todayBookings}',
        ),
        _MiniMetric(
          icon: Icons.pending_actions_rounded,
          label: l10n.pending,
          value: '${data.pending}',
          highlight: data.pending > 0,
        ),
        _MiniMetric(
          icon: Icons.payment_rounded,
          label: l10n.paymentSubmitted,
          value: '${data.paymentSubmitted}',
          highlight: data.paymentSubmitted > 0,
        ),
        _MiniMetric(
          icon: Icons.route_rounded,
          label: l10n.inProgress,
          value: '${data.inProgress}',
        ),
      ],
    );
  }
}

class _OperationsCard extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final List<Widget> children;

  const _OperationsCard({
    required this.icon,
    required this.onTap,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.55)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: theme.colorScheme.primary.withValues(alpha: 0.09),
                    ),
                    child: Icon(icon, color: theme.colorScheme.primary),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 12,
                childAspectRatio: 2.7,
                children: children,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  const _MiniMetric({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: highlight
              ? theme.colorScheme.error
              : theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ComingSoonCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ComingSoonCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.55)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.hotel_rounded,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Chip(label: Text(AppLocalizations.of(context)!.soon)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 48),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      ),
    );
  }
}
