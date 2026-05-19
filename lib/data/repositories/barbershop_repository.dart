import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/app_constants.dart';
import '../models/barbershop_model.dart';

class BarbershopRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<BarbershopModel>> streamApprovedBarbershops({bool activeOnly = true}) {
    Query query = _firestore
        .collection(AppConstants.barbershopsCollection)
        .where('isApproved', isEqualTo: true);

    if (activeOnly) {
      query = query.where('isActive', isEqualTo: true);
    }

    return query.snapshots().map(
          (snapshot) => snapshot.docs.map(BarbershopModel.fromFirestore).toList(),
        );
  }

  Stream<List<BarbershopModel>> streamBarbershops({bool? isApproved, bool? isActive}) {
    Query query = _firestore.collection(AppConstants.barbershopsCollection);
    if (isApproved != null) {
      query = query.where('isApproved', isEqualTo: isApproved);
    }
    if (isActive != null) {
      query = query.where('isActive', isEqualTo: isActive);
    }

    return query.snapshots().map(
          (snapshot) => snapshot.docs.map(BarbershopModel.fromFirestore).toList(),
        );
  }

  Future<BarbershopModel?> getBarbershopById(String id) async {
    final doc = await _firestore.collection(AppConstants.barbershopsCollection).doc(id).get();
    if (!doc.exists) return null;
    return BarbershopModel.fromFirestore(doc);
  }

  Future<void> updateApprovalStatus(String barbershopId, bool isApproved) async {
    await _firestore.collection(AppConstants.barbershopsCollection).doc(barbershopId).update({
      'isApproved': isApproved,
      'isActive': isApproved ? true : false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateActiveStatus(String barbershopId, bool isActive) async {
    await _firestore.collection(AppConstants.barbershopsCollection).doc(barbershopId).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
