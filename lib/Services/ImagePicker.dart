import 'dart:io';
import 'package:get/get_rx/get_rx.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker imagePicker = ImagePicker();
  var imageFile = Rx<File?>(null);

  Future<File?> pickImages(bool fromCamera) async {
    final XFile? pickedImage = await imagePicker.pickImage(source: fromCamera ? ImageSource.camera : ImageSource.gallery);
    if (pickedImage != null) {
      imageFile.value = File(pickedImage.path);
      print("Image Path: ${pickedImage.path}");
      return imageFile.value;
    }
    return null;
  }
}