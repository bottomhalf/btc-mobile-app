import 'dart:io';

import 'package:conference/pages/common/image_viewer/file_viewer_controller.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class VideoViewer extends StatefulWidget {
  final String videoFilePath;
  final bool isPlayVideo;

  const VideoViewer({
    super.key,
    required this.videoFilePath,
    required this.isPlayVideo,
  });

  @override
  State<VideoViewer> createState() => _VideoViewerState();
}

class _VideoViewerState extends State<VideoViewer> {
  // late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  final controller = Get.find<FileViewerController>();

  bool isPlaying = false;
  bool isUploading = false;
  final Duration _videoPosition = Duration.zero;
  late FlickManager _flickManager;

  @override
  void initState() {
    super.initState();

    // if (widget.videoFilePath.contains("http")) {
    //   _controller = VideoPlayerController.networkUrl(
    //     Uri.parse(
    //       widget.videoFilePath,
    //     ),
    //   );
    // } else {
    //   _controller = VideoPlayerController.file(File(widget.videoFilePath));
    // }
    //
    // _initializeVideoPlayerFuture = _controller.initialize();
    // _controller.addListener(_videoListener);



    _flickManager = FlickManager(
      videoPlayerController: widget.videoFilePath.contains("http")
          ? VideoPlayerController.networkUrl(Uri.parse(widget.videoFilePath))
          : VideoPlayerController.file(File(widget.videoFilePath)),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _flickManager.flickVideoManager!.videoPlayerController?.initialize().then((_) {
        setState(() {});  // Ensure the UI updates only after initialization
      }).catchError((e) {
        debugPrint("Error initializing video: $e");
      });
      // _startVideo();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _flickManager.dispose();
    super.dispose();
  }

  // void _startVideo() {
  //   _controller.setLooping(false);
  //   _controller.play();
  //
  //   setState(() {
  //     isPlaying = true;
  //   });
  // }
  //
  // void _videoListener() {
  //   debugPrint("Position: ${_controller.value.position}" ?? "0");
  //   setState(() {
  //     _videoPosition = _controller.value.position;
  //   });
  //
  //   // Check if the video has completed
  //   if (_controller.value.position >= _controller.value.duration) {
  //     _onVideoCompleted();
  //   }
  // }

  // Callback for when the video completes
  void _onVideoCompleted() {
    debugPrint("Video has completed playing.");

    setState(() {
      isPlaying = false;
    });
  }

  String convertIntoTwoDigitDecimal(String minutes, String seconds) {
    if (minutes.length == 1) {
      minutes = "0$minutes";
    }

    if (seconds.length == 1) {
      minutes += ":0$seconds";
    }

    return minutes;
  }

  Widget videoProgressBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Opacity(
        opacity: .8,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 20,
          ),
          decoration: BoxDecoration(
            color: Colors.black,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // videoProgressControllerWidget(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget videoProgressControllerWidget() {
  //   return Padding(
  //     padding: const EdgeInsets.all(8.0),
  //     child: Column(
  //       children: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             IconButton(
  //               onPressed: () {
  //                 setState(() {
  //                   if (_controller.value.isPlaying) {
  //                     _controller.pause();
  //                   } else {
  //                     _controller.play();
  //                     Future.delayed(Duration(seconds: 1), () {
  //                       controller.toggleShowCaptionFlag();
  //                     });
  //                   }
  //                 });
  //               },
  //               icon: Icon(
  //                 _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
  //                 color: Colors.white,
  //               ),
  //             ),
  //             // const Icon(
  //             //   Icons.volume_off,
  //             // ),
  //             Padding(
  //               padding: const EdgeInsets.only(
  //                 right: 10,
  //               ),
  //               child: Text(
  //                 convertIntoTwoDigitDecimal("${_videoPosition.inMinutes}",
  //                     "${_videoPosition.inSeconds}"),
  //                 style: const TextStyle(
  //                   fontSize: 16,
  //                   color: Colors.white,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //         VideoProgressIndicator(
  //           _controller,
  //           allowScrubbing: true,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget videoWidget() {
  //   return FutureBuilder(
  //     future: _initializeVideoPlayerFuture,
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return const Center(
  //           child: CircularProgressIndicator(),
  //         );
  //       } else if (snapshot.hasError) {
  //         return const Center(
  //           child: Text('Error loading video'),
  //         );
  //       } else {
  //         return FittedBox(
  //           fit: BoxFit.contain,
  //           child: SizedBox(
  //             width: _controller.value.size.width,
  //             height: _controller.value.size.height,
  //             child: AspectRatio(
  //               aspectRatio: _controller.value.aspectRatio,
  //               child: VideoPlayer(_controller),
  //             ),
  //           ),
  //         );
  //       }
  //     },
  //   );
  // }

  Widget playWithFlickPlayer() {
    return FlickVideoPlayer(flickManager: _flickManager);
  }

  @override
  Widget build(BuildContext context) {
    return playWithFlickPlayer();
    // return Stack(
    //   fit: StackFit.expand,
    //   children: [
    //     Center(
    //       child: videoWidget(),
    //     ),
    //     Obx(
    //       () => Visibility(
    //         visible: controller.showCaption.value,
    //         child: widget.isPlayVideo ? videoProgressBar() : videoCaption(),
    //       ),
    //     ),
    //   ],
    // );
  }
}
