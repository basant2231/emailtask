import 'dart:async';

import 'package:emailtask/core/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:mailer/smtp_server/hotmail.dart';
import 'package:mailer/smtp_server/yandex.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:file_picker/file_picker.dart';

class MailPage extends StatefulWidget {
  const MailPage({super.key});

  @override
  State<MailPage> createState() => _MailPageState();
}

class _MailPageState extends State<MailPage> {
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  List<File> _attachments = [];
  List<String> _attachmentNames = [];
  bool _isSending = false;
  bool _isPickingAttachments = false;

  final gmailSmtp = gmail(
    dotenv.env["GMAIL_MAIL"]!,
    dotenv.env["GMAIL_PASSWORD"]!,
  );

  Future<void> sendMailFromGmail(String sender, String sub, String text) async {
    if (_isSending) return;

    setState(() => _isSending = true);

    final message =
        Message()
          ..from = Address(dotenv.env["GMAIL_MAIL"]!, 'Custom Support')
          ..recipients.add(sender)
          ..subject = sub
          ..text = text;

    for (int i = 0; i < _attachments.length; i++) {
      try {
        message.attachments.add(
          FileAttachment(_attachments[i])..fileName = _attachmentNames[i],
        );
      } catch (e) {
        print('Error attaching file ${_attachmentNames[i]}: $e');
      }
    }

    try {
      final sendReport = await send(message, gmailSmtp).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Email sending timed out'),
      );

      print('Message sent: $sendReport');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email sent successfully!'),
          backgroundColor: AppColors.successSnackbar,
        ),
      );

      if (mounted) {
        setState(() {
          _recipientController.clear();
          _subjectController.clear();
          _contentController.clear();
          _attachments.clear();
          _attachmentNames.clear();
        });
      }
    } on TimeoutException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send email: ${e.message}'),
          backgroundColor: AppColors.errorSnackbar,
        ),
      );
    } on MailerException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send email: ${e.message}'),
          backgroundColor: AppColors.errorSnackbar,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: ${e.toString()}'),
          backgroundColor: AppColors.errorSnackbar,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _pickAttachments() async {
    if (_isPickingAttachments) return;

    setState(() => _isPickingAttachments = true);

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          for (var file in result.files) {
            if (file.path != null) {
              _attachments.add(File(file.path!));
              _attachmentNames.add(file.name);
            }
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking files: ${e.toString()}'),
          backgroundColor: AppColors.errorSnackbar,
        ),
      );
    } finally {
      if (mounted) setState(() => _isPickingAttachments = false);
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
      _attachmentNames.removeAt(index);
    });
  }

  void _clearAllAttachments() {
    setState(() {
      _attachments.clear();
      _attachmentNames.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Send Email to Clients",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.appBarText,
          ),
        ),
        backgroundColor: AppColors.appBarBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.appBarText),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.backgroundTop, AppColors.backgroundBottom],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  _buildTextFieldCard(
                    controller: _recipientController,
                    label: "Recipient Email",
                    icon: Icons.email,
                    validator:
                        (value) => value!.isEmpty ? "Required field" : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextFieldCard(
                    controller: _subjectController,
                    label: "Subject",
                    icon: Icons.subject,
                    validator:
                        (value) => value!.isEmpty ? "Required field" : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextFieldCard(
                    controller: _contentController,
                    label: "Message Content",
                    maxLines: 5,
                    validator:
                        (value) => value!.isEmpty ? "Required field" : null,
                  ),
                  const SizedBox(height: 24),
                  _buildAttachmentsSection(),
                  const SizedBox(height: 32),
                  _buildSendButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldCard({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Card(
      elevation: 2,
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: AppColors.fieldLabel),
            border: InputBorder.none,
            prefixIcon:
                icon != null ? Icon(icon, color: AppColors.fieldIcon) : null,
            alignLabelWithHint: maxLines > 1,
          ),
          validator: validator,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildAttachmentsSection() {
    return Card(
      elevation: 2,
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isPickingAttachments ? null : _pickAttachments,
                    icon:
                        _isPickingAttachments
                            ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.buttonText,
                              ),
                            )
                            : Icon(
                              Icons.attach_file,
                              color: AppColors.buttonText,
                            ),
                    label: Text(
                      _isPickingAttachments
                          ? "Loading Attachments..."
                          : "Add Attachments",
                      style: const TextStyle(color: AppColors.buttonText),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryButton,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                if (_attachments.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed:
                        _isPickingAttachments ? null : _clearAllAttachments,
                    child: Text(
                      "Clear All",
                      style: TextStyle(
                        color: AppColors.clearButton,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (_attachments.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.attachmentBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children:
                      _attachmentNames
                          .asMap()
                          .entries
                          .map(
                            (entry) => ListTile(
                              leading: const Icon(
                                Icons.insert_drive_file,
                                color: AppColors.attachmentIcon,
                              ),
                              title: Text(
                                entry.value,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: AppColors.removeIcon,
                                ),
                                onPressed:
                                    _isPickingAttachments
                                        ? null
                                        : () => _removeAttachment(entry.key),
                              ),
                              contentPadding: EdgeInsets.zero,
                              minLeadingWidth: 24,
                            ),
                          )
                          .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed:
            _isSending || _isPickingAttachments
                ? null
                : () {
                  if (formKey.currentState!.validate()) {
                    sendMailFromGmail(
                      _recipientController.text,
                      _subjectController.text,
                      _contentController.text,
                    );
                  }
                },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sendButton,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child:
            _isSending
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.buttonText,
                  ),
                )
                : const Text(
                  "Send Email",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.buttonText,
                  ),
                ),
      ),
    );
  }
}
