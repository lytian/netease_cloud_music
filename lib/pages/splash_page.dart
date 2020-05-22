import 'package:flutter/material.dart';
import 'package:netease_cloud_music/application.dart';
import 'package:netease_cloud_music/models/profile.dart';
import 'package:netease_cloud_music/pages/login_page.dart';
import 'package:netease_cloud_music/pages/main_page.dart';
import 'package:netease_cloud_music/provider/profile_provider.dart';
import 'package:netease_cloud_music/utils/dio_utils.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  void _initAsync() async {
    await DioUtils.init();

    prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId');
    if (userId == null) {
      // 跳转登录
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return LoginPage();
      }));
    } else {
      // 刷新登录，获取用户数据
      try {
        await DioUtils.get('/login/refresh');
        var data = await DioUtils.get('/user/detail', queryParameters: {
          'uid': userId
        });
        // 设置用户数据
        Provider.of<ProfileProvider>(context, listen: false).setProfile(Profile.fromJson(data['profile']));
        // 跳转主页
        goMain();
      } catch(e) {
        // 跳转登录
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
          return LoginPage();
        }));
      }
    }
  }

  void goMain() async {
    await Application.initSp();
    // TODO 播放默认歌曲
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return MainPage();
    }));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    Application.screenWidth = size.width;
    Application.screenHeight = size.height;
    Application.statusBarHeight = MediaQuery.of(context).padding.top;
    Application.bottomBarHeight = MediaQuery.of(context).padding.bottom;

    return Material(
      child: Image.asset(
        'images/splash_bg.png',
        width: double.infinity,
        fit: BoxFit.fill,
        height: double.infinity,
      )
    );
  }
}