import 'package:cloud_firestore/cloud_firestore.dart';

class PlatformSettingsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'platform_settings';
  static const String _document = 'master';

  DocumentReference<Map<String, dynamic>> get _doc =>
      _firestore.collection(_collection).doc(_document);

  Stream<Map<String, dynamic>> streamSettings() {
    return _doc.snapshots().map((snapshot) => snapshot.data() ?? {});
  }

  Future<void> updateSetting(String keyPath, dynamic value) async {
    final data = _buildNestedMap(keyPath.split('.'), value);
    await _doc.set(data, SetOptions(merge: true));
  }

  Future<void> logAction(String actionKey) async {
    await _doc.set({
      'actions': {
        actionKey: FieldValue.serverTimestamp(),
      }
    }, SetOptions(merge: true));
  }

  Future<void> removeSetting(String keyPath) async {
    await _doc.update({keyPath: FieldValue.delete()});
  }

  Map<String, dynamic> _buildNestedMap(List<String> keys, dynamic value) {
    final Map<String, dynamic> result = {};
    Map<String, dynamic> current = result;
    for (var i = 0; i < keys.length; i++) {
      final key = keys[i];
      if (i == keys.length - 1) {
        current[key] = value;
      } else {
        current = current.putIfAbsent(key, () => <String, dynamic>{})
            as Map<String, dynamic>;
      }
    }
    return result;
  }
}
