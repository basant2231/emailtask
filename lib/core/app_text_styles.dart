import 'package:emailtask/core/colors.dart';
import 'package:flutter/material.dart';

class AppTextStyles {
  static const TextStyle appBarTitle = TextStyle(
    fontWeight: FontWeight.w600,
    color: AppColors.appBarText,
  );

  static const TextStyle fieldLabel = TextStyle(
    color: AppColors.fieldLabel,
  );

  static const TextStyle buttonText = TextStyle(
    color: AppColors.buttonText,
  );

  static const TextStyle sendButtonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.buttonText,
  );

  static const TextStyle clearButtonText = TextStyle(
    color: AppColors.clearButton,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle attachmentText = TextStyle(
    fontSize: 14,
  );
}