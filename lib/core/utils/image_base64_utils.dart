import 'dart:convert';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

class ImageBase64Utils {
  const ImageBase64Utils._();

  static Future<String> encodeXFile(XFile file) async {
    final bytes = await file.readAsBytes();
    final mimeType = _mimeTypeFromName(file.name);
    return 'data:$mimeType;base64,${base64Encode(bytes)}';
  }

  static bool isBase64Image(String value) {
    final source = value.trim();
    return source.startsWith('data:image/') || _tryDecodeRawBase64(source) != null;
  }

  static Uint8List? decode(String value) {
    final source = value.trim();
    if (source.isEmpty) return null;

    if (source.startsWith('data:image/')) {
      final commaIndex = source.indexOf(',');
      if (commaIndex == -1) return null;
      return _tryDecodeRawBase64(source.substring(commaIndex + 1));
    }

    return _tryDecodeRawBase64(source);
  }

  static Uint8List? _tryDecodeRawBase64(String value) {
    try {
      return base64Decode(value);
    } catch (_) {
      return null;
    }
  }

  static String _mimeTypeFromName(String name) {
    final extension = name.split('.').last.toLowerCase();
    return switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      _ => 'image/jpeg',
    };
  }
}
