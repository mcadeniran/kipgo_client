import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/controllers/theme_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/models/profile.dart';
import 'package:kipgo/screens/settings/docs/bullet_widget.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/screens/widgets/error_message.dart';
import 'package:kipgo/screens/widgets/success_message_widget.dart';
import 'package:kipgo/utils/colors.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class DocumentUploadSection extends StatefulWidget {
  final String title;
  final String instructionsTitle;
  final List<String> instructions;

  final String documentUrl;
  final String documentStatus;
  final String rejectionReason;

  final String firestoreUrlField;
  final String firestoreStatusField;
  final String firestoreTextField;

  const DocumentUploadSection({
    super.key,
    required this.title,
    required this.instructionsTitle,
    required this.instructions,
    required this.documentUrl,
    required this.documentStatus,
    required this.rejectionReason,
    required this.firestoreUrlField,
    required this.firestoreStatusField,
    required this.firestoreTextField,
  });

  @override
  State<DocumentUploadSection> createState() => _DocumentUploadSectionState();
}

class _DocumentUploadSectionState extends State<DocumentUploadSection> {
  PlatformFile? pickedFile;
  UploadTask? uploadTask;

  late Profile profile;

  bool isLoading = false;

  String localError = '';
  String localSuccess = '';

  @override
  void initState() {
    super.initState();

    profile = Provider.of<ProfileProvider>(context, listen: false).profile!;
  }

  bool get hasUploadedDocument => widget.documentUrl.isNotEmpty;

  bool get hasSelectedDocument => pickedFile != null;

  bool get isRejected => widget.documentStatus == 'Rejected';

  bool get isSubmitted => widget.documentStatus == 'Submitted';

  bool get isAccepted => widget.documentStatus == 'Accepted';

