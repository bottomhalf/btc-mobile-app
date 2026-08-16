class FileDetail {
  int? fileDetailId;
  String? filePath;
  int? fileCategoryId;
  String? thumbnailFilePath;

  FileDetail({this.fileDetailId, this.filePath, this.fileCategoryId, this.thumbnailFilePath});

  static Map<String, dynamic> toJson(FileDetail fileDetail) {
    return {
      'fileDetailId': fileDetail.fileDetailId,
      'filePath': fileDetail.filePath,
      'fileCategoryId': fileDetail.fileCategoryId,
      'thumbnailFilePath': fileDetail.thumbnailFilePath,
    };
  }

  factory FileDetail.fromJson(dynamic file) {
    return FileDetail(
      fileDetailId: file["fileDetailId"],
      filePath: file["filePath"],
      fileCategoryId: file["fileCategoryId"] ?? file["fileCatagoryId"],
      thumbnailFilePath: file["thumbnailFilePath"],
    );
  }
  static List<FileDetail> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => FileDetail.fromJson(json)).toList();
  }
}
