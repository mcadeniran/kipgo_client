import 'package:flutter/material.dart';

class AppServiceModel {
  final String title;
  final String icon;
  final VoidCallback onTap;
  final bool isAdmin;

  const AppServiceModel({
    required this.title,
    required this.icon,
    required this.onTap,
    this.isAdmin = false,
  });
}