  Future<void> selectFile() async {
    if (isLoading) return;

    setState(() {
      localError = '';
      localSuccess = '';
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.image,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.first;

      if (file.path == null || file.path!.isEmpty) {
        if (!mounted) return;

        setState(() {
          localError = AppLocalizations.of(context)!.uploadFailed;
        });

        return;
      }

      if (!mounted) return;

      setState(() {
        pickedFile = file;
        localError = '';
        localSuccess = '';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        localError = '${AppLocalizations.of(context)!.uploadFailed} $e';
      });
    }
  }

  Future<void> uploadFile() async {
    if (pickedFile == null) {
      if (!mounted) return;

      setState(() {
        localError = AppLocalizations.of(context)!.noFileSelected;
      });

      return;
    }

    if (pickedFile!.path == null) {
      if (!mounted) return;

      setState(() {
        localError = AppLocalizations.of(context)!.uploadFailed;
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

      final path = 'files/${profile.id}/$fileId$fileExtension';

      final file = File(pickedFile!.path!);

      final ref = FirebaseStorage.instance.ref().child(path);

      final task = ref.putFile(file);

      if (!mounted) return;

      setState(() {
        uploadTask = task;
      });

      final snapshot = await task;

      final urlDownload = await snapshot.ref.getDownloadURL();

      await _updateFirestore(urlDownload);

      if (!mounted) return;

      setState(() {
        pickedFile = null;
        localSuccess = AppLocalizations.of(context)!.imageUploadedSuccessfully;
      });

      _refreshProfileProvider();
    } on FirebaseException catch (e) {
      if (!mounted) return;

      setState(() {
        localError =
            '${AppLocalizations.of(context)!.uploadFailed} '
            '${e.message ?? e.code}';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        localError = '${AppLocalizations.of(context)!.uploadFailed} $e';
      });
    } finally {
      if (!mounted) return;

      setState(() {
        uploadTask = null;
        isLoading = false;
      });
    }
  }

  Future<void> _updateFirestore(String photoUrl) async {
    await FirebaseFirestore.instance
        .collection('profiles')
        .doc(profile.id)
        .update({
          widget.firestoreUrlField: photoUrl,
          widget.firestoreStatusField: 'Submitted',
          widget.firestoreTextField: '',
          'account.isApproved': false,
        });
  }

  Future<void> deleteFile() async {
    if (widget.documentUrl.isEmpty) return;

    setState(() {
      localError = '';
      localSuccess = '';
      isLoading = true;
    });

    try {
      final ref = FirebaseStorage.instance.refFromURL(widget.documentUrl);

      await ref.delete();

      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(profile.id)
          .update({
            widget.firestoreUrlField: '',
            widget.firestoreStatusField: '',
            widget.firestoreTextField: '',
            'account.isApproved': false,
          });

      if (!mounted) return;

      setState(() {
        pickedFile = null;
        localSuccess = AppLocalizations.of(context)!.fileDeletedSuccessfully;
      });

      _refreshProfileProvider();
    } on FirebaseException catch (e) {
      if (!mounted) return;

      setState(() {
        localError =
            '${AppLocalizations.of(context)!.deleteFailed} '
            '${e.message ?? e.code}';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        localError = '${AppLocalizations.of(context)!.deleteFailed} $e';
      });
    } finally {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> confirmDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final isDark = Provider.of<ThemeProvider>(
          dialogContext,
          listen: false,
        ).isDarkMode;

        return AlertDialog(
          backgroundColor: isDark
              ? AppColors.darkAccent
              : Theme.of(dialogContext).dialogBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            AppLocalizations.of(dialogContext)!.deleteFile,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            AppLocalizations.of(dialogContext)!.areYouSureDeleteFile,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(AppLocalizations.of(dialogContext)!.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(AppLocalizations.of(dialogContext)!.delete),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await deleteFile();
    }
  }

  void _refreshProfileProvider() {
    // The Firestore listener in ProfileProvider should normally
    // update the profile automatically. This method exists as a
    // single place to trigger additional refresh logic later if
    // your provider requires it.
  }

  Future<void> _handlePrimaryAction() async {
    if (isLoading) return;

    if (!hasUploadedDocument && !hasSelectedDocument) {
      await selectFile();
      return;
    }

    if (!hasUploadedDocument && hasSelectedDocument) {
      await uploadFile();
      return;
    }

    await confirmDelete();
  }

  void _removeSelectedFile() {
    if (isLoading) return;

    setState(() {
      pickedFile = null;
      localError = '';
      localSuccess = '';
    });
  }

  String _localizedStatus(BuildContext context) {
    if (widget.documentStatus == 'Submitted') {
      return AppLocalizations.of(context)!.submitted;
    }

    if (widget.documentStatus == 'Rejected') {
      return AppLocalizations.of(context)!.rejected;
    }

    if (widget.documentStatus == 'Accepted') {
      return AppLocalizations.of(context)!.accepted;
    }

    return AppLocalizations.of(context)!.notSubmitted;
  }

  Color _statusColor() {
    if (widget.documentStatus == 'Submitted') {
      return AppColors.secondary;
    }

    if (widget.documentStatus == 'Rejected') {
      return Colors.red;
    }

    if (widget.documentStatus == 'Accepted') {
      return Colors.green;
    }

    return Colors.grey;
  }

  IconData _statusIcon() {
    if (widget.documentStatus == 'Submitted') {
      return Icons.timelapse_rounded;
    }

    if (widget.documentStatus == 'Rejected') {
      return Icons.cancel_rounded;
    }

    if (widget.documentStatus == 'Accepted') {
      return Icons.check_circle_rounded;
    }

    return Icons.upload_file_rounded;
  }

  Widget _buildStatusCard() {
    final color = _statusColor();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(_statusIcon(), color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.status,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _localizedStatus(context),
                  style: TextStyle(
                    fontSize: 16,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.instructionsTitle,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...widget.instructions.map(
            (instruction) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: BulletWidget(details: instruction),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    if (hasSelectedDocument) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel(AppLocalizations.of(context)!.selectFile),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(
              File(pickedFile!.path!),
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: isLoading ? null : _removeSelectedFile,
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            icon: const Icon(Icons.close_rounded),
            label: Text(AppLocalizations.of(context)!.removeFile),
          ),
        ],
      );
    }

    if (!hasUploadedDocument) {
      return _buildEmptyPreview();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(widget.title),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(
            widget.documentUrl,
            width: double.infinity,
            height: 220,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;

              return Container(
                width: double.infinity,
                height: 220,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.lightLayer.withValues(alpha: 0.25),
                ),
                child: const CircularProgressIndicator.adaptive(),
              );
            },
            errorBuilder: (_, _, _) {
              return Container(
                width: double.infinity,
                height: 220,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.lightLayer.withValues(alpha: 0.2),
                ),
                child: Image.asset(
                  'assets/images/placeholder.jpeg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 220,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyPreview() {
    final isDark = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;

    return Container(
      width: double.infinity,
      height: 190,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.cloud_upload_outlined,
              size: 42,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.noFileSelected,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context)!.selectFile,
            style: TextStyle(
              color: Theme.of(
                context,
              ).textTheme.bodySmall?.color?.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildRejectionReason() {
    if (!isRejected || widget.rejectionReason.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.rejected,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.rejectionReason,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    late final String label;
    late final IconData icon;
    late final Color backgroundColor;

    if (!hasUploadedDocument && !hasSelectedDocument) {
      label = AppLocalizations.of(context)!.selectFile;
      icon = Icons.file_open_outlined;
      backgroundColor = AppColors.tertiary;
    } else if (!hasUploadedDocument && hasSelectedDocument) {
      label = AppLocalizations.of(context)!.uploadFile;
      icon = Icons.file_upload_outlined;
      backgroundColor = AppColors.primary;
    } else {
      label = AppLocalizations.of(context)!.deleteFile;
      icon = Icons.delete_outline_rounded;
      backgroundColor = Colors.red;
    }

    return TextButton(
      onPressed: isLoading ? null : _handlePrimaryAction,
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: backgroundColor.withValues(alpha: 0.45),
        disabledForegroundColor: Colors.white70,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 25),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    return StreamBuilder<TaskSnapshot>(
      stream: uploadTask?.snapshotEvents,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!;

        if (data.totalBytes <= 0) {
          return const SizedBox.shrink();
        }

        final progress = data.bytesTransferred / data.totalBytes;

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.uploadFile,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: AppColors.lightLayer,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBarWidget(title: widget.title),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        clipBehavior: Clip.hardEdge,
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom > 20
              ? MediaQuery.of(context).padding.bottom
              : 20,
        ),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInstructions(),

                const SizedBox(height: 18),

                _buildStatusCard(),

                const SizedBox(height: 18),

                _buildImagePreview(),

                const SizedBox(height: 14),

                _buildRejectionReason(),

                if (isRejected && widget.rejectionReason.isNotEmpty)
                  const SizedBox(height: 14),

                if (localError.isNotEmpty) ...[
                  ErrorMessageWidget(localErrorMessage: localError),
                  const SizedBox(height: 12),
                ],

                if (localSuccess.isNotEmpty) ...[
                  SuccessMessageWidget(successMessage: localSuccess),
                  const SizedBox(height: 12),
                ],

                if (isLoading) _buildProgress(),

                _buildActionButton(),

                const SizedBox(height: 20),

                Divider(thickness: 0.5, color: AppColors.border),

                const SizedBox(height: 18),

                Text(
                  AppLocalizations.of(context)!.yourStatusStaysPending,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),

                const SizedBox(height: 8),

                Text(
                  AppLocalizations.of(context)!.ifYouUpdateDocument,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
