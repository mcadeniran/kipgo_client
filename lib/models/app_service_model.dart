import 'package:flutter/material.dart';

class AppServiceModel {
  final String title;
  final String icon;
  final VoidCallback onTap;

  const AppServiceModel({
    required this.title,
    required this.icon,
    required this.onTap,
  });
}
