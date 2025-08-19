import 'package:flutter/material.dart';


void showSnackBar(BuildContext context, String message) {
  final snackBar = SnackBar(content: Text(message), behavior: SnackBarBehavior.floating, backgroundColor: Colors.black87, duration: Duration(seconds: 3));

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

// void showErrorDialog(BuildContext context, String message, {String? title}) {
//   showDialog(
//     context: context,
//     barrierDismissible: true,
//     builder: (BuildContext context) {
//       return ErrorDialogWidget(message: message, title: title);
//     },
//   );
// }
