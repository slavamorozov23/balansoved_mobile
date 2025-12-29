class FileSavePermissionModel {
  final bool storageGranted;
  final bool galleryGranted;
  final bool requiresGallery;

  const FileSavePermissionModel({
    required this.storageGranted,
    required this.galleryGranted,
    required this.requiresGallery,
  });
}
