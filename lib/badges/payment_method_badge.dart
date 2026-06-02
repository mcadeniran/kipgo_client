import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/bi.dart';
import 'package:iconify_flutter/icons/carbon.dart';
import 'package:iconify_flutter/icons/simple_icons.dart';

class PaymentMethodBadge extends StatelessWidget {
  final String method;

  const PaymentMethodBadge({super.key, required this.method});

  @override
  Widget build(BuildContext context) {
    Color color;
    Iconify icon;

    switch (method) {
      case 'crypto':
        color = Color(0xff009393);
        icon = Iconify(SimpleIcons.tether, color: color);
        break;
      case 'payOnPickup':
        color = Colors.green;
        icon = Iconify(Bi.cash, color: color);
        break;
      default:
        color = Colors.red;
        icon = Iconify(Carbon.unknown_filled, color: color);
        break;
    }

    return CircleAvatar(
      backgroundColor: Colors.transparent,
      radius: 14,
      child: icon,
    );
  }
}
