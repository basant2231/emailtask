import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:mailer/smtp_server/hotmail.dart';
import 'package:mailer/smtp_server/yandex.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

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
  bool _isPickingAttachments = false; // New state for attachment loading

  // SMTP server for gmail
  final gmailSmtp = gmail(
    dotenv.env["GMAIL_MAIL"]!,
    dotenv.env["GMAIL_PASSWORD"]!,
  );

  Future<void> sendMailFromGmail(String sender, String sub, String text) async {
    if (_isSending) return;
    
    setState(() {
      _isSending = true;
    });

    final message = Message()
      ..from = Address(dotenv.env["GMAIL_MAIL"]!, 'Custom Support')
      ..recipients.add(sender)
      ..subject = sub
      ..text = text;

    // Add all attachments
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
        const SnackBar(content: Text('Email sent successfully!')),
      );
    } on TimeoutException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send email: ${e.message}')),
      );
    } on MailerException catch (e) {
      print('Mailer error: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send email: ${e.message}')),
      );
    } catch (e) {
      print('Unexpected error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Future<void> _pickAttachments() async {
    if (_isPickingAttachments) return;
    
    setState(() {
      _isPickingAttachments = true;
    });

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
      print('Error picking files: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking files: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPickingAttachments = false;
        });
      }
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
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                // Recipient Field
                TextFormField(
                  controller: _recipientController,
                  decoration: InputDecoration(
                    labelText: "Recipient Email",
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  validator: (value) => value!.isEmpty ? "Required field" : null,
                ),
                const SizedBox(height: 16),

                // Subject Field
                TextFormField(
                  controller: _subjectController,
                  decoration: InputDecoration(
                    labelText: "Subject",
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  validator: (value) => value!.isEmpty ? "Required field" : null,
                ),
                const SizedBox(height: 16),

                // Content Field
                TextFormField(
                  controller: _contentController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: "Message Content",
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  validator: (value) => value!.isEmpty ? "Required field" : null,
                ),
                const SizedBox(height: 20),

                // Attachments Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isPickingAttachments ? null : _pickAttachments,
                          icon: _isPickingAttachments
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(Icons.attach_file),
                          label: Text(_isPickingAttachments ? "Loading..." : "Add Attachments"),
                        ),
                        if (_attachments.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: _isPickingAttachments ? null : _clearAllAttachments,
                            child: Text("Clear All"),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_attachments.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: _attachmentNames.asMap().entries.map(
                            (entry) => ListTile(
                              leading: Icon(Icons.insert_drive_file),
                              title: Text(
                                entry.value,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.close),
                                onPressed: _isPickingAttachments ? null : () => _removeAttachment(entry.key),
                              ),
                              contentPadding: EdgeInsets.zero,
                              minLeadingWidth: 24,
                            ),
                          ).toList(),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // Send Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSending || _isPickingAttachments
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
                    child: _isSending
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text("Send Email"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}