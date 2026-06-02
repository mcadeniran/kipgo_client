import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kipgo/screens/widgets/language_widget.dart';
import 'package:kipgo/utils/colors.dart';

class AppBarWidget extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool showLanguage;
  final List<Widget>? actions;
  const AppBarWidget({
    super.key,
    required this.title,
    this.showLanguage = true,
    this.actions,
  });

  @override
  State<AppBarWidget> createState() => _AppBarWidgetState();

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

class _AppBarWidgetState extends State<AppBarWidget> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      title: Text(
        widget.title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: Colors.white),
      actions: [
        if (widget.showLanguage) const LanguageWidget(),

        if (widget.actions != null) ...widget.actions!,
      ],
      actionsPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      elevation: 8,
    );
  }
}
