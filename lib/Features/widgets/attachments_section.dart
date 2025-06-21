import 'package:emailtask/Features/controllers/mail_controllers.dart';
import 'package:emailtask/core/app_text_styles.dart';
import 'package:emailtask/core/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AttachmentsSection extends StatelessWidget {
  final MailController controller;

  const AttachmentsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          controller.isPickingAttachments
                              ? null
                              : controller.pickAttachments,
                      icon:
                          controller.isPickingAttachments
                              ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : Icon(Icons.attach_file, color: Colors.white),
                      label: Text(
                        controller.isPickingAttachments
                            ? "Loading Attachments..."
                            : "Add Attachments",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.sendButton,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  if (controller.attachments.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed:
                          controller.isPickingAttachments
                              ? null
                              : controller.clearAllAttachments,
                      child: Text(
                        "Clear All",
                        style: TextStyle(color: AppColors.sendButton),
                      ),
                    ),
                  ],
                ],
              ),
              if (controller.attachments.isNotEmpty) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: List.generate(controller.attachments.length, (
                    index,
                  ) {
                    final attachmentName = controller.attachmentNames[index];
                    final bool isDisabled = controller.isPickingAttachments;

                    return InputChip(
                      label: Text(attachmentName),
                      avatar: const Icon(Icons.attach_file, size: 20),
                      onDeleted: () => controller.removeAttachment(index),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      isEnabled: !isDisabled,
                    );
                  }),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
