import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:kipgo/screens/settings/docs/bullet_widget.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:provider/provider.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/profile.dart';
import 'package:kipgo/screens/widgets/error_message.dart';
import 'package:kipgo/screens/widgets/success_message_widget.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class SelfieWithLicenceSection extends StatefulWidget {
  const SelfieWithLicenceSection({super.key});

  @override
  State<SelfieWithLicenceSection> createState() =>
      _SelfieWithLicenceSectionState();
}

class _SelfieWithLicenceSectionState extends State<SelfieWithLicenceSection> {
  late String selfieUrl;
  late String selfieStatus;
  late String selfieText;
  PlatformFile? pickedFile;
  UploadTask? uploadTask;
  late Profile profile;
  bool isLoading = false;
  String localError = '';
  String localSuccess = '';
  bool showLocalImage = false;

  Future<void> selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.image,
    );

    if (result == null) return;

    setState(() {
      pickedFile = result.files.first;
      showLocalImage = true;
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
      showLocalImage = false;
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

      await updateDetails(photoUrl: urlDownload);

      setState(() {
        pickedFile = null;
        showLocalImage = false;
        selfieUrl = urlDownload;
        selfieStatus = AppLocalizations.of(context)!.submitted;
      });
    } on FirebaseException catch (e) {
      // Firebase specific errors (storage, permissions, etc.)
      setState(() {
        showLocalImage = true;
        localError =
            '${AppLocalizations.of(context)!.uploadFailed} ${e.message ?? e.code}';
      });
    } catch (e) {
      // Any other type of error
      setState(() {
        showLocalImage = true;
        localError = '${AppLocalizations.of(context)!.uploadFailed} $e';
      });
    } finally {
      setState(() {
        uploadTask = null;
        isLoading = false;
      });
    }
  }

  Future<void> updateDetails({required String photoUrl}) async {
    try {
      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(profile.id)
          .update({
            'vehicle.selfieUrl': photoUrl,
            'vehicle.selfieStatus': 'Submitted',
            'vehicle.selfieText': '',
            'account.isApproved': false,
          });

      setState(() {
        localSuccess = AppLocalizations.of(context)!.imageUploadedSuccessfully;
      });
    } on FirebaseException catch (e) {
      setState(() {
        localError =
            '${AppLocalizations.of(context)!.uploadFailed} ${e.message ?? e.code}';
      });
    } catch (e) {
      setState(() {
        localError = '${AppLocalizations.of(context)!.uploadFailed} $e';
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteFile() async {
    if (selfieUrl.isEmpty) return;

    setState(() {
      localError = '';
      localSuccess = '';
      isLoading = true;
    });

    try {
      // Delete from Firebase Storage
      final ref = FirebaseStorage.instance.refFromURL(selfieUrl);
      await ref.delete();

      // Clear in Firestore
      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(profile.id)
          .update({
            'vehicle.selfieUrl': '',
            'vehicle.selfieStatus': '',
            'vehicle.selfieText': '',
            'account.isApproved': false,
          });

      setState(() {
        selfieUrl = '';
        pickedFile = null;
        localSuccess = AppLocalizations.of(context)!.fileDeletedSuccessfully;
      });
    } on FirebaseException catch (e) {
      setState(() {
        localError =
            '${AppLocalizations.of(context)!.deleteFailed} ${e.message ?? e.code}';
      });
    } catch (e) {
      setState(() {
        localError = '${AppLocalizations.of(context)!.deleteFailed} $e';
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> confirmDelete() async {
    final ctx = context;
    final shouldDelete = await showDialog<bool>(
      context: ctx,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(AppLocalizations.of(ctx)!.deleteFile),
        content: Text(AppLocalizations.of(ctx)!.areYouSureDeleteFile),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppLocalizations.of(ctx)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(ctx)!.delete),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await deleteFile();
    }
  }

  @override
  void initState() {
    super.initState();
    profile = Provider.of<ProfileProvider>(context, listen: false).profile!;
    selfieUrl = Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).profile!.vehicle.selfieUrl;
    selfieStatus = profile.vehicle.selfieStatus;
    selfieText = profile.vehicle.selfieText;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBarWidget(
        title: AppLocalizations.of(context)!.selfieWithLicence,
      ),
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        padding: EdgeInsets.only(
          left: 12,
          right: 12,
          top: 12,
          bottom: MediaQuery.of(context).padding.bottom > 20
              ? MediaQuery.of(context).padding.bottom
              : 20,
        ),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Consumer<ProfileProvider>(
          builder: (context, p, _) {
            if (p.isLoading) {
              return Center(child: CircularProgressIndicator.adaptive());
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.selfieWithLicence,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 12),
                      BulletWidget(
                        details: AppLocalizations.of(context)!.takeASelfie,
                      ),
                      SizedBox(height: 5),
                      BulletWidget(
                        details: AppLocalizations.of(
                          context,
                        )!.yourFaceAndTheLicence,
                      ),
                      SizedBox(height: 5),
                      BulletWidget(
                        details: AppLocalizations.of(
                          context,
                        )!.thisHelpsUsConfirm,
                      ),
                    ],
                  ),
                  Expanded(child: Container()),
                  if (p.profile!.vehicle.selfieUrl != '') ...[
                    FadeInImage.assetNetwork(
                      fadeInCurve: Curves.easeIn,
                      fadeInDuration: Duration(seconds: 2),
                      width: double.maxFinite,
                      height: 220,
                      fit: BoxFit.fill,
                      placeholder: "assets/images/image_spinner.gif",
                      image: p.profile!.vehicle.selfieUrl,
                      imageErrorBuilder: (c, e, s) => Image.asset(
                        "assets/images/placeholder.jpeg",
                        height: 220,
                        width: double.maxFinite,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.status,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          p.profile!.vehicle.selfieStatus == 'Submitted'
                              ? AppLocalizations.of(context)!.submitted
                              : p.profile!.vehicle.selfieStatus == 'Rejected'
                              ? AppLocalizations.of(context)!.rejected
                              : AppLocalizations.of(context)!.accepted,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color:
                                p.profile!.vehicle.selfieStatus == 'Submitted'
                                ? AppColors.secondary
                                : p.profile!.vehicle.selfieStatus == 'Rejected'
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    if (p.profile!.vehicle.selfieStatus == 'Rejected' &&
                        (p.profile!.vehicle.selfieText != '')) ...[
                      Text(
                        "*${p.profile!.vehicle.selfieText}",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                  Expanded(child: Container()),
                  Column(
                    children: [
                      if (isLoading) ...[buildProgress(), SizedBox(height: 20)],
                      if (localError != '') ...[
                        ErrorMessageWidget(localErrorMessage: localError),
                        SizedBox(height: 10),
                      ],
                      if (localSuccess != '') ...[
                        SuccessMessageWidget(successMessage: localSuccess),
                        SizedBox(height: 10),
                      ],
                      if (pickedFile != null && showLocalImage == true) ...[
                        Image.file(File(pickedFile!.path!)),
                        SizedBox(height: 10),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          onPressed: () {
                            setState(() {
                              pickedFile = null;
                            });
                          },
                          child: Text(AppLocalizations.of(context)!.removeFile),
                        ),
                        SizedBox(height: 10),
                      ],
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                if (p.profile!.vehicle.selfieUrl == '' &&
                                    pickedFile == null) {
                                  selectFile();
                                } else if (p.profile!.vehicle.selfieUrl == '' &&
                                    pickedFile != null) {
                                  await uploadFile();
                                } else {
                                  await confirmDelete();
                                }
                              },
                        style: TextButton.styleFrom(
                          backgroundColor:
                              p.profile!.vehicle.selfieUrl == '' &&
                                  pickedFile == null
                              ? AppColors.tertiary
                              : p.profile!.vehicle.selfieUrl == '' &&
                                    pickedFile != null
                              ? AppColors.primary
                              : Colors.red,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              p.profile!.vehicle.selfieUrl == '' &&
                                      pickedFile == null
                                  ? Icons.file_open_outlined
                                  : pickedFile != null
                                  ? Icons.file_upload
                                  : Icons.delete_outlined,
                              size: 28,
                            ),
                            SizedBox(width: 10),
                            Text(
                              p.profile!.vehicle.selfieUrl == '' &&
                                      pickedFile == null
                                  ? AppLocalizations.of(context)!.selectFile
                                  : selfieUrl == '' && pickedFile != null
                                  ? AppLocalizations.of(context)!.uploadFile
                                  : AppLocalizations.of(context)!.deleteFile,
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
          },
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

        return LinearProgressIndicator(
          value: progress,
          backgroundColor: AppColors.lightLayer,
          minHeight: 20,
          color: AppColors.primary,
        );
      } else {
        return Container();
      }
    },
  );
}
