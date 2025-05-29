import 'dart:io';
import 'package:excel/excel.dart' as excel;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service to handle Excel file operations
class ExcelService {
  /// Request storage permissions for file operations
  static Future<bool> requestStoragePermission(BuildContext context) async {
    if (!Platform.isAndroid) return true;

    // For Android 13 and above
    if (await Permission.mediaLibrary.isGranted) return true;

    // For Android 12 and below
    if (await Permission.storage.isGranted) return true;

    // Request permissions
    Map<Permission, PermissionStatus> statuses =
        await [Permission.storage, Permission.mediaLibrary].request();

    bool hasPermission =
        statuses[Permission.storage]?.isGranted == true ||
        statuses[Permission.mediaLibrary]?.isGranted == true;

    if (!hasPermission && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Storage permission is required to save Excel files'),
          backgroundColor: Colors.red,
        ),
      );
    }
    return hasPermission;
  }

  /// Get the file path for saving Excel file
  static Future<String?> getExcelFilePath(String fileName) async {
    try {
      if (Platform.isAndroid) {
        // Try to save to Downloads directory first
        final downloadsDir = Directory('/storage/emulated/0/Download');
        if (await downloadsDir.exists()) {
          return '${downloadsDir.path}/$fileName';
        }
        // Fallback to external storage directory
        final directory = await getExternalStorageDirectory();
        if (directory != null) {
          return '${directory.path}/$fileName';
        }
      } else {
        // For other platforms, use documents directory
        final directory = await getApplicationDocumentsDirectory();
        return '${directory.path}/$fileName';
      }
    } catch (e) {
      debugPrint('Error getting file path: $e');
    }
    return null;
  }

  /// Save Excel workbook to a file
  static Future<bool> saveExcelFile(
    excel.Excel workbook,
    String filePath,
  ) async {
    try {
      final file = File(filePath);
      final bytes = workbook.encode();
      if (bytes == null) {
        throw Exception('Failed to encode Excel file');
      }
      await file.writeAsBytes(bytes);
      return true;
    } catch (e) {
      debugPrint('Error saving Excel file: $e');
      return false;
    }
  }
}
