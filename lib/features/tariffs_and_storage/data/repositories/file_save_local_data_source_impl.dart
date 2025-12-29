import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:balansoved_mobile/core/error/exception.dart';
import '../data_source/file_save_local_data_source.dart';
import '../models/file_save_permission_model.dart';
import '../models/file_save_result_model.dart';

class FileSaveLocalDataSourceImpl implements IFileSaveLocalDataSource {
  @override
  Future<FileSavePermissionModel> requestPermissions({
    required String fileName,
  }) async {
    var storageGranted = true;
    var galleryGranted = true;
    final requiresGallery = _isImageFile(fileName, null);

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final sdkInt = _androidSdkInt();
      final needsLegacyStorage = sdkInt == null || sdkInt <= 32;
      if (needsLegacyStorage) {
        final storageStatus = await Permission.storage.request();
        storageGranted = storageStatus.isGranted;
      }
      if (requiresGallery) {
        if (sdkInt != null && sdkInt >= 33) {
          final photosStatus = await Permission.photos.request();
          galleryGranted =
              photosStatus.isGranted || photosStatus.isLimited;
        } else {
          galleryGranted = storageGranted;
        }
      }
    }

    return FileSavePermissionModel(
      storageGranted: storageGranted,
      galleryGranted: galleryGranted,
      requiresGallery: requiresGallery,
    );
  }

  @override
  Future<FileSaveResultModel> saveFile({
    required Uint8List bytes,
    required String fileName,
    required String? mimeType,
    required bool storageGranted,
    required bool galleryGranted,
  }) async {
    final normalizedName = _normalizeFileName(fileName, bytes, mimeType);
    final resolvedMime =
        mimeType ?? lookupMimeType(normalizedName, headerBytes: bytes);
    final isImage = _isImageFile(normalizedName, resolvedMime);

    if (isImage) {
      if (!galleryGranted &&
          !kIsWeb &&
          defaultTargetPlatform == TargetPlatform.android) {
        throw const CacheException(
          message: 'Нужно разрешение на доступ к галерее',
        );
      }
      final tempPath = await _writeTempFile(bytes, normalizedName);
      final saved = await _saveImageToGallery(
        tempPath,
        _stripExtension(normalizedName),
      );
      if (!saved) {
        throw const CacheException(message: 'Не удалось сохранить в галерею');
      }
      return FileSaveResultModel(
        fileName: normalizedName,
        filePath: tempPath,
        savedToGallery: true,
      );
    }

    final docPath = await _saveDocumentToDocuments(
      bytes,
      normalizedName,
      preferExternal: storageGranted,
    );
    return FileSaveResultModel(
      fileName: normalizedName,
      filePath: docPath,
      savedToGallery: false,
    );
  }

  bool _isImageFile(String fileName, String? mimeType) {
    if (mimeType != null && mimeType.startsWith('image/')) return true;
    final lower = fileName.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.bmp') ||
        lower.endsWith('.heic');
  }

  String _normalizeFileName(
    String fileName,
    Uint8List bytes,
    String? mimeType,
  ) {
    final sanitized = _sanitizeFileName(fileName);
    final hasExt = RegExp(r'\.[a-zA-Z0-9]{1,6}$').hasMatch(sanitized);
    if (hasExt) return sanitized;
    final resolvedMime =
        mimeType ?? lookupMimeType(sanitized, headerBytes: bytes);
    if (resolvedMime == null) return sanitized;
    final ext = extensionFromMime(resolvedMime);
    if (ext == null || ext.isEmpty) return sanitized;
    return '$sanitized.$ext';
  }

  String _sanitizeFileName(String fileName) {
    final trimmed = fileName.split('?').first.split('#').first.trim();
    final cleaned =
        trimmed.replaceAll(RegExp(r'[<>:"/\\|?*\u0000-\u001F]'), '_');
    return cleaned.isEmpty ? 'Файл' : cleaned;
  }

  String _stripExtension(String fileName) {
    final index = fileName.lastIndexOf('.');
    if (index <= 0) return fileName;
    return fileName.substring(0, index);
  }

  Future<String> _writeTempFile(Uint8List bytes, String fileName) async {
    final tempDir = await getTemporaryDirectory();
    final path = '${tempDir.path}${Platform.pathSeparator}$fileName';
    final file = File(path);
    await file.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<bool> _saveImageToGallery(String tempPath, String name) async {
    final result = await ImageGallerySaverPlus.saveFile(
      tempPath,
      name: name,
    );
    if (result is Map) {
      final success = result['isSuccess'] ?? result['success'];
      if (success is bool) return success;
      if (success is int) return success == 1;
    }
    return result == true;
  }

  Future<String> _saveDocumentToDocuments(
    Uint8List bytes,
    String fileName, {
    required bool preferExternal,
  }) async {
    Directory dir;
    if (Platform.isAndroid && preferExternal) {
      final dirs = await getExternalStorageDirectories(
        type: StorageDirectory.documents,
      );
      dir = (dirs != null && dirs.isNotEmpty)
          ? dirs.first
          : await getApplicationDocumentsDirectory();
    } else {
      dir = await getApplicationDocumentsDirectory();
    }
    await dir.create(recursive: true);
    final path = '${dir.path}${Platform.pathSeparator}$fileName';
    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  int? _androidSdkInt() {
    if (!Platform.isAndroid) return null;
    final match =
        RegExp(r'SDK\\s+(\\d+)').firstMatch(Platform.operatingSystemVersion);
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }
}
