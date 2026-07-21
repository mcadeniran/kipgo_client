import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/utils/colors.dart';

class DriverDocumentsStep extends StatelessWidget {
  final String? licenseFront;
  final String? licenseBack;
  final String? idCard;
  final String? licenseFrontUrl;
  final String? licenseBackUrl;
  final String? idCardUrl;

  final VoidCallback onFrontUpload;
  final VoidCallback onBackUpload;
  final VoidCallback onIdUpload;

  const DriverDocumentsStep({
    super.key,
    required this.licenseFront,
    required this.licenseBack,
    required this.idCard,
    required this.onFrontUpload,
    required this.onBackUpload,
    required this.onIdUpload,
    required this.licenseFrontUrl,
    required this.licenseBackUrl,
    required this.idCardUrl,
  });

  Widget tile({
    required BuildContext context,
    required String title,
    String? localPath,
    String? networkUrl,
    required VoidCallback onTap,
  }) {
    Widget content;

    if (localPath != null) {
      content = Image.file(File(localPath), fit: BoxFit.contain);
    } else if (networkUrl != null) {
      content = Image.network(
        networkUrl,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;

          return Image.asset(
            "assets/images/image_spinner.gif",
            fit: BoxFit.cover,
          );
        },
        errorBuilder: (_, _, _) =>
            Image.asset("assets/images/placeholder.jpeg", fit: BoxFit.cover),
      );
    } else {
      content = Center(
        child: Text(AppLocalizations.of(context)!.uploadTitle(title)),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Stack(
          children: [
            AspectRatio(aspectRatio: 16 / 9, child: content),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.primary,
                ),
                child: const Icon(Icons.edit, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;
    return Column(
      children: [
        tile(
          context: context,
          title: loc.licenseFront,
          localPath: licenseFront,
          networkUrl: licenseFrontUrl,
          onTap: onFrontUpload,
        ),
        tile(
          context: context,
          title: loc.licenseBack,
          localPath: licenseBack,
          networkUrl: licenseBackUrl,
          onTap: onBackUpload,
        ),

        tile(
          context: context,
          title: loc.governmentID,
          localPath: idCard,
          networkUrl: idCardUrl,
          onTap: onIdUpload,
        ),
      ],
    );
  }
}
