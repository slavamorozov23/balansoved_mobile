import 'dart:typed_data';
import '../models/file_save_permission_model.dart';
import '../models/file_save_result_model.dart';

abstract class IFileSaveLocalDataSource {
  Future<FileSavePermissionModel> requestPermissions({
    required String fileName,
  });

  Future<FileSaveResultModel> saveFile({
    required Uint8List bytes,
    required String fileName,
    required String? mimeType,
    required bool storageGranted,
    required bool galleryGranted,
  });
}
