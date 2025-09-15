import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:kipgo/l10n/app_localizations.dart';
import 'package:kipgo/screens/widgets/app_bar_widget.dart';
import 'package:kipgo/screens/widgets/error_message.dart';
import 'package:kipgo/screens/widgets/input_decorator.dart';
import 'package:kipgo/screens/widgets/success_message_widget.dart';
import 'package:kipgo/utils/colors.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final contactUsKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  bool _isSending = false;
  String errorMessage = '';
  String successMessage = '';
  int minWords = 3;

  String? _validateWordCount(String? text) {
    if (text == null || text.isEmpty) {
      return AppLocalizations.of(context)!.pleaseEnterMessage;
    }

    List<String> words = text.trim().split(RegExp(r'\s+'));

    if (words.length < minWords) {
      return AppLocalizations.of(context)!.messageCannotBeLessThan;
    }

    return null; // Validation passed
  }

  Future<void> sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _isSending = true;
      errorMessage = '';
      successMessage = '';
    });

    final profile = Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).profile!;

    try {
      await FirebaseFirestore.instance.collection('supportMessages').add({
        'userId': profile.id,
        'email': profile.email,
        'message': _controller.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending', // can be updated later by admin
      });

      _controller.clear();
      setState(() {
        successMessage = AppLocalizations.of(context)!.messageSent;
      });
    } catch (e) {
      setState(() {
        errorMessage = AppLocalizations.of(context)!.messageFailed;
      });
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        appBar: AppBarWidget(
          title: AppLocalizations.of(context)!.contactUs.toUpperCase(),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: contactUsKey,
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.sendUsAMessage,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _controller,
                  maxLines: 5,
                  decoration: inputDecoration(context: context).copyWith(
                    hint: Text(AppLocalizations.of(context)!.typeYourMessage),
                    label: Text(AppLocalizations.of(context)!.message),
                  ),
                  validator: _validateWordCount,
                ),
                const SizedBox(height: 15),
                if (errorMessage != '') ...[
                  ErrorMessageWidget(localErrorMessage: errorMessage),
                  const SizedBox(height: 15),
                ],
                if (successMessage != '') ...[
                  SuccessMessageWidget(successMessage: successMessage),
                  const SizedBox(height: 15),
                ],
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primary.withValues(
                      alpha: 0.5,
                    ),
                    disabledForegroundColor: Colors.white54,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isSending
                      ? null
                      : () {
                          if (contactUsKey.currentState!.validate()) {
                            contactUsKey.currentState!
                                .save(); // ensures phone is saved
                            sendMessage();
                          }
                        },
                  child: _isSending
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(AppLocalizations.of(context)!.send),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
