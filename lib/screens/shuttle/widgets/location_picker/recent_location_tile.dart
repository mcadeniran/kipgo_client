import 'package:flutter/material.dart';
import 'package:kipgo/models/shuttle_location.dart';

class RecentLocationTile extends StatelessWidget {
  final ShuttleLocation location;

  final VoidCallback onTap;

  const RecentLocationTile({
    super.key,
    required this.location,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.history)),

      title: Text(
        location.displayName != '' ? location.displayName : location.address,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),

      subtitle: Text(location.city),

      trailing: const Icon(Icons.chevron_right),

      onTap: onTap,
    );
  }
}
