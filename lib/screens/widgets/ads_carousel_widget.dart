import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kipgo/models/ads.dart';
import 'package:kipgo/screens/widgets/ads_fade_carousel.dart';

class AdsCarouselWidget extends StatelessWidget {
  const AdsCarouselWidget({super.key});

  Stream<List<AdsModel>> getActiveAds() {
    return FirebaseFirestore.instance
        .collection('ads')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          final now = DateTime.now();
          return snapshot.docs
              .map((doc) {
                return AdsModel.fromSnapshot(doc);
              })
              .where((ad) {
                final withinDateRange =
                    ad.startDate.isBefore(now) && ad.endDate.isAfter(now);
                return ad.isActive && withinDateRange;
              })
              .toList();
        });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AdsModel>>(
      stream: getActiveAds(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox(); // hide if no ads
        }

        final ads = snapshot.data!;
        return AdsFadeCarousel(ads: ads);
      },
    );
  }
}
