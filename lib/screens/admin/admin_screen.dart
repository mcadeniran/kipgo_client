import 'package:flutter/material.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/admin/admin_nav/rental_admin_page.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});
  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    AppLocalizations loc = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                pinned: false,
                floating: false,
                expandedHeight: 40,
                toolbarHeight: 0,
                backgroundColor: AppColors.primary,
                bottom: TabBar(
                  indicatorColor: isDark ? Colors.white : AppColors.lightLayer,
                  dividerColor: Theme.of(context).scaffoldBackgroundColor,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  padding: EdgeInsets.all(0),
                  tabs: [
                    Tab(text: loc.rental),
                    Tab(text: loc.taxi),
                    Tab(text: loc.hotel),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              RentalAdminPage(),
              Center(child: Text(loc.taxi)),
              Center(child: Text(loc.hotel)),
            ],
          ),
        ),
      ),
    );
  }
}
