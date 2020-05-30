import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:netease_cloud_music/application.dart';
import 'package:netease_cloud_music/models/user.dart';
import 'package:netease_cloud_music/pages/input_phone.dart';
import 'package:netease_cloud_music/provider/profile_provider.dart';
import 'package:netease_cloud_music/utils/dio_utils.dart';
import 'package:provider/provider.dart';

class MainLeftPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, child) {
        User user = provider.profile;
        return Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  UserAccountsDrawerHeader(
                    accountName: Text(user.nickname, style: TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold),),
                    accountEmail: Text(user.description == null || user.description.isEmpty ? '暂无描述' : user.description, style: TextStyle(fontSize: 14, color: Colors.white),),
                    currentAccountPicture: CircleAvatar(
                      backgroundImage: NetworkImage(user.avatarUrl + '?param=400y400'),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      image: DecorationImage(
                        image: NetworkImage(user.backgroundUrl),
                        fit: BoxFit.cover
                      )
                    )
                  ),
                  Container(
                    height: 1200,
                    alignment: Alignment.center,
                    child: Text('列表数据'),
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            _buildBottomBar(context),
          ],
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: Application.bottomBarHeight),
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
              top: BorderSide(color: Color(0xffe0e0e0), width: 0.5)
          )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          GestureDetector(
              onTap: () {},
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.brightness_2, color: Colors.black87, size: 18,),
                    SizedBox(width: 6,),
                    Text('夜间模式', style: TextStyle(fontSize: 14, color: Colors.black87, height: 1),)
                  ],
                ),
              )
          ),
          GestureDetector(
              onTap: () {},
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.settings, color: Colors.black87, size: 18,),
                    SizedBox(width: 6,),
                    Text('设置', style: TextStyle(fontSize: 14, color: Colors.black87, height: 1),)
                  ],
                ),
              )
          ),
          GestureDetector(
              onTap: () async {
                BotToast.showLoading();
                await DioUtils.get('/logout');
                BotToast.closeAllLoading();
                // 关闭Drawer
                Navigator.pop(context);
                // 跳转登录页面。并清空之前所有的路由近路
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
                  return InputPhonePage();
                }), (Route<dynamic> route) => false);
                // 延迟清空Profile
                Future.delayed(Duration(milliseconds: 300), () {
                  Provider.of<ProfileProvider>(context, listen: false).setProfile(null);
                });
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.power_settings_new, color: Colors.black87, size: 18,),
                    SizedBox(width: 6,),
                    Text('退出', style: TextStyle(fontSize: 14, color: Colors.black87, height: 1),)
                  ],
                ),
              )
          ),
        ],
      ),
    );
  }
}
