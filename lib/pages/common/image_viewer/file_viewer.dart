import 'dart:io';
import 'dart:typed_data';

import 'package:conference/models/file_detail.dart';
import 'package:conference/pages/common/image_viewer/file_viewer_controller.dart';
import 'package:conference/pages/common/image_viewer/widget/file_loader.dart';
import 'package:conference/pages/common/image_viewer/widget/videos/video_viewer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FileViewer extends StatefulWidget {
  final List<FileDetail>? fileDetail;
  final String? url;
  final File? file;
  final FileAccessType fileAccessType;
  final bool isFileUploading;
  final Uint8List? fileBytes;
  final bool isPlayVideo;

  const FileViewer.server({
    super.key,
    required this.fileDetail,
  })  : assert(true),
        file = null,
        isPlayVideo = false,
        fileAccessType = FileAccessType.serverFiles,
        isFileUploading = false,
        fileBytes = null,
        url = null;

  const FileViewer.videoFile({
    super.key,
    required this.url,
  })  : assert(true),
        isPlayVideo = false,
        fileDetail = null,
        fileBytes = null,
        fileAccessType = FileAccessType.uploadVideo,
        isFileUploading = true,
        file = null;


  FileViewer.fromUrl({
    super.key,
    required this.url,
  })  : assert(true),
        isPlayVideo = false,
        file = null,
        fileAccessType = FileAccessType.fromUrl,
        isFileUploading = false,
        fileBytes = null,
        fileDetail = [
          FileDetail(
              thumbnailFilePath: null,
              fileDetailId: 0,
              fileCategoryId: 0,
              filePath: url)
        ];

  @override
  State<FileViewer> createState() => _FileViewerState();
}

class _FileViewerState extends State<FileViewer> {
  final pageController = PageController();
  final uploadController = Get.put(FileViewerController());

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    Get.delete<FileViewerController>();
  }

  Widget loadFromFileDetail() {
    return Expanded(
      child: PageView.builder(
        controller: pageController,
        itemCount: widget.fileDetail!.length,
        onPageChanged: (index) {
          debugPrint("Current page index: $index");
        },
        itemBuilder: (context, index) {
          return InteractiveViewer(
            panEnabled: true,
            minScale: 1.0,
            maxScale: 4.0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                FileLoader.loadImage(
                  fileUrl: widget.fileDetail![index].filePath,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget loadFromUrl() {
    return InteractiveViewer(
      panEnabled: true,
      minScale: 1.0,
      maxScale: 4.0,
      child: FileLoader.loadImage(
        fileUrl: widget.url,
      ),
    );
  }

  Widget loadFromFile({required File? file, required Uint8List? fileBytes}) {
    if (file != null) {
      return InteractiveViewer(
        panEnabled: true,
        minScale: 1.0,
        maxScale: 4.0,
        child: Image.file(file, fit: BoxFit.cover),
      );
    } else if (fileBytes != null) {
      return InteractiveViewer(
        panEnabled: true,
        minScale: 1.0,
        maxScale: 4.0,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: MemoryImage(fileBytes),
              // Use the generated thumbnail
              fit: BoxFit
                  .contain, // Adjust the image to cover the entire container
            ),
          ),
        ),
      );
    } else {
      return Text("Invalid image. No content found.");
    }
  }

  Widget fileSelectionWidget() {
    switch (widget.fileAccessType) {
      case FileAccessType.serverFiles:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            loadFromFileDetail(),
          ],
        );
      case FileAccessType.uploadFile:
        return loadFromFile(
          file: widget.file,
          fileBytes: widget.fileBytes,
        );
      case FileAccessType.uploadVideo:
        return VideoViewer(
          videoFilePath: widget.url!,
          isPlayVideo: widget.isPlayVideo,
        );
      case FileAccessType.fromUrl:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            loadFromUrl(),
          ],
        );
      default:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Image not found"),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          if (widget.isFileUploading)
            Icon(
              Icons.upload,
              color: Colors.white,
            ),
        ],
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white), // Custom icon
          onPressed: () {
            Navigator.pop(context); // Go back
          },
        ),
        title: const Text(
          "Image viewer",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: InkWell(
        onTap: uploadController.toggleShowCaptionFlag,
        child: fileSelectionWidget(),
      ),
    );
  }
}

enum FileAccessType { fromUrl, fromFile, uploadVideo, uploadFile, serverFiles }
