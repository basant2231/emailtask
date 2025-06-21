import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

import 'package:emailtask/core/snackbar_util.dart';

class MailController extends GetxController {
  final TextEditingController recipientController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final _attachments = <File>[].obs;
  final _attachmentNames = <String>[].obs;
  final _isSending = false.obs;
  final _isPickingAttachments = false.obs;

  List<File> get attachments => _attachments;
  List<String> get attachmentNames => _attachmentNames;
  bool get isSending => _isSending.value;
  bool get isPickingAttachments => _isPickingAttachments.value;

  final gmailSmtp = gmail(
    dotenv.env["GMAIL_MAIL"]!,
    dotenv.env["GMAIL_PASSWORD"]!,
  );

  Future<void> sendMail() async {
    if (_isSending.value) return;

    if (formKey.currentState?.validate() ?? false) {
      _isSending.value = true;

      final message = Message()
        ..from = Address(dotenv.env["GMAIL_MAIL"]!, 'Custom Support')
        ..recipients.add(recipientController.text)
        ..subject = subjectController.text
        ..text = contentController.text;

      for (int i = 0; i < _attachments.length; i++) {
       
          message.attachments.add(
            FileAttachment(_attachments[i])..fileName = _attachmentNames[i],
          );
        
      }

      try {
        final sendReport = await send(message, gmailSmtp).timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw TimeoutException('Email sending timed out'),
        );

        print('Message sent: $sendReport');
        SnackbarUtil.showSuccess(
          title: 'Success', 
          message: 'Email sent successfully!'
        );

        clearForm();
      } on TimeoutException catch (e) {
        SnackbarUtil.showError(
          title: 'Error',
          message: 'Failed to send email: ${e.message}'
        );
      } on MailerException catch (e) {
        SnackbarUtil.showError(
          title: 'Error',
          message: 'Failed to send email: ${e.message}'
        );
      } catch (e) {
        SnackbarUtil.showError(
          title: 'Error',
          message: 'An error occurred: ${e.toString()}'
        );
      } finally {
        _isSending.value = false;
      }
    }
  }

  Future<void> pickAttachments() async {
    if (_isPickingAttachments.value) return;

    _isPickingAttachments.value = true;

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null && result.files.isNotEmpty) {
        for (var file in result.files) {
          if (file.path != null) {
            _attachments.add(File(file.path!));
            _attachmentNames.add(file.name);
          }
        }
      }
    } catch (e) {
      SnackbarUtil.showError(
        title: 'Error',
        message: 'Error picking files: ${e.toString()}'
      );
    } finally {
      _isPickingAttachments.value = false;
    }
  }

  void removeAttachment(int index) {
    _attachments.removeAt(index);
    _attachmentNames.removeAt(index);
  }

  void clearAllAttachments() {
    _attachments.clear();
    _attachmentNames.clear();
  }

  void clearForm() {
    recipientController.clear();
    subjectController.clear();
    contentController.clear();
    clearAllAttachments();
  }

  @override
  void onClose() {
    recipientController.dispose();
    subjectController.dispose();
    contentController.dispose();
    super.onClose();
  }
}