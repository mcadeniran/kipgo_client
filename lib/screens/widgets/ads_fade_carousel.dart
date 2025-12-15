import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kipgo/models/ads.dart';
import 'package:url_launcher/url_launcher.dart';

class AdsFadeCarousel extends StatefulWidget {
  final List<AdsModel> ads;
  const AdsFadeCarousel({super.key, required this.ads});

  @override
  State<AdsFadeCarousel> createState() => _AdsFadeCarouselState();
}

class _AdsFadeCarouselState extends State<AdsFadeCarousel> {
  final PageController _pageController = PageController();
  int currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    if (widget.ads.length <= 1) return; // no autoplay for 1 ad

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) return;

      final nextIndex = (currentIndex + 1) % widget.ads.length;

      setState(() {
        currentIndex = nextIndex;
      });

      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.ads.length,
        onPageChanged: (i) => setState(() => currentIndex = i),
        itemBuilder: (context, index) {
          final ad = widget.ads[index];

          return AnimatedOpacity(
            duration: const Duration(milliseconds: 600),
            opacity: currentIndex == index ? 1.0 : 0.0,
            child: GestureDetector(
              onTap: () async {
                final uri = Uri.parse(ad.linkUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(ad.bannerUrl, fit: BoxFit.cover),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.6),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ad.title,
                              style: Theme.of(context).textTheme.titleLarge!
                                  .copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ad.description,
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(color: Colors.white70),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
