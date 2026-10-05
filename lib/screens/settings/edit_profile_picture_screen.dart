import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:kipgo/controllers/theme_provider.dart';
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
      localError = '';
      localSuccess = '';
    });
  }

  Future<void> uploadFile() async {
    if (pickedFile == null) {
      setState(() {
        localError = AppLocalizations.of(context)!.noFileSelected;
        localSuccess = '';
      });
      return;
    }

    setState(() {
      localError = '';
      localSuccess = '';
      isLoading = true;
    });

    try {
      final fileExtension = p.extension(pickedFile!.name);
      final fileId = const Uuid().v4();

      final profileId = Provider.of<ProfileProvider>(
        context,
        listen: false,
      ).profile!.id;

      final path = 'files/$profileId/$fileId$fileExtension';

      final file = File(pickedFile!.path!);

      final ref = FirebaseStorage.instance.ref().child(path);

      setState(() {
        uploadTask = ref.putFile(file);
      });

      final snapshot = await uploadTask!.whenComplete(() {});

      final urlDownload = await snapshot.ref.getDownloadURL();

      await updateProfile(photoUrl: urlDownload);
    } on FirebaseException catch (e) {
      setState(() {
        localError =
            '${AppLocalizations.of(context)!.profileImageUploadError} '
            '${e.message ?? e.code}';
      });
    } catch (e) {
      setState(() {
        localError =
            '${AppLocalizations.of(context)!.profileImageUploadError} $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          uploadTask = null;
          isLoading = false;
        });
      }
    }
  }

  Future<void> updateProfile({required String photoUrl}) async {
    try {
      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(profile.id)
          .update({'personal.photoUrl': photoUrl});

      if (!mounted) return;

      setState(() {
        localSuccess = AppLocalizations.of(context)!.profileImageUploadSuccess;
        localError = '';
      });
    } on FirebaseException catch (e) {
      if (!mounted) return;

      setState(() {
        localError =
            '${AppLocalizations.of(context)!.profileImageUploadError} '
            '${e.message ?? e.code}';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        localError =
            '${AppLocalizations.of(context)!.profileImageUploadError} $e';
      });
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    profile = Provider.of<ProfileProvider>(context, listen: false).profile!;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    final backgroundColor = theme.scaffoldBackgroundColor;
    final cardColor = isDark ? AppColors.darkAccent : Colors.white;

    final mutedColor = isDark ? Colors.white60 : Colors.black54;

    final hasExistingPhoto = profile.personal.photoUrl.isNotEmpty;

    final hasSelectedPhoto = pickedFile != null;

    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.primary,

      appBar: AppBarWidget(
        title: AppLocalizations.of(context)!.profilePicture.toUpperCase(),
      ),

      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),

        child: SafeArea(
          top: false,

          child: ListView(
            physics: const BouncingScrollPhysics(),

            padding: const EdgeInsets.fromLTRB(12, 24, 12, 30),

            children: [
              // ─────────────────────────────
              // HEADER
              // ─────────────────────────────
              Text(
                AppLocalizations.of(context)!.profilePicture,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                AppLocalizations.of(context)!.profilePicture,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: mutedColor,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 28),

              // ─────────────────────────────
              // PROFILE IMAGE CARD
              // ─────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 28,
                  horizontal: 20,
                ),

                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.18 : 0.06,
                      ),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],

                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : AppColors.border.withValues(alpha: 0.35),
                  ),
                ),

                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Subtle avatar glow/background
                        Container(
                          width: 218,
                          height: 218,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? AppColors.primary.withValues(alpha: 0.18)
                                : AppColors.primary.withValues(alpha: 0.06),
                          ),
                        ),

                        // Avatar
                        Hero(
                          tag: 'avatarImageChange',

                          child: Container(
                            width: 200,
                            height: 200,

                            decoration: BoxDecoration(
                              shape: BoxShape.circle,

                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.14)
                                    : Colors.white,
                                width: 5,
                              ),

                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.20,
                                  ),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),

                            child: ClipOval(child: _buildProfileImage()),
                          ),
                        ),

                        // Camera button
                        Positioned(
                          right: 0,
                          bottom: 4,

                          child: Material(
                            color: Colors.transparent,

                            child: InkWell(
                              onTap: isLoading ? null : selectFile,

                              borderRadius: BorderRadius.circular(18),

                              child: Container(
                                width: 58,
                                height: 58,

                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,

                                  border: Border.all(
                                    color: cardColor,
                                    width: 4,
                                  ),

                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.30,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),

                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 25,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // Selected image status
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),

                      child: hasSelectedPhoto
                          ? Row(
                              key: const ValueKey('selected'),
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    color: Colors.green,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    pickedFile!.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              key: const ValueKey('current'),
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  hasExistingPhoto
                                      ? Icons.check_circle_outline_rounded
                                      : Icons.person_outline_rounded,
                                  size: 18,
                                  color: hasExistingPhoto
                                      ? Colors.green
                                      : mutedColor,
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  hasExistingPhoto
                                      ? loc.currentProfilePicture
                                      : loc.noProfilePictureSelected,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: mutedColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      loc.tapCameraButton,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: mutedColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ─────────────────────────────
              // UPLOAD PROGRESS
              // ─────────────────────────────
              if (isLoading) ...[
                _buildUploadProgress(isDark: isDark, loc: loc),

                const SizedBox(height: 20),
              ],

              // ─────────────────────────────
              // ERROR / SUCCESS
              // ─────────────────────────────
              if (localError.isNotEmpty) ...[
                ErrorMessageWidget(localErrorMessage: localError),

                const SizedBox(height: 16),
              ],

              if (localSuccess.isNotEmpty) ...[
                SuccessMessageWidget(successMessage: localSuccess),

                const SizedBox(height: 16),
              ],

              // ─────────────────────────────
              // UPLOAD BUTTON
              // ─────────────────────────────
              SizedBox(
                height: 56,

                child: ElevatedButton(
                  onPressed: isLoading ? null : uploadFile,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,

                    disabledBackgroundColor: AppColors.primary.withValues(
                      alpha: 0.45,
                    ),

                    elevation: isLoading ? 0 : 4,

                    shadowColor: AppColors.primary.withValues(alpha: 0.30),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),

                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.cloud_upload_rounded, size: 21),
                            const SizedBox(width: 10),
                            Text(
                              AppLocalizations.of(context)!.uploadImage,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 14),

              // ─────────────────────────────
              // DELETE BUTTON
              // ─────────────────────────────
              SizedBox(
                height: 52,

                child: OutlinedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          // Keep your existing delete
                          // implementation here.
                        },

                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.tertiary,

                    side: BorderSide(
                      color: AppColors.tertiary.withValues(alpha: 0.45),
                    ),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.delete_outline_rounded, size: 21),
                      const SizedBox(width: 9),
                      Text(
                        AppLocalizations.of(context)!.deleteProfilePicture,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ─────────────────────────────
              // SECURITY / PRIVACY NOTE
              // ─────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),

                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.035)
                      : AppColors.primary.withValues(alpha: 0.035),

                  borderRadius: BorderRadius.circular(14),
                ),

                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 19,
                      color: isDark
                          ? Colors.white60
                          : AppColors.primary.withValues(alpha: 0.65),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        loc.useClearPhoto,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: mutedColor,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // PROFILE IMAGE
  // ─────────────────────────────────────────

  Widget _buildProfileImage() {
    if (pickedFile != null) {
      return Image.file(
        File(pickedFile!.path!),
        fit: BoxFit.cover,
        width: 200,
        height: 200,
      );
    }

    if (profile.personal.photoUrl.isEmpty) {
      return Image.asset(
        'assets/images/avatar.png',
        fit: BoxFit.cover,
        width: 200,
        height: 200,
      );
    }

    return Image.network(
      profile.personal.photoUrl,
      fit: BoxFit.cover,
      width: 200,
      height: 200,

      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          return child;
        }

        return const Center(child: CircularProgressIndicator());
      },

      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/images/image_not_found.png',
          fit: BoxFit.cover,
        );
      },
    );
  }

  // ─────────────────────────────────────────
  // UPLOAD PROGRESS
  // ─────────────────────────────────────────

  Widget _buildUploadProgress({
    required bool isDark,
    required AppLocalizations loc,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: isDark ? AppColors.darkAccent : Colors.white,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : AppColors.border.withValues(alpha: 0.4),
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: StreamBuilder<TaskSnapshot>(
        stream: uploadTask?.snapshotEvents,

        builder: (context, snapshot) {
          double progress = 0;

          if (snapshot.hasData) {
            final data = snapshot.data!;

            if (data.totalBytes > 0) {
              progress = data.bytesTransferred / data.totalBytes;
            }
          }

          final percentage = (progress * 100).round();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,

                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(11),
                    ),

                    child: const Icon(
                      Icons.cloud_upload_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 11),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.uploadingProfilePicture,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          loc.pleaseWaitWhileUpload,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: isDark ? Colors.white54 : Colors.black45,
                              ),
                        ),
                      ],
                    ),
                  ),

                  Text(
                    '$percentage%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              ClipRRect(
                borderRadius: BorderRadius.circular(10),

                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,

                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : AppColors.border.withValues(alpha: 0.35),

                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// class EditProfilePictureScreen extends StatefulWidget {
//   const EditProfilePictureScreen({super.key});

//   @override
//   State<EditProfilePictureScreen> createState() =>
//       _EditProfilePictureScreenState();
// }

// class _EditProfilePictureScreenState extends State<EditProfilePictureScreen> {
//   PlatformFile? pickedFile;
//   UploadTask? uploadTask;
//   late Profile profile;
//   bool isLoading = false;
//   String localError = '';
//   String localSuccess = '';

//   Future<void> selectFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       allowMultiple: false,
//       type: FileType.image,
//     );

//     if (result == null) return;

//     setState(() {
//       pickedFile = result.files.first;
//     });
//   }

//   Future<void> uploadFile() async {
//     if (pickedFile == null) {
//       setState(() {
//         localError = AppLocalizations.of(context)!.noFileSelected;
//       });
//       return;
//     }

//     setState(() {
//       localError = '';
//       localSuccess = '';
//       isLoading = true;
//     });

//     try {
//       var fileExtension = p.extension(pickedFile!.name);
//       var fileId = const Uuid().v4();

//       final path =
//           'files/${Provider.of<ProfileProvider>(context, listen: false).profile!.id}/$fileId$fileExtension';
//       final file = File(pickedFile!.path!);

//       final ref = FirebaseStorage.instance.ref().child(path);

//       setState(() {
//         uploadTask = ref.putFile(file);
//       });

//       final snapshot = await uploadTask!.whenComplete(() {});
//       final urlDownload = await snapshot.ref.getDownloadURL();

//       await updateProfile(photoUrl: urlDownload);
//     } on FirebaseException catch (e) {
//       // Firebase specific errors (storage, permissions, etc.)
//       setState(() {
//         localError =
//             '${AppLocalizations.of(context)!.profileImageUploadError} ${e.message ?? e.code}';
//       });
//     } catch (e) {
//       // Any other type of error
//       setState(() {
//         localError =
//             '${AppLocalizations.of(context)!.profileImageUploadError} $e';
//       });
//     } finally {
//       setState(() {
//         uploadTask = null;
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> updateProfile({required String photoUrl}) async {
//     try {
//       await FirebaseFirestore.instance
//           .collection('profiles')
//           .doc(profile.id)
//           .update({'personal.photoUrl': photoUrl});

//       setState(() {
//         localSuccess = AppLocalizations.of(context)!.profileImageUploadSuccess;
//       });
//     } on FirebaseException catch (e) {
//       setState(() {
//         localError =
//             '${AppLocalizations.of(context)!.profileImageUploadError} ${e.message ?? e.code}';
//       });
//     } catch (e) {
//       setState(() {
//         localError =
//             '${AppLocalizations.of(context)!.profileImageUploadError} $e';
//       });
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     profile = Provider.of<ProfileProvider>(context, listen: false).profile!;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.primary,
//       appBar: AppBarWidget(
//         title: AppLocalizations.of(context)!.profilePicture.toUpperCase(),
//       ),
//       body: Container(
//         width: double.maxFinite,
//         padding: EdgeInsets.all(18),
//         decoration: BoxDecoration(
//           color: Theme.of(context).scaffoldBackgroundColor,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         child: ListView(
//           physics: const BouncingScrollPhysics(),
//           children: [
//             SizedBox(height: 30),
//             Center(
//               child: Stack(
//                 children: [
//                   Hero(
//                     tag: 'avatarImageChange',
//                     child: ClipOval(
//                       child: Material(
//                         color: Colors.transparent,
//                         child: pickedFile == null
//                             ? profile.personal.photoUrl == ''
//                                   ? Ink.image(
//                                       image: const AssetImage(
//                                         'assets/images/avatar.png',
//                                       ),
//                                       fit: BoxFit.cover,
//                                       width: 200,
//                                       height: 200,
//                                     )
//                                   : SizedBox(
//                                       width: 200,
//                                       height: 200,
//                                       child: InkWell(
//                                         onTap: selectFile,
//                                         child: Image.network(
//                                           profile.personal.photoUrl,
//                                           fit: BoxFit.cover,
//                                           loadingBuilder:
//                                               (context, child, progress) {
//                                                 if (progress == null) {
//                                                   return child;
//                                                 }
//                                                 return const Center(
//                                                   child:
//                                                       CircularProgressIndicator(),
//                                                 );
//                                               },
//                                           errorBuilder:
//                                               (
//                                                 context,
//                                                 error,
//                                                 stackTrace,
//                                               ) => Image.asset(
//                                                 'assets/images/image_not_found.png',
//                                                 fit: BoxFit.cover,
//                                               ),
//                                         ),
//                                       ),
//                                     )
//                             : Ink.image(
//                                 image: FileImage(File(pickedFile!.path!)),
//                                 fit: BoxFit.cover,
//                                 width: 200,
//                                 height: 200,
//                                 // child: InkWell(onTap: selectFile),
//                               ),
//                       ),
//                     ),
//                   ),
//                   Positioned(
//                     bottom: 5,
//                     right: 5,
//                     child: ClipOval(
//                       child: Container(
//                         color: Colors.white,
//                         padding: const EdgeInsets.all(3),
//                         child: ClipOval(
//                           child: Container(
//                             padding: const EdgeInsets.all(8),
//                             color: AppColors.primary,
//                             child: InkWell(
//                               onTap: selectFile,
//                               child: const Icon(
//                                 Icons.add_a_photo,
//                                 color: Colors.white,
//                                 size: 30,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 45),
//             ElevatedButton(
//               onPressed: isLoading ? null : uploadFile,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primary,
//                 foregroundColor: Colors.white,
//                 padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
//                 textStyle: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(5),
//                 ),
//               ),
//               child: Text(AppLocalizations.of(context)!.uploadImage),
//             ),
//             if (isLoading) ...[SizedBox(height: 10), buildProgress()],
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {},
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.tertiary,
//                 foregroundColor: Colors.white,
//                 padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
//                 textStyle: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(5),
//                 ),
//               ),
//               child: Text(AppLocalizations.of(context)!.deleteProfilePicture),
//             ),
//             if (localError != '') ...[
//               SizedBox(height: 10),
//               ErrorMessageWidget(localErrorMessage: localError),
//             ],
//             if (localSuccess != '') ...[
//               SizedBox(height: 10),
//               SuccessMessageWidget(successMessage: localSuccess),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildProgress() => StreamBuilder<TaskSnapshot>(
//     stream: uploadTask?.snapshotEvents,
//     builder: (context, snapshot) {
//       if (snapshot.hasData) {
//         final data = snapshot.data!;
//         double progress = data.bytesTransferred / data.totalBytes;

//         return SizedBox(
//           height: 50,
//           child: Stack(
//             fit: StackFit.expand,
//             children: [
//               LinearProgressIndicator(
//                 value: progress,
//                 backgroundColor: AppColors.darkLayer,
//                 color: AppColors.primary,
//               ),
//               Center(
//                 child: Text(
//                   '${(100 * progress).roundToDouble()}%',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       } else {
//         return Container();
//       }
//     },
//   );
// }
