import 'package:emailtask/Features/mail/controllers/mail_controller.dart';
import 'package:emailtask/core/app_text_styles.dart';
import 'package:emailtask/core/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class SendButton extends StatelessWidget {
  final MailController controller;

  const SendButton({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed:
            controller.isSending || controller.isPickingAttachments
                ? null
                : controller.sendMail,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sendButton,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Obx(
          () =>
              controller.isSending
                  ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppColors.buttonText,
                    ),
                  )
                  : Text("Send Email", style: AppTextStyles.sendButtonText),
        ),
      ),
    );
  }
}
