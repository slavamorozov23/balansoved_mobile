import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/download_file_usecase.dart';
import 'tariffs_and_storage_state.dart';

class TariffsAndStorageCubit extends Cubit<TariffsAndStorageState> {
  final DownloadFileUseCase _downloadFileUseCase;

  TariffsAndStorageCubit({
    required DownloadFileUseCase downloadFileUseCase,
  }) : _downloadFileUseCase = downloadFileUseCase,
       super(TariffsAndStorageInitial());

  Future<void> getDownloadUrl({
    required String firmId,
    required String fileKey,
  }) async {
    emit(FileDownloadInProgress(fileKey: fileKey));

    final result = await _downloadFileUseCase(
      firmId: firmId,
      fileKey: fileKey,
    );

    result.fold(
      (failure) => emit(
        TariffsAndStorageError(message: failure.message, fileKey: fileKey),
      ),
      (downloadEntity) => emit(
        FileDownloadUrlReady(
          downloadUrl: downloadEntity.downloadUrl,
          fileKey: downloadEntity.fileKey,
        ),
      ),
    );
  }

  void clearState() {
    emit(TariffsAndStorageInitial());
  }
}
