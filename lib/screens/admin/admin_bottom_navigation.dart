import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:kipgo/controllers/auth_provider.dart';
import 'package:kipgo/controllers/inapp_notification_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/admin/admin_chats_screen.dart';
import 'package:kipgo/screens/admin/admin_dashboard_screen.dart';
import 'package:kipgo/screens/admin/admin_operations_screen.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class AdminBottomNavigation extends StatefulWidget {
  final int initialIndex;

  const AdminBottomNavigation({super.key, this.initialIndex = 0});

  @override
  State<AdminBottomNavigation> createState() => _AdminBottomNavigationState();
}

class _AdminBottomNavigationState extends State<AdminBottomNavigation> {
  late int index;

  @override
  void initState() {
    super.initState();

    index = widget.initialIndex;

    final auth = context.read<AuthProvider>();
    final user = auth.profile;

    if (user != null) {
      context.read<InAppNotificationProvider>().listenToNotifications(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final loc = AppLocalizations.of(context)!;

    final auth = context.watch<AuthProvider>();
    final user = auth.profile;

    // Admin access only.
    final isAdmin = user?.isAdmin == true;

    if (!isAdmin) {
      return const Scaffold(body: Center(child: Text('Access denied')));
    }

    final screens = [
      const AdminDashboardScreen(),
      const AdminOperationsScreen(),
      const AdminChatsScreen(),
      // Center(child: Text('ADMIN USERS')),
      Center(child: Text('ADMIN MORE')),
      // const AdminUsersScreen(),
      // const AdminMoreScreen(),
    ];

    final safeIndex = index >= screens.length ? 0 : index;

    return Scaffold(
      body: IndexedStack(index: safeIndex, children: screens),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 7),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkAccent : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : AppColors.primary.withValues(alpha: 0.06),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: GNav(
            onTabChange: (value) {
              setState(() {
                index = value;
              });
            },
            tabBorderRadius: 18,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            backgroundColor: Colors.transparent,
            color: isDark ? AppColors.darkLayer : AppColors.primary,
            activeColor: Colors.white,
            tabBackgroundColor: isDark
                ? AppColors.darkLayer
                : AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            gap: 7,
            tabs: [
              GButton(
                icon: Icons.dashboard_outlined,
                text: loc.dashboard,
                haptic: true,
              ),
              GButton(
                icon: Icons.grid_view_rounded,
                text: loc.operations,
                haptic: true,
              ),
              // GButton(
              //   icon: Icons.people_outline,
              //   text: loc.users,
              //   haptic: true,
              // ),
              GButton(
                icon: Icons.chat_bubble_outline,
                text: loc.chats,
                haptic: true,
              ),
              GButton(
                icon: Icons.more_horiz_rounded,
                text: loc.more,
                haptic: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
