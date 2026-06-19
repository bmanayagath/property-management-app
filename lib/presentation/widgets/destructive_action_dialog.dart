import 'package:flutter/material.dart';

Future<bool> showDestructiveActionDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
}) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFF04438),
              ),
              child: Text(confirmLabel),
            ),
          ],
        ),
      ) ??
      false;
}

const deleteVillaConfirmationMessage =
    'This will remove the villa and related rooms from active view. Existing income, expenses, media, and reports may be affected.\n\nAre you sure you want to continue?';

const disableUserConfirmationMessage =
    'This user will no longer be able to login or access this organization.\n\nAre you sure you want to continue?';
