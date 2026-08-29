import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/screens/widgets/language_widget.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class AppBarWidget extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showLanguage;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottomWidget;

  const AppBarWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.showLanguage = true,
    this.actions,
    this.bottomWidget,
  });

  double get toolbarHeight => subtitle != null ? 76 : 68;

  double get bottomHeight => bottomWidget?.preferredSize.height ?? 0;

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight + bottomHeight);

  @override
  State<AppBarWidget> createState() => _AppBarWidgetState();
}

class _AppBarWidgetState extends State<AppBarWidget> {
  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    final hasSubtitle =
        widget.subtitle != null && widget.subtitle!.trim().isNotEmpty;

    return AppBar(
      automaticallyImplyLeading: true,

      backgroundColor: AppColors.primary,
      surfaceTintColor: Colors.transparent,

      elevation: 0,
      scrolledUnderElevation: 0,

      toolbarHeight: widget.toolbarHeight,

      centerTitle: false,
      titleSpacing: 4,

      iconTheme: const IconThemeData(color: Colors.white, size: 22),

      title: hasSubtitle
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -.2,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  widget.subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: .62),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            )
          : Text(
              widget.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w700,
                letterSpacing: -.25,
              ),
            ),

      actionsPadding: const EdgeInsets.only(right: 12, top: 10, bottom: 10),

      actions: [
        if (widget.showLanguage)
          _AppBarActionContainer(child: const LanguageWidget()),

        if (widget.showLanguage && widget.actions != null)
          const SizedBox(width: 6),

        if (widget.actions != null)
          ...widget.actions!.map(
            (action) => Padding(
              padding: const EdgeInsets.only(left: 6),
              child: _AppBarActionContainer(child: action),
            ),
          ),
      ],

      bottom: widget.bottomWidget,

      flexibleSpace: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: .96),
              isDark
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: .94),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .12),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppBarActionContainer extends StatelessWidget {
  final Widget child;

  const _AppBarActionContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      width: 42,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .11),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: .10),
          width: .8,
        ),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
