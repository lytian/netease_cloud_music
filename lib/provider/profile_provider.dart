import 'package:flutter/material.dart';
import 'package:netease_cloud_music/models/user.dart';

class ProfileProvider with ChangeNotifier {
  String _token;
  int _loginType = 0;
  User _profile;

  String get token => _token;
  int get loginType => _loginType;
  User get profile => _profile;


  void setLoginType(int type) {
    _loginType = type;
    notifyListeners();
  }
  void setToken(String token) {
    _token = token;
    notifyListeners();
  }
  void setProfile(User profile) {
    _profile = profile;
    notifyListeners();
  }
}