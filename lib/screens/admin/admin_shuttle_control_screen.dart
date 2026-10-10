import 'package:flutter/material.dart';
import 'package:kipgo/controllers/admin_operations_service.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/admin_operations_model.dart';

class AdminShuttleControlScreen extends StatefulWidget {
  const AdminShuttleControlScreen({super.key});

  @override
  State<AdminShuttleControlScreen> createState() =>
      _AdminShuttleControlScreenState();
}

class _AdminShuttleControlScreenState extends State<AdminShuttleControlScreen> {
  late Future<AdminShuttleOperations> _future;

  @override
  void initState() {
    super.initState();

    _future = AdminOperationsService.instance.getShuttleOperations();
  }

  void _refresh() {
    setState(() {
      _future = AdminOperationsService.instance.getShuttleOperations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.shuttle),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<AdminShuttleOperations>(
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
                _Header(
                  title: l10n.shuttle,
                  subtitle: l10n.manageShuttleOperations,
                  icon: Icons.airport_shuttle_rounded,
                ),
                const SizedBox(height: 20),

                _StatsGrid(
                  items: [
                    _Stat(
                      Icons.calendar_today_rounded,
                      l10n.todayBookings,
                      '${data.todayBookings}',
                    ),
                    _Stat(
                      Icons.pending_actions_rounded,
                      l10n.pending,
                      '${data.pending}',
                      attention: data.pending > 0,
                    ),
                    _Stat(
                      Icons.payment_rounded,
                      l10n.paymentSubmitted,
                      '${data.paymentSubmitted}',
                      attention: data.paymentSubmitted > 0,
                    ),
                    _Stat(
                      Icons.event_available_rounded,
                      l10n.upcoming,
                      '${data.upcoming}',
                    ),
                    _Stat(
                      Icons.route_rounded,
                      l10n.inProgress,
                      '${data.inProgress}',
                    ),
                    _Stat(
                      Icons.check_circle_outline_rounded,
                      l10n.completed,
                      '${data.completedToday}',
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                _Tile(
                  icon: Icons.pending_actions_rounded,
                  title: l10n.pending,
                  subtitle: l10n.manageShuttleOperations,
                ),
                _Tile(
                  icon: Icons.payment_rounded,
                  title: l10n.paymentSubmitted,
                  subtitle: l10n.paymentAttention,
                ),
                _Tile(
                  icon: Icons.event_available_rounded,
                  title: l10n.upcoming,
                  subtitle: l10n.manageShuttleOperations,
                ),
                _Tile(
                  icon: Icons.route_rounded,
                  title: l10n.inProgress,
                  subtitle: l10n.manageShuttleOperations,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _Header({
    required this.title,
    required this.subtitle,
    required this.icon,
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
  final List<_Stat> items;

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
        childAspectRatio: 1.4,
      ),
      itemBuilder: (_, index) {
        final item = items[index];

        return Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: item.attention
                  ? Theme.of(context).colorScheme.error.withValues(alpha: 0.4)
                  : Theme.of(context).dividerColor.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                item.icon,
                color: item.attention
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary,
              ),
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

class _Stat {
  final IconData icon;
  final String title;
  final String value;
  final bool attention;

  const _Stat(this.icon, this.title, this.value, {this.attention = false});
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15),
      ),
    );
  }
}
