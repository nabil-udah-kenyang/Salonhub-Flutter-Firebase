import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<UserModel>> streamUsers({String? role}) {
    Query query = _firestore.collection(AppConstants.usersCollection);
    if (role != null && role.isNotEmpty && role != 'all') {
      query = query.where('role', isEqualTo: role);
    }
    return query.snapshots().map(
          (snapshot) => snapshot.docs.map(UserModel.fromFirestore).toList(),
        );
  }

  Future<void> updateUser({
    required String userId,
    String? name,
    String? role,
    bool? isActive,
  }) async {
    final updateData = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (name != null) updateData['name'] = name;
    if (role != null) updateData['role'] = role;
    if (isActive != null) updateData['isActive'] = isActive;

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .update(updateData);
  }

  Future<void> deleteUser(String userId) async {
    await _firestore.collection(AppConstants.usersCollection).doc(userId).delete();
  }

  Future<int> getUserCount({String? role}) async {
    Query query = _firestore.collection(AppConstants.usersCollection);
    if (role != null && role.isNotEmpty) {
      query = query.where('role', isEqualTo: role);
    }
    final snapshot = await query.get();
    return snapshot.size;
  }
}
