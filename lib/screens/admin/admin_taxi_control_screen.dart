import 'package:flutter/material.dart';
import 'package:kipgo/controllers/admin_operations_service.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/admin_operations_model.dart';

class AdminTaxiControlScreen extends StatefulWidget {
  const AdminTaxiControlScreen({super.key});

  @override
  State<AdminTaxiControlScreen> createState() => _AdminTaxiControlScreenState();
}

class _AdminTaxiControlScreenState extends State<AdminTaxiControlScreen> {
  late Future<AdminTaxiOperations> _future;

  @override
  void initState() {
    super.initState();

    _future = AdminOperationsService.instance.getTaxiOperations();
  }

  void _refresh() {
    setState(() {
      _future = AdminOperationsService.instance.getTaxiOperations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.taxi),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<AdminTaxiOperations>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: FilledButton.icon(
                onPressed: _refresh,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.retry),
              ),
            );
          }

          final data = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              _refresh();
              await _future;
            },
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _ControlHeader(
                  icon: Icons.local_taxi_rounded,
                  title: l10n.taxi,
                  subtitle: l10n.manageRidesAndDrivers,
                ),
                const SizedBox(height: 20),

                _StatsGrid(
                  items: [
                    _StatData(
                      icon: Icons.directions_car_rounded,
                      title: l10n.todaysRides,
                      value: '${data.todayRides}',
                    ),
                    _StatData(
                      icon: Icons.check_circle_outline_rounded,
                      title: l10n.completed,
                      value: '${data.completedToday}',
                    ),
                    _StatData(
                      icon: Icons.cancel_outlined,
                      title: l10n.cancelled,
                      value: '${data.cancelledToday}',
                    ),
                    _StatData(
                      icon: Icons.person_pin_circle_outlined,
                      title: l10n.onlineDrivers,
                      value: '${data.onlineDrivers}',
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                _ActionTile(
                  icon: Icons.directions_car_rounded,
                  title: l10n.rides,
                  subtitle: l10n.manageRidesAndDrivers,
                  onTap: () {
                    // Detailed ride management will be
                    // connected here.
                  },
                ),
                _ActionTile(
                  icon: Icons.people_alt_rounded,
                  title: l10n.allDrivers,
                  subtitle: l10n.onlineDrivers,
                  onTap: () {
                    // Driver management will be connected here.
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ControlHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ControlHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17),
              color: theme.colorScheme.primary,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final List<_StatData> items;

  const _StatsGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.45,
      ),
      itemBuilder: (_, index) {
        final item = items[index];

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(item.icon, color: Theme.of(context).colorScheme.primary),
              const Spacer(),
              Text(
                item.value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatData {
  final IconData icon;
  final String title;
  final String value;

  const _StatData({
    required this.icon,
    required this.title,
    required this.value,
  });
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15),
      ),
    );
  }
}
