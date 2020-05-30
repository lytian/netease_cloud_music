import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:netease_cloud_music/pages/main_left_page.dart';
import 'package:netease_cloud_music/widget/play_bar.dart';
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
  int _tabIndex = 0;
  Color _tabColor = Colors.black87;
  Color _iconColor = Colors.black54;
  double _opacity = 1;
  GlobalKey<ScaffoldState> _key = GlobalKey();

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
            ? Color.lerp(Colors.white70, Colors.black54, _tabController.animation.value)
            : Colors.black54;
        _opacity = _tabController.animation.value < 1 ? _tabController.animation.value : 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white.withOpacity(_opacity),
        leading: IconButton(
          onPressed: () {
            _key.currentState.openDrawer();
          },
          icon: Icon(Icons.menu, color: _iconColor),
        ),
        centerTitle: true,
        title: VTabBar(
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
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.search, color: _iconColor),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Column(
        children: <Widget>[
          Expanded(
            child: TabBarView(
                controller: _tabController,
                children: _tabs.map((item) => item.view).toList()
            ),
          ),
          PlayBar()
        ],
      ),
      drawer: Drawer(
        child: MainLeftPage(),
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