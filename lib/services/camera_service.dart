import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

class CameraService {
  final ImagePicker _picker = ImagePicker();

  // カメラで写真を撮影
  Future<dynamic> takePicture() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo != null) {
        if (kIsWeb) {
          return photo; // Web版ではXFileを返す
        }
        return File(photo.path);
      }
      return null;
    } catch (e) {
      throw Exception('カメラの起動に失敗しました: $e');
    }
  }

  // ギャラリーから画像を選択
  Future<dynamic> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        if (kIsWeb) {
          return image; // Web版ではXFileを返す
        }
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw Exception('ギャラリーの起動に失敗しました: $e');
    }
  }
}
