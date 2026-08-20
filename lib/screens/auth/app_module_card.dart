import 'package:flutter/material.dart';
import 'package:kipgo/l10n/app_localizations.dart';

class AppModuleCard extends StatelessWidget {
  const AppModuleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.gradient,
    required this.image,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String badge;
  final List<Color> gradient;
  final String image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          height: 240,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withValues(alpha: .0),
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            children: [
              /// Decorative background circle
              Positioned(
                right: -45,
                top: -45,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: .08),
                  ),
                ),
              ),

              /// Badge
              Positioned(
                left: 24,
                top: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .18),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              /// Main Content
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 60, 150, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Expanded(
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: .92),
                          fontSize: 15,
                          height: 1.45,
                        ),
                      ),
                    ),

                    Row(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.continueAction,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /// Vehicle Image
              Positioned(
                right: 8,
                bottom: 8,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.30,
                  child: Image.asset(image, fit: BoxFit.contain),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
