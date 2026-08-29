import 'package:flutter/material.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/utils/colors.dart';

class KipgoSplashScreen extends StatefulWidget {
  final Widget child;

  const KipgoSplashScreen({super.key, required this.child});

  @override
  State<KipgoSplashScreen> createState() => _KipgoSplashScreenState();
}

class _KipgoSplashScreenState extends State<KipgoSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;

  late final Animation<double> _ringScale;
  late final Animation<double> _ringOpacity;

  late final Animation<double> _secondRingScale;
  late final Animation<double> _secondRingOpacity;

  late final Animation<double> _brandOpacity;
  late final Animation<Offset> _brandSlide;

  late final Animation<double> _taglineOpacity;
  late final Animation<double> _loaderOpacity;

  bool _showApp = false;

  @override
  void initState() {
    super.initState();

    // ==========================================================
    // MAIN CONTROLLER
    // ==========================================================

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // ==========================================================
    // LOGO
    // ==========================================================

    _logoScale = Tween<double>(begin: 0.72, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.42, curve: Curves.easeOutBack),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.22, curve: Curves.easeOut),
      ),
    );

    // ==========================================================
    // OUTER RING
    // ==========================================================

    _ringScale = Tween<double>(begin: 0.55, end: 1.55).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.05, 0.58, curve: Curves.easeOut),
      ),
    );

    _ringOpacity = Tween<double>(begin: 0.45, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.05, 0.65, curve: Curves.easeOut),
      ),
    );

    // ==========================================================
    // SECOND RING
    // ==========================================================

    _secondRingScale = Tween<double>(begin: 0.65, end: 1.25).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.12, 0.68, curve: Curves.easeOut),
      ),
    );

    _secondRingOpacity = Tween<double>(begin: 0.35, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.12, 0.72, curve: Curves.easeOut),
      ),
    );

    // ==========================================================
    // BRAND TEXT
    // ==========================================================

    _brandOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.30, 0.58, curve: Curves.easeOut),
      ),
    );

    _brandSlide = Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.30, 0.58, curve: Curves.easeOutCubic),
          ),
        );

    // ==========================================================
    // TAGLINE
    // ==========================================================

    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.48, 0.70, curve: Curves.easeOut),
      ),
    );

    // ==========================================================
    // LOADING INDICATOR
    // ==========================================================

    _loaderOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.58, 0.78, curve: Curves.easeOut),
      ),
    );

    _startAnimation();
  }

  // ==========================================================
  // START SPLASH
  // ==========================================================

  Future<void> _startAnimation() async {
    await _controller.forward();

    await Future.delayed(const Duration(milliseconds: 250));

    if (!mounted) return;

    setState(() {
      _showApp = true;
    });
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    if (_showApp) {
      return widget.child;
    }

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ======================================================
          // BACKGROUND
          // ======================================================
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.85,
                colors: [
                  AppColors.lightLayer.withValues(alpha: 0.18),
                  AppColors.primary,
                ],
              ),
            ),
          ),

          // ======================================================
          // SUBTLE BACKGROUND GLOW
          // ======================================================
          IgnorePointer(
            child: Center(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.lightLayer.withValues(alpha: 0.10),
                      blurRadius: 100,
                      spreadRadius: 35,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ======================================================
          // OUTER RING
          // ======================================================
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _ringOpacity.value,
                  child: Transform.scale(scale: _ringScale.value, child: child),
                );
              },
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

          // ======================================================
          // SECOND RING
          // ======================================================
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _secondRingOpacity.value,
                  child: Transform.scale(
                    scale: _secondRingScale.value,
                    child: child,
                  ),
                );
              },
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.65),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // ======================================================
          // CENTER LOGO
          // ======================================================
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _logoOpacity.value,
                  child: Transform.scale(scale: _logoScale.value, child: child),
                );
              },
              child: Container(
                width: 220,
                height: 220,
                decoration: const BoxDecoration(
                  // color: Colors.white,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(20),
                child: Image.asset(
                  'assets/images/kipgo_transparent.png',
                  fit: BoxFit.contain,
                  width: 220,
                  height: 220,
                ),
              ),
            ),
          ),

          // ======================================================
          // BRAND TEXT
          //
          // Positioned independently from the logo so the logo
          // remains perfectly centered on every screen.
          // ======================================================
          Positioned(
            left: 0,
            right: 0,
            bottom: 105,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _brandOpacity,
                  child: SlideTransition(position: _brandSlide, child: child),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // const Text(
                  //   'KIPGO',
                  //   style: TextStyle(
                  //     color: Colors.white,
                  //     fontSize: 25,
                  //     fontWeight: FontWeight.w900,
                  //     letterSpacing: 5,
                  //   ),
                  // ),

                  // const SizedBox(height: 7),
                  AnimatedBuilder(
                    animation: _taglineOpacity,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _taglineOpacity.value,
                        child: child,
                      );
                    },
                    child: Text(
                      AppLocalizations.of(
                        context,
                      )!.travelMadeEasy.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ======================================================
          // LOADING INDICATOR
          // ======================================================
          Positioned(
            left: 0,
            right: 0,
            bottom: 52,
            child: AnimatedBuilder(
              animation: _loaderOpacity,
              builder: (context, child) {
                return Opacity(opacity: _loaderOpacity.value, child: child);
              },
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withValues(alpha: 0.55),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// class KipgoSplashScreen extends StatefulWidget {
//   final VoidCallback onFinished;

//   const KipgoSplashScreen({super.key, required this.onFinished});

//   @override
//   State<KipgoSplashScreen> createState() => _KipgoSplashScreenState();
// }

// class _KipgoSplashScreenState extends State<KipgoSplashScreen>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _pulseController;

//   bool _finished = false;

//   @override
//   void initState() {
//     super.initState();

//     _pulseController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1800),
//     )..repeat(reverse: true);

//     _finishSplash();
//   }

//   Future<void> _finishSplash() async {
//     // Give the Flutter splash enough time to make the transition
//     // feel intentional without unnecessarily delaying the user.
//     await Future.delayed(const Duration(milliseconds: 2200));

//     if (!mounted || _finished) return;

//     _finished = true;
//     widget.onFinished();
//   }

//   @override
//   void dispose() {
//     _pulseController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.primary,
//       body: Stack(
//         fit: StackFit.expand,
//         children: [
//           // ----------------------------------------------------------
//           // Background atmosphere
//           // ----------------------------------------------------------
//           Positioned(
//             top: -140,
//             right: -110,
//             child: _GlowCircle(
//               size: 360,
//               color: AppColors.secondary,
//               opacity: .10,
//             ),
//           ),

//           Positioned(
//             bottom: -180,
//             left: -140,
//             child: _GlowCircle(
//               size: 420,
//               color: AppColors.tertiary,
//               opacity: .10,
//             ),
//           ),

//           Positioned(
//             top: MediaQuery.of(context).size.height * .35,
//             left: -160,
//             child: _GlowCircle(
//               size: 300,
//               color: AppColors.lightLayer,
//               opacity: .035,
//             ),
//           ),

//           // ----------------------------------------------------------
//           // Main content
//           // ----------------------------------------------------------
//           Center(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Logo
//                 Image.asset(
//                       'assets/images/kipgo_transparent.png',
//                       width: 185,
//                       fit: BoxFit.contain,
//                     )
//                     .animate()
//                     .fadeIn(duration: 700.ms, curve: Curves.easeOut)
//                     .scale(
//                       begin: const Offset(.78, .78),
//                       end: const Offset(1, 1),
//                       duration: 900.ms,
//                       curve: Curves.easeOutBack,
//                     ),

//                 const SizedBox(height: 18),

//                 // Tagline
//                 Text(
//                       AppLocalizations.of(
//                         context,
//                       )!.travelMadeEasy.toUpperCase(),
//                       textAlign: TextAlign.center,
//                       style: GoogleFonts.poppins(
//                         color: Colors.white.withValues(alpha: .86),
//                         fontSize: 10.5,
//                         fontWeight: FontWeight.w600,
//                         letterSpacing: 2.2,
//                       ),
//                     )
//                     .animate()
//                     .fadeIn(delay: 450.ms, duration: 650.ms)
//                     .slideY(
//                       begin: .25,
//                       end: 0,
//                       delay: 450.ms,
//                       duration: 650.ms,
//                       curve: Curves.easeOut,
//                     ),

//                 const SizedBox(height: 34),

//                 // Moving travel indicator
//                 _TravelIndicator(
//                   controller: _pulseController,
//                 ).animate().fadeIn(delay: 850.ms, duration: 450.ms),

//                 const SizedBox(height: 42),

//                 // Small loading text
//                 Text(
//                   'YOUR JOURNEY STARTS HERE',
//                   textAlign: TextAlign.center,
//                   style: GoogleFonts.poppins(
//                     color: Colors.white.withValues(alpha: .38),
//                     fontSize: 8,
//                     fontWeight: FontWeight.w500,
//                     letterSpacing: 1.7,
//                   ),
//                 ).animate().fadeIn(delay: 1100.ms, duration: 500.ms),
//               ],
//             ),
//           ),

//           // ----------------------------------------------------------
//           // Bottom branding
//           // ----------------------------------------------------------
//           Positioned(
//             left: 0,
//             right: 0,
//             bottom: 28,
//             child: Text(
//               'KIPGO',
//               textAlign: TextAlign.center,
//               style: GoogleFonts.poppins(
//                 color: Colors.white.withValues(alpha: .22),
//                 fontSize: 9,
//                 fontWeight: FontWeight.w600,
//                 letterSpacing: 3,
//               ),
//             ).animate().fadeIn(delay: 1200.ms, duration: 500.ms),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _TravelIndicator extends StatelessWidget {
//   final AnimationController controller;

//   const _TravelIndicator({required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: controller,
//       builder: (context, child) {
//         final position = Curves.easeInOut.transform(controller.value);

//         return SizedBox(
//           width: 145,
//           height: 14,
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               // Left track
//               Positioned(
//                 left: 0,
//                 right: 0,
//                 child: Container(
//                   height: 1,
//                   color: Colors.white.withValues(alpha: .18),
//                 ),
//               ),

//               // Moving dot
//               Positioned(
//                 left: position * 125,
//                 child: Container(
//                   width: 10,
//                   height: 10,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: AppColors.secondary,
//                     boxShadow: [
//                       BoxShadow(
//                         color: AppColors.secondary.withValues(alpha: .45),
//                         blurRadius: 12,
//                         spreadRadius: 2,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// class _GlowCircle extends StatelessWidget {
//   final double size;
//   final Color color;
//   final double opacity;

//   const _GlowCircle({
//     required this.size,
//     required this.color,
//     required this.opacity,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return IgnorePointer(
//       child: Container(
//         width: size,
//         height: size,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: color.withValues(alpha: opacity),
//         ),
//       ),
//     );
//   }
// }
