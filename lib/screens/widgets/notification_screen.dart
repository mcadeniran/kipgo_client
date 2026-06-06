import 'package:flutter/material.dart';
import 'package:kipgo/controllers/inapp_notification_provider.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/helpers/notification_navigator.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InAppNotificationProvider>(context);
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      appBar: AppBarWidget(
        title: AppLocalizations.of(context)!.notifications,
        actions: [
          IconButton(
            icon: Icon(Icons.done_all),
            onPressed: () {
              final userId = Provider.of<ProfileProvider>(
                context,
                listen: false,
              ).profile!.id;

              provider.markAllAsRead(userId);
            },
          ),
        ],
      ),
      backgroundColor: AppColors.primary,
      body: Container(
        padding: EdgeInsets.all(12),
        clipBehavior: Clip.hardEdge,
        width: double.maxFinite,
        height: double.maxFinite,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: provider.notifications.isEmpty
            ? Center(child: Text(AppLocalizations.of(context)!.noNotification))
            : ListView.separated(
                separatorBuilder: (context, index) => SizedBox(height: 10),
                clipBehavior: Clip.hardEdge,

                itemCount: provider.notifications.length,
                itemBuilder: (context, index) {
                  final notif = provider.notifications[index];
                  return InkWell(
                    onTap: () {
                      provider.markAsRead(notif.id);

                      if (notif.bookingId == null) return;

                      NotificationNavigator.navigate(
                        context,
                        audience: notif.audience,
                        bookingId: notif.bookingId!,
                      );

                      // if (notif.type == 'bookingUpdate') {
                      //   Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //       builder: (_) =>
                      //           BookingDetailsPage(bookingId: notif.bookingId!),
                      //     ),
                      //   );
                      // } else if (notif.type == 'newBooking') {
                      //   Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //       builder: (_) => RentalBookingDetailsPage(
                      //         bookingId: notif.bookingId!,
                      //       ),
                      //     ),
                      //   );
                      // }
                    },
                    child: Container(
                      padding: EdgeInsets.all(12),
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkLayer
                            : AppColors.lightAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.primary,
                            child: Icon(
                              notif.isRead
                                  ? Icons.mark_email_read_outlined
                                  : Icons.email_outlined,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notif.title,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                Text(
                                  notif.body,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            timeago.format(notif.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
