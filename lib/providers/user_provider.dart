import 'package:flutter/widgets.dart';
import 'package:roy_mariane_mobile/models/user.dart';
import 'package:roy_mariane_mobile/resources/auth_methods.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  final AuthMethods _authMethods = AuthMethods();

  User get getUser => _user!;

  Future<void> refreshUser() async {
    User user = await _authMethods.getUserDetails();
    _user = user;
    notifyListeners();
  }
}