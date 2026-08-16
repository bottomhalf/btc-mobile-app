import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:conference/config/app_config.dart';
import 'package:conference/pages/common/image_viewer/file_viewer.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class FileLoader extends StatefulWidget {
  final String? fileUrl;
  final String alternateImage;
  final int fileCategoryId;
  final String? thumbnailUrl;
  final BoxFit? fit;

  FileLoader.loadProfile({
    super.key,
    required this.fileUrl,
    this.fit = BoxFit.cover,
  })  : assert(true),
        fileCategoryId = 0,
        alternateImage = AppConfig.instance.getDefaultUserImage,
        thumbnailUrl = null;

  FileLoader.loadImage({
    super.key,
    required this.fileUrl,
  })  : assert(true),
        fileCategoryId = 0,
        alternateImage = AppConfig.instance.getDefaultUserImage,
        thumbnailUrl = null,
        fit = BoxFit.contain;

  FileLoader.loadVideo({
    super.key,
    required this.fileUrl,
    required this.thumbnailUrl,
  })  : assert(true),
        fileCategoryId = 1,
        alternateImage = AppConfig.instance.getDefaultUserImage,
        fit = BoxFit.contain;

  FileLoader.loadFile({
    super.key,
    required this.fileUrl,
    required this.fileCategoryId,
    required this.thumbnailUrl,
    this.fit = BoxFit.contain,
  })  : assert(true),
        alternateImage = AppConfig.instance.getDefaultUserImage;

  @override
  State<FileLoader> createState() => _FileLoaderState();
}

class _FileLoaderState extends State<FileLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween(begin: 0.5, end: 1.0).animate(_controller);
  }

  Widget getAnimatedBuilder() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Center(
            child: Container(
              width: double.infinity,
              height: 200,
              color: Colors.grey,
            ),
          ),
        );
      },
    );
  }

  Widget bindThumbnailImage(String url, String defaultImagePlaceholder) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: widget.fit ?? BoxFit.contain,
      width: double.infinity,
      placeholder: (context, url) => getAnimatedBuilder(),
      errorListener: (dynamic error) {
        debugPrint("Listener error ------------------------------: $error");
      },
      errorWidget: (context, url, error) => Image.asset(
        defaultImagePlaceholder,
      ),
    );
  }

  Widget bindCachedImage(String url, String defaultImagePlaceholder) {
    return CachedNetworkImage(
        imageUrl: url,
        fit: widget.fit ?? BoxFit.fitWidth,
        placeholder: (context, url) => getAnimatedBuilder(),
        errorListener: (dynamic error) {
          debugPrint("Listener error ------------------------------: $error");
        },
        errorWidget: (context, url, error) {
          return Image.asset(
            defaultImagePlaceholder,
          );
        });
  }

  Widget getCachedImageContainer(String? url, {bool isVideoThumbnail = false}) {
    if (url!.startsWith("/data/user")) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10), // Adjust corner radius
        child: Image.file(
          File(url),
          fit: BoxFit.cover,
        ),
      );
    } else {
      url = AppConfig.instance.getImage(url);
      if (url == null) {
        return Image.asset(
          AppConfig.instance.getDefaultUserImage,
        );
      }

      if (isVideoThumbnail) {
        return bindThumbnailImage(url, widget.alternateImage);
      } else {
        return bindCachedImage(url, widget.alternateImage);
      }
    }
  }

  Widget getVideoContainer(String? url) {
    return InkWell(
      onTap: () {
        Get.to(
          () => FileViewer.videoFile(
            url: AppConfig.instance.getImage(url!)!,
          ),
        );
      },
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: getCachedImageContainer(
              widget.thumbnailUrl,
              isVideoThumbnail: true,
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: 160,
            right: 160,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.black,
                size: 45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget bindImage() {
    if (widget.fileUrl == null || widget.fileUrl!.isEmpty) {
      return Image.asset(widget.alternateImage);
    }

    return getCachedImageContainer(widget.fileUrl);
  }

  Widget bindVideoWidget() {
    if (widget.fileUrl == null || widget.fileUrl!.isEmpty) {
      return Image.asset(widget.alternateImage);
    }

    return getVideoContainer(widget.fileUrl);
  }

  @override
  Widget build(BuildContext context) {
    return widget.fileCategoryId == 2 ? bindVideoWidget() : bindImage();
  }
}
