import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> showCustomAlertDialog(
    BuildContext context, {
      required Widget text,
      required String message,
      required VoidCallback onConfirm,
      VoidCallback? onCancel,
    }) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.add_alert),
            const SizedBox(width: 8),
            text
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              onConfirm();
            },
            child: const Text(
              'Yes',
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
          TextButton(
            onPressed: () {
              if (onCancel != null) {
                onCancel();
              }
              Get.back(); // Close the dialog
            },
            child: const Text(
              'No',
              style: TextStyle(color: Colors.green, fontSize: 16),
            ),
          ),
        ],
      );
    },
  );
}