import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  StorageService._();

  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static Future<String> uploadBarbershopImage({
    required String barbershopId,
    required String folder,
    required XFile file,
  }) async {
    final bytes = await file.readAsBytes();
    final extension = file.name.split('.').last;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.${extension.toLowerCase()}';
    final ref = _storage.ref('barbershops/$barbershopId/$folder/$fileName');

    final metadata = SettableMetadata(contentType: 'image/$extension');
    await ref.putData(bytes, metadata);
    return ref.getDownloadURL();
  }

  static Future<String> uploadGeneralImage({
    required String path,
    required XFile file,
  }) async {
    final bytes = await file.readAsBytes();
    final extension = file.name.split('.').last;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.${extension.toLowerCase()}';
    final ref = _storage.ref('$path/$fileName');

    final metadata = SettableMetadata(contentType: 'image/$extension');
    await ref.putData(bytes, metadata);
    return ref.getDownloadURL();
  }
}
