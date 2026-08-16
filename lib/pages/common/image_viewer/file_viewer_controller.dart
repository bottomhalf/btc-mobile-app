import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class FileViewerController extends GetxController {
  var showCaption = true.obs;
  var isUploading = false.obs;
  final captionController = TextEditingController();

  void toggleShowCaptionFlag() {
    showCaption.value = !showCaption.value;
  }

  void setCaptionFlag({ required bool flag }) {
    showCaption.value = flag;
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    debugPrint("UploadFile for image viewer initialized");
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    debugPrint("UploadFile for image viewer closed");
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    debugPrint("UploadFile for image viewer disposed");
  }
}
