import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
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

      await updateDetails(photoUrl: urlDownload);
    } on FirebaseException catch (e) {
      // Firebase specific errors (storage, permissions, etc.)
      setState(() {
        localError =
            '${AppLocalizations.of(context)!.uploadFailed} ${e.message ?? e.code}';
      });
    } catch (e) {
      // Any other type of error
      setState(() {
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
          .update({'vehicle.selfieUrl': photoUrl});

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

  @override
  void initState() {
    super.initState();
    profile = Provider.of<ProfileProvider>(context, listen: false).profile!;
    selfieUrl = Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).profile!.vehicle.selfieUrl;
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
            color: isDark
                ? Color.fromARGB(255, 15, 15, 42)
                : Colors.grey.shade100,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    selfieUrl != '' ? Icons.check_circle : Icons.upload_file,
                    color: selfieUrl != '' ? Colors.green : Colors.grey,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)!.selfieWithLicence,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                ],
              ),
              if (isLoading) ...[SizedBox(height: 10), buildProgress()],
              if (localError != '') ...[
                SizedBox(height: 10),
                ErrorMessageWidget(localErrorMessage: localError),
              ],
              if (localSuccess != '') ...[
                SizedBox(height: 10),
                SuccessMessageWidget(successMessage: localSuccess),
              ],
              if (!isLoading) ...[
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              if (selfieUrl == '' && pickedFile == null) {
                                selectFile();
                              } else if (selfieUrl == '' &&
                                  pickedFile != null) {
                                await uploadFile();
                              } else {}
                            },
                      style: TextButton.styleFrom(
                        backgroundColor: selfieUrl == '' && pickedFile == null
                            ? Colors.black
                            : selfieUrl == '' && pickedFile != null
                            ? Colors.blue
                            : Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(8),
                        ),
                      ),
                      child: Text(
                        selfieUrl == '' && pickedFile == null
                            ? AppLocalizations.of(context)!.selectFile
                            : selfieUrl == '' && pickedFile != null
                            ? AppLocalizations.of(context)!.uploadFile
                            : AppLocalizations.of(context)!.deleteFile,
                      ),
                    ),
                    SizedBox(width: 10),
                    if (selfieUrl != '') ...[
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              child: InteractiveViewer(
                                // allows pinch-to-zoom
                                child: Image.network(
                                  selfieUrl,
                                  width: double.maxFinite,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                        child: Text(AppLocalizations.of(context)!.preview),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
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
          backgroundColor: AppColors.darkLayer,
          color: AppColors.primary,
        );
      } else {
        return Container();
      }
    },
  );
}
