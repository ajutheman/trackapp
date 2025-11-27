import 'package:flutter/material.dart';
import 'error_display.dart';

/// Legacy function - redirects to new error display utility
/// @deprecated Use showErrorSnackBar, showSuccessSnackBar, or showInfoSnackBar instead
void showSnackBar(BuildContext context, String message, {bool isError = false, bool isSuccess = false}) {
  if (isSuccess) {
    showSuccessSnackBar(context, message);
  } else if (isError) {
    showErrorSnackBar(context, message);
  } else {
    showInfoSnackBar(context, message);
  }
}
