import 'package:flutter/material.dart';

class BulletWidget extends StatelessWidget {
  final String details;
  const BulletWidget({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('●'),
        SizedBox(width: 5),
        Expanded(
          child: Text(details, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
