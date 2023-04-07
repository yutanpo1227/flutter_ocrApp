import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';


class Pick{
  XFile? image;
  final picker = ImagePicker();

  // 画像をギャラリーから選ぶ関数
  Future<XFile?> pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    // 画像がnullの場合戻る
    if (image == null) return null;

    final imageTemp = image;

    return imageTemp;
  }
  // カメラを使う関数
  Future<XFile?> pickImageCamera() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    // 画像がnullの場合戻る
    if (image == null) return null;

    final imageTemp = image;

    return imageTemp;
  }
}