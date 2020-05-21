import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netease_cloud_music/widget/vtab.dart';

import 'discover/discover_page.dart';
import 'event/event_page.dart';
import 'my/my_page.dart';
import 'video/video_list_page.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {

  TabController _tabController;
  List<_TabItem> _tabs = [
    _TabItem('我的', MyPage()),
    _TabItem('发现', DiscoverPage()),
    _TabItem('云村', EventPage()),
    _TabItem('视频', VideoPage()),
  ];
  int _tabIndex = 1;
  Color _tabColor = Colors.black87;
  Color _iconColor = Colors.grey;
  double _opacity = 1;

  @override
  void initState() {
    super.initState();

    _tabController = new TabController(length: _tabs.length, vsync: this, initialIndex: 1);
    _tabController.addListener(() {
      setState(() {
        _tabIndex = _tabController.index;
      });
    });
    _tabController.animation.addListener(() {
      setState(() {
        _tabColor = _tabController.animation.value < 0.6 ? Colors.white : Colors.black87;
        _iconColor = _tabController.animation.value < 1
            ? Color.lerp(Colors.white70, Colors.grey, _tabController.animation.value)
            : Colors.grey;
        _opacity = _tabController.animation.value < 1 ? _tabController.animation.value : 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          NotificationListener<MainTabNotification>(
            onNotification: (notification) {
              print(notification.direction.toString());
//              _tabController.offset();
              return false;
            },
            child: TabBarView(
                controller: _tabController,
                children: _tabs.map((item) => item.view).toList()
            ),
          ),
          _buildAppBar(),
        ],
      )
    );
  }

  Widget _buildAppBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: PreferredSize(
        preferredSize: Size.fromHeight(48),
        child: Container(
          color: Colors.white.withOpacity(_opacity),
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                //有Appbar时，会被覆盖
                statusBarIconBrightness: Brightness.dark),
            child: SafeArea(child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                InkWell(
                    onTap: () {},
                    child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Icon(Icons.menu, color: _iconColor,),
                    )
                ),
                VTabBar(
                  isScrollable: true,
                  controller: _tabController,
                  indicator: BoxDecoration(),
                  labelPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  unselectedLabelColor: Colors.grey,
                  unselectedLabelStyle: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 16
                  ),
                  labelColor: _tabColor,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                  ),
                  tabs: _tabs.map((item) {
                    return Tab(text: item.title);
                  }).toList(),
                ),
                InkWell(
                  onTap: () {},
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Icon(Icons.search, color: _iconColor,),
                  )
                ),
              ],
            ),
          )),
        ),
      ),
    );
  }
}

class _TabItem {
  final String title;
  final Widget view;

  _TabItem(this.title, this.view);
}

class MainTabNotification extends Notification {
  final AxisDirection direction;

  MainTabNotification({this.direction});
}