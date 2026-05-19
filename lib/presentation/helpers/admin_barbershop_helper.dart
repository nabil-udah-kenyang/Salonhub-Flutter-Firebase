import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/app_constants.dart';
import '../controllers/auth_controller.dart';

class AdminBarbershopHelper {
  AdminBarbershopHelper._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static List<String> _resolveOwnerIds(AuthController authController) {
    final user = authController.user;
    final seedOwnerId = user?.preferences?['barbershopOwnerId']?.toString();

    return <String>{
      if (user?.id != null && user!.id!.isNotEmpty) user.id!,
      if (seedOwnerId != null && seedOwnerId.isNotEmpty) seedOwnerId,
      if (user?.email.toLowerCase().contains('barberking') == true) 'admin_barberking',
      if (user?.email.toLowerCase().contains('urban') == true) 'admin_urban_groom',
      if (user?.name.toLowerCase().contains('barberking') == true) 'admin_barberking',
      if (user?.name.toLowerCase().contains('urban') == true) 'admin_urban_groom',
    }.toList();
  }

  static Future<String?> fetchPrimaryBarbershopId(AuthController authController) async {
    final ownerIds = _resolveOwnerIds(authController);
    if (ownerIds.isEmpty) return null;

    final query = await _firestore
        .collection(AppConstants.barbershopsCollection)
        .where('ownerId', whereIn: ownerIds)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      return null;
    }

    return query.docs.first.id;
  }
}
