import 'dart:typed_data';
import 'package:image_picker_for_web/image_picker_for_web.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';

class Pick{
  XFile? image;
  final picker = ImagePickerPlugin();

  // 画像をギャラリーから選ぶ関数
  Future<XFile?> pickImage() async {
    final image = await ImagePickerPlugin().getImage(source: ImageSource.gallery);
    // 画像がnullの場合戻る
    if (image == null) return null;

    final imageTemp = image;

    return imageTemp;
  }
  // カメラを使う関数
  Future<XFile?> pickImageCamera() async {
    final image = await ImagePickerPlugin().pickImage(source: ImageSource.camera);
    // 画像がnullの場合戻る
    if (image == null) return null;

    final imageTemp = XFile(image.path);

    return imageTemp;
  }
}
