import 'package:flutter/material.dart';

class DriverDocumentsDetails extends StatelessWidget {
  final String? licenseFront;
  final String? licenseBack;
  final String? idCard;

  final VoidCallback onUploadLicenseFront;
  final VoidCallback onUploadLicenseBack;
  final VoidCallback onUploadId;

  const DriverDocumentsDetails({
    super.key,
    required this.licenseFront,
    required this.licenseBack,
    required this.idCard,
    required this.onUploadLicenseFront,
    required this.onUploadLicenseBack,
    required this.onUploadId,
  });

  Widget uploadTile(
    BuildContext context,
    String title,
    String? image,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.4)),
        ),
        child: image == null
            ? Center(child: Text("Upload $title"))
            : ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(image, fit: BoxFit.cover),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        uploadTile(
          context,
          "License Front",
          licenseFront,
          onUploadLicenseFront,
        ),
        uploadTile(context, "License Back", licenseBack, onUploadLicenseBack),
        uploadTile(context, "Government ID", idCard, onUploadId),
      ],
    );
  }
}
