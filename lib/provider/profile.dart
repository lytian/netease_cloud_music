import 'package:flutter/material.dart';
import 'package:netease_cloud_music/models/profile.dart';

class ProfileProvider with ChangeNotifier {
  String _token;
  int _loginType = 0;
  Profile _profile;

  String get token => _token;
  int get loginType => _loginType;
  Profile get profile => _profile;


  void setLoginType(int type) {
    _loginType = type;
    notifyListeners();
  }
  void setToken(String token) {
    _token = token;
    notifyListeners();
  }
  void setProfile(Profile profile) {
    _profile = profile;
    notifyListeners();
  }
}