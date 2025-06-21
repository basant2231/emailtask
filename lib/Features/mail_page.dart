import 'dart:async';

import 'package:emailtask/Features/controllers/mail_controllers.dart';
import 'package:emailtask/Features/widgets/attachments_section.dart';
import 'package:emailtask/Features/widgets/email_text_field.dart';
import 'package:emailtask/Features/widgets/send_button.dart';
import 'package:emailtask/core/app_text_styles.dart';
import 'package:emailtask/core/colors.dart';
import 'package:emailtask/core/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

import 'package:get/get.dart';

class MailPage extends StatelessWidget {
  MailPage({super.key});

  final MailController mailController = Get.put(MailController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Send Email to Clients",
          style: AppTextStyles.appBarTitle,
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
              key: mailController.formKey,
              child: Column(
                children: [
                  EmailTextField(
                    controller: mailController.recipientController,
                    label: "Recipient Email",
                    icon: Icons.email,
                    validator: (value) => Validators.validateEmail(value),
                  ),
                  const SizedBox(height: 16),
                  EmailTextField(
                    controller: mailController.subjectController,
                    label: "Subject",
                    icon: Icons.subject,
                    validator:
                        (value) =>
                            Validators.validateRequired(value, 'Subject'),
                  ),
                  const SizedBox(height: 16),
                  EmailTextField(
                    controller: mailController.contentController,
                    label: "Message Content",
                    maxLines: 5,
                    validator:
                        (value) => Validators.validateRequired(
                          value,
                          'Message content',
                        ),
                  ),
                  const SizedBox(height: 24),
                  AttachmentsSection(controller: mailController),
                  const SizedBox(height: 32),
                  SendButton(controller: mailController),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
