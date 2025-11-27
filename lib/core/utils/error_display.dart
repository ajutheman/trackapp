import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../model/network/result.dart';

/// Centralized error display utilities for consistent error messaging across the app

/// Show a standard error SnackBar
void showErrorSnackBar(BuildContext context, String message, {Duration? duration}) {
  if (!context.mounted) return;
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: duration ?? const Duration(seconds: 4),
      action: SnackBarAction(
        label: 'Dismiss',
        textColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ),
  );
}

/// Show a standard success SnackBar
void showSuccessSnackBar(BuildContext context, String message, {Duration? duration}) {
  if (!context.mounted) return;
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: duration ?? const Duration(seconds: 3),
    ),
  );
}

/// Show a standard info SnackBar
void showInfoSnackBar(BuildContext context, String message, {Duration? duration}) {
  if (!context.mounted) return;
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.secondary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: duration ?? const Duration(seconds: 3),
    ),
  );
}


/// Widget to display a single field error below an input field
class FieldErrorText extends StatelessWidget {
  final String? errorText;

  const FieldErrorText({super.key, this.errorText});

  @override
  Widget build(BuildContext context) {
    if (errorText == null || errorText!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline,
            size: 14,
            color: AppColors.error,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              errorText!,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.error,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper function to handle Result errors with proper display
void handleResultError(BuildContext context, Result result, {bool showDialog = false}) {
  if (!context.mounted) return;
  
  // Show error message as snackbar
  showErrorSnackBar(context, result.message ?? 'An error occurred');
}

