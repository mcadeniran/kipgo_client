import 'package:flutter/material.dart';
import 'package:kipgo/screens/shuttle/widgets/booking_card/shuttle_booking_card.dart';
import 'package:kipgo/screens/shuttle/widgets/shuttle/shuttle_contact_section.dart';
import 'package:kipgo/screens/shuttle/widgets/shuttle/shuttle_services_section.dart';
import 'package:kipgo/screens/shuttle/widgets/shuttle/shuttle_why_us_section.dart';
import 'package:kipgo/screens/shuttle/widgets/shuttle/upcoming_booking_card.dart'
    show UpcomingBookingCard;
import 'package:kipgo/screens/shuttle/widgets/shuttle_hero_header.dart';
import 'package:kipgo/screens/widgets/ads_carousel_widget.dart';
import 'package:kipgo/screens/widgets/notification_icon_button.dart';
import 'package:kipgo/utils/colors.dart';

class ShuttleHome extends StatefulWidget {
  const ShuttleHome({super.key});

  @override
  State<ShuttleHome> createState() => _ShuttleHomeState();
}

class _ShuttleHomeState extends State<ShuttleHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () {},
        child: NotificationIconButton(),
      ),
      // floatingActionButton: NotificationIconButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const ShuttleHeroHeader(),

                Transform.translate(
                  offset: const Offset(0, -35),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: ShuttleBookingCard(),
                  ),
                ),
              ],
            ),
          ),

          /// Remaining Content
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // const SizedBox(height: 10),
                UpcomingBookingCard(),

                const SizedBox(height: 12),

                AdsCarouselWidget(),

                const SizedBox(height: 24),

                ShuttleServicesSection(),

                const SizedBox(height: 12),

                ShuttleWhyUsSection(),

                const SizedBox(height: 12),

                ShuttleContactSection(),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
