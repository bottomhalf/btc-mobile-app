import 'package:get/get.dart';
import '../../models/user_model.dart';

class ProfileController extends GetxController {
  final user = UserModel.instance;

  String get initials {
    final first = user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '';
    final last = user.lastName.isNotEmpty ? user.lastName[0].toUpperCase() : '';
    return '$first$last';
  }
}
