import 'dart:typed_data';

class FileDownloadDataModel {
  final Uint8List bytes;
  final String? mimeType;

  const FileDownloadDataModel({required this.bytes, this.mimeType});
}
