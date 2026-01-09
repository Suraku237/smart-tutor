import 'dart:io';
import 'package:flutter/material.dart';

class DeleteService {
  /// Deletes a PDF file from the device storage
  static Future<bool> deletePDF(String filePath) async {
    try {
      final file = File(filePath);
      
      if (await file.exists()) {
        await file.delete();
        debugPrint("File deleted successfully: $filePath");
        return true;
      } else {
        debugPrint("File does not exist: $filePath");
        return false;
      }
    } catch (e) {
      debugPrint("Error deleting file: $e");
      return false;
    }
  }

  /// Shows a confirmation dialog before deleting
  static Future<void> showDeleteDialog({
    required BuildContext context,
    required String fileName,
    required VoidCallback onConfirm,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete PDF"),
        content: Text("Are you sure you want to delete '$fileName'? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}