import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kipgo/l10n/app_localizations.dart';

Future<File?> pickImage(BuildContext context) async {
  final ImagePicker picker = ImagePicker();

  final XFile? picked = await showModalBottomSheet<XFile?>(
    clipBehavior: Clip.hardEdge,
    context: context,
    builder: (_) {
      return SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: Text(AppLocalizations.of(context)!.chooseFromGallery),
              onTap: () async {
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 70,
                );
                Navigator.pop(context, image);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(AppLocalizations.of(context)!.takeAPhoto),
              onTap: () async {
                final XFile? image = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 70,
                );
                Navigator.pop(context, image);
              },
            ),
          ],
        ),
      );
    },
  );
  if (picked == null) return null;

  return File(picked.path);
}
