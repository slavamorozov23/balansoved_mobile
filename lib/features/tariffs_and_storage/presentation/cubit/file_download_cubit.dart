import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_filex/open_filex.dart';
import '../../domain/entities/file_download_result_entity.dart';
import '../../domain/usecases/download_and_save_file_usecase.dart';
import 'file_download_state.dart';

class FileDownloadCubit extends Cubit<FileDownloadState> {
  final DownloadAndSaveFileUseCase _downloadAndSaveFileUseCase;

  FileDownloadCubit({
    required DownloadAndSaveFileUseCase downloadAndSaveFileUseCase,
  }) : _downloadAndSaveFileUseCase = downloadAndSaveFileUseCase,
       super(FileDownloadInitial());

  Future<FileDownloadResultEntity?> downloadFile({
    required String firmId,
    required String fileKey,
    required String fileName,
  }) async {
    emit(FileDownloadInProgress(fileKey: fileKey));

    final result = await _downloadAndSaveFileUseCase(
      firmId: firmId,
      fileKey: fileKey,
      fileName: fileName,
    );

    return result.fold((failure) {
      emit(FileDownloadFailure(fileKey: fileKey, message: failure.message));
      return null;
    }, (saved) async {
      emit(FileDownloadSuccess(fileKey: fileKey, result: saved));
      await _openFile(saved);
      return saved;
    });
  }

  Future<void> _openFile(FileDownloadResultEntity result) async {
    try {
      await OpenFilex.open(result.filePath);
    } catch (_) {}
  }
}
