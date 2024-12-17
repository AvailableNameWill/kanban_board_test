import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kanban_board_test/utils/font_sizes.dart';

DateTime toDate({required String dateTime}) {
  final utcDateTime = DateTime.parse(dateTime);
  return utcDateTime.toLocal();
}

String formatDate({
  required String dateTime,
  format = "dd MMM, yyyy"
}) {
  final localDateTime = toDate(dateTime: dateTime);
  return DateFormat(format).format(localDateTime);
}

SnackBar getSnackBar(String message, Color backgroundColor) {
  SnackBar snackBar = SnackBar(
    content: Text(message,
        style: const TextStyle(fontSize: textMedium)),
    backgroundColor: backgroundColor,
    dismissDirection: DismissDirection.up,
    behavior: SnackBarBehavior.floating,
  );
  return snackBar;
}

bool isValidEmail(String email){
  String emailPattern = r'^[a-zA-Z0-9.a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+$';
  RegExp regex = RegExp(emailPattern);
  return regex.hasMatch(email);
}