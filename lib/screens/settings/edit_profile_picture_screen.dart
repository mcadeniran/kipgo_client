import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/profile.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/screens/widgets/error_message.dart';
import 'package:kipgo/screens/widgets/success_message_widget.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class EditProfilePictureScreen extends StatefulWidget {
  const EditProfilePictureScreen({super.key});

  @override
  State<EditProfilePictureScreen> createState() =>
      _EditProfilePictureScreenState();
}

class _EditProfilePictureScreenState extends State<EditProfilePictureScreen> {
  PlatformFile? pickedFile;
  UploadTask? uploadTask;
  late Profile profile;
  bool isLoading = false;
  String localError = '';
  String localSuccess = '';

  Future<void> selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.image,
    );

    if (result == null) return;

    setState(() {
      pickedFile = result.files.first;
    });
  }

  Future<void> uploadFile() async {
    if (pickedFile == null) {
      setState(() {
        localError = AppLocalizations.of(context)!.noFileSelected;
      });
      return;
    }

    setState(() {
      localError = '';
      localSuccess = '';
      isLoading = true;
    });

    try {
      var fileExtension = p.extension(pickedFile!.name);
      var fileId = const Uuid().v4();

      final path =
          'files/${Provider.of<ProfileProvider>(context, listen: false).profile!.id}/$fileId$fileExtension';
      final file = File(pickedFile!.path!);

      final ref = FirebaseStorage.instance.ref().child(path);

      setState(() {
        uploadTask = ref.putFile(file);
      });

      final snapshot = await uploadTask!.whenComplete(() {});
      final urlDownload = await snapshot.ref.getDownloadURL();

      await updateProfile(photoUrl: urlDownload);
    } on FirebaseException catch (e) {
      // Firebase specific errors (storage, permissions, etc.)
      setState(() {
        localError =
            '${AppLocalizations.of(context)!.profileImageUploadError} ${e.message ?? e.code}';
      });
    } catch (e) {
      // Any other type of error
      setState(() {
        localError =
            '${AppLocalizations.of(context)!.profileImageUploadError} $e';
      });
    } finally {
      setState(() {
        uploadTask = null;
        isLoading = false;
      });
    }
  }

  Future<void> updateProfile({required String photoUrl}) async {
    try {
      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(profile.id)
          .update({'personal.photoUrl': photoUrl});

      setState(() {
        localSuccess = AppLocalizations.of(context)!.profileImageUploadSuccess;
      });
    } on FirebaseException catch (e) {
      setState(() {
        localError =
            '${AppLocalizations.of(context)!.profileImageUploadError} ${e.message ?? e.code}';
      });
    } catch (e) {
      setState(() {
        localError =
            '${AppLocalizations.of(context)!.profileImageUploadError} $e';
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    profile = Provider.of<ProfileProvider>(context, listen: false).profile!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBarWidget(title: 'Profile Picture'),
      body: Container(
        width: double.maxFinite,
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            SizedBox(height: 30),
            Center(
              child: Stack(
                children: [
                  ClipOval(
                    child: Material(
                      color: Colors.transparent,
                      child: pickedFile == null
                          ? profile.personal.photoUrl == ''
                                ? Ink.image(
                                    image: const AssetImage(
                                      'assets/images/avatar.png',
                                    ),
                                    fit: BoxFit.cover,
                                    width: 200,
                                    height: 200,
                                  )
                                : Ink.image(
                                    image: NetworkImage(
                                      profile.personal.photoUrl,
                                    ),
                                    fit: BoxFit.cover,
                                    width: 200,
                                    height: 200,
                                    // child: InkWell(onTap: selectFile),
                                  )
                          : Ink.image(
                              image: FileImage(File(pickedFile!.path!)),
                              fit: BoxFit.cover,
                              width: 200,
                              height: 200,
                              // child: InkWell(onTap: selectFile),
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: ClipOval(
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(3),
                        child: ClipOval(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            color: AppColors.primary,
                            child: InkWell(
                              onTap: selectFile,
                              child: const Icon(
                                Icons.add_a_photo,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 45),
            ElevatedButton(
              onPressed: isLoading ? null : uploadFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: const Text('Upload Image'),
            ),
            if (isLoading) ...[SizedBox(height: 10), buildProgress()],
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tertiary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: const Text(' Delete profile picture '),
            ),
            if (localError != '') ...[
              SizedBox(height: 10),
              ErrorMessageWidget(localErrorMessage: localError),
            ],
            if (localSuccess != '') ...[
              SizedBox(height: 10),
              SuccessMessageWidget(successMessage: localSuccess),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildProgress() => StreamBuilder<TaskSnapshot>(
    stream: uploadTask?.snapshotEvents,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        final data = snapshot.data!;
        double progress = data.bytesTransferred / data.totalBytes;

        return SizedBox(
          height: 50,
          child: Stack(
            fit: StackFit.expand,
            children: [
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.darkLayer,
                color: AppColors.primary,
              ),
              Center(
                child: Text(
                  '${(100 * progress).roundToDouble()}%',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        return Container();
      }
    },
  );
}
