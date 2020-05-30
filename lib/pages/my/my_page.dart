import 'dart:math';

import 'package:flutter/material.dart';
import 'package:netease_cloud_music/application.dart';
import 'package:netease_cloud_music/models/play_list_detail.dart';
import 'package:netease_cloud_music/models/user.dart';
import 'package:netease_cloud_music/pages/discover/play_list_page.dart';
import 'package:netease_cloud_music/provider/play_songs_provider.dart';
import 'package:netease_cloud_music/provider/profile_provider.dart';
import 'package:netease_cloud_music/utils/dio_utils.dart';
import 'package:netease_cloud_music/widget/custom_future_builder.dart';
import 'package:netease_cloud_music/widget/flexible_detail_bar.dart';
import 'package:netease_cloud_music/widget/music_list_header.dart';
import 'package:provider/provider.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> with AutomaticKeepAliveClientMixin {
  List _musicCards = [
    {
      'hasBg': true,
      'head':  '',
      'title': '我喜欢的音乐',
      'icon': 'images/icon_liked_full.png',
      'tail': Container(
        height: 24,
        padding: EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Color.fromRGBO(210, 210, 210, 0.3),
          borderRadius: BorderRadius.circular(24)
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.play_arrow, size: 14, color: Colors.white,),
            Text('心动模式', style: TextStyle(fontSize: 12, color: Colors.white, height: 1),)
          ],
        ),
      ),
      'background': 'images/img_000.jpg'
    },
    {
      'hasBg': true,
      'head':  '',
      'title': '私人FM',
      'icon': 'images/icon_shears.png',
      'tail': Text('最懂你的推荐', style: TextStyle(fontSize: 12, color: Colors.grey),),
      'background': 'images/img_001.jpg'
    },
    {
      'head':  '推荐',
      'title': '最嗨电台',
      'icon': 'images/icon_check.png',
      'tail': Text('专业电音平台', style: TextStyle(fontSize: 12, color: Colors.grey),),
      'background': 'images/card_bg.png'
    },
    {
      'head':  '推荐',
      'title': '古典专区',
      'icon': 'images/icon_mutil.png',
      'tail': Text('专业古典大全', style: TextStyle(fontSize: 12, color: Colors.grey),),
      'background': 'images/card_bg.png'
    },
    {
      'head':  '推荐',
      'title': '歌手兴趣全',
      'icon': 'images/icon_bill.png',
      'tail': Text('一起畅聊歌手', style: TextStyle(fontSize: 12, color: Colors.grey),),
      'background': 'images/card_bg.png'
    }
  ];
  PlayListDetail _likedDetail; // 我喜欢的歌单
  int _playListType = 0;
  List<PlayListDetail> _createPlayList = []; // 创建的歌单
  List<PlayListDetail> _collectPlayList = []; // 收藏的歌单
  var _playRecord; // 播放歌曲记录
  bool _showRecommendPlayList = true;

  @override
  void initState() {
    super.initState();

    int userId = Provider.of<ProfileProvider>(context, listen: false).profile.userId;
    _getMyPlayList(userId);
    _getPlayRecord(userId);
  }

  /// 获取我的歌单
  Future _getMyPlayList(int userId) async {
    var data = await DioUtils.get('/user/playlist', queryParameters: {
      'uid': userId
    });
    List<PlayListDetail> list = (data['playlist'] as List).map((e) => PlayListDetail.fromJson(e)).toList();
    setState(() {
      if (list.length > 0) {
        _likedDetail = list[0];
        list.removeAt(0);
      }
      _createPlayList = list.where((e) => e.creator.userId == userId).toList();
      _collectPlayList = list.where((e) => e.subscribed == true).toList();
    });
  }

  /// 获取播放记录、歌单记录
  Future _getPlayRecord(int userId) async {
    var data = await DioUtils.get('/user/record', queryParameters: {
      'uid': userId,
      'type': 0
    });
    List list = data['allData'] as List;
    if (list.isNotEmpty) {
      setState(() {
        _playRecord = {
          'count': list.length,
          'picUrl': list[50]['song']['al']['picUrl'] + '?param=200y200'
        };
      });
    }
  }

  /// 获取推荐歌单
  Future _getRecommendList() async {
    var data = await DioUtils.get('/recommend/resource');
    return data['recommend'];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    User profile = Provider.of<ProfileProvider>(context).profile;
    List<Widget> children = [];
    // 添加音乐卡
    children.add(
      Container(
        height: 160,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _musicCards.length,
            itemBuilder: (context, index) {
              return _buildMusicCard(index);
            }),
      ),
    );
    // 添加最近播放
    if (_playRecord != null) {
      children.add(_buildTitle('最近播放'));
      children.add(_CommonGridView(
        data: [
          _GridItemData(title: '全部已播歌曲', desc: '${_playRecord['count']}首', picUrl: _playRecord['picUrl']),
        ],
        onItemTap: (item) {
          print(item);
        },
        leftChild: Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Color.fromRGBO(255, 255, 255, 0.9),
            borderRadius: BorderRadius.circular(24)
          ),
          child: Icon(Icons.play_arrow, color: Colors.red, size: 18,),
        ),
      ));
    }
    // 添加我的歌单
    children.add(_buildTitle('', icon: Icons.more_vert, moreText: '', content: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        GestureDetector(
          onTap: () {
            setState(() {
              _playListType = 0;
            });
          },
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: _playListType == 0 ? Colors.black87 : Colors.grey),
              children: [
                TextSpan(text: '创建歌单', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1)),
                TextSpan(text: ' ' + _createPlayList.length.toString(), style: TextStyle(fontSize: 12, height: 1)),
              ]
            ),
          ),
        ),
        SizedBox(width: 24,),
        GestureDetector(
          onTap: () {
            setState(() {
              _playListType = 1;
            });
          },
          child: RichText(
            text: TextSpan(
                style: TextStyle(color: _playListType == 1 ? Colors.black87 : Colors.grey),
                children: [
                  TextSpan(text: '收藏歌单', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1)),
                  TextSpan(text: ' ' + _collectPlayList.length.toString(), style: TextStyle(fontSize: 12, height: 1)),
                ]
            ),
          ),
        )
      ],
    )));
    List<_GridItemData> playListData = [];
    if (_playListType == 0) {
      playListData = _createPlayList.map((e) {
        return _GridItemData(title: e.name, desc: e.trackCount.toString() + '首', picUrl: e.coverImgUrl + '?param=200y200', data: e);
      }).toList();
    } else {
      playListData = _collectPlayList.map((e) {
        return _GridItemData(title: e.name, desc: e.trackCount.toString() + '首', picUrl: e.coverImgUrl + '?param=200y200', data: e);
      }).toList();
    }
    children.add(_CommonGridView(data: playListData, onItemTap: (item) {
      var id = (item.data as PlayListDetail).id;
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return PlayListPage(id);
      }));
    },));

    // 添加推荐歌单
    if (_showRecommendPlayList) {
      children.add(_buildTitle('推荐歌单', moreText: '', icon: Icons.close, onTap: () {
        setState(() {
          _showRecommendPlayList = false;
        });
      }));
      children.add(CustomFutureBuilder(
        futureFunc: _getRecommendList,
        builder: (context, data) {
          List list = data as List;
          // 和发现页面推荐的歌单有重复
          if (list.length >= 20) {
            list = list.sublist(8, 14);
          } else {
            list = list.sublist(0, min(6, list.length));
          }
          List<_GridItemData> gridData = list.map((e) => _GridItemData(
            title: e['name'],
            desc: e['copywriter'],
            picUrl: e['picUrl'],
            data: e
          )).toList();
          return _CommonGridView(data: gridData, onItemTap: (item) {
            var id = item.data['id'];
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return PlayListPage(id);
            }));
          },);
        },
      ));
    }

    // 添加底部空隙
    children.add(SizedBox(height: 20,));

    return CustomScrollView (
      slivers: <Widget>[
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          elevation: 0,
          leading: Container(),
          bottom: MusicListHeader(
            content: Text(' 我的音乐', style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold
            ),),
            tail: Row(
              children: <Widget>[
                Icon(Icons.directions_car, color: Colors.grey, size: 18,),
                Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 13,)
              ],
            ),
          ),
          flexibleSpace: FlexibleDetailBar(
            content: _buildProfileInfo(profile),
            titleBackground: Container(
              color: Color.fromRGBO(0, 0, 0, 0.5),
            ),
            background: Container(
              foregroundDecoration: BoxDecoration(
                color: Colors.black.withOpacity(0.68),
                backgroundBlendMode: BlendMode.darken
              ),
              child: Image.network(profile.backgroundUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate(children)
        ),
      ]
    );
  }
  /// 构建个人信息
  Widget _buildProfileInfo(User profile) {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, left: 12, right: 12),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: Colors.grey,
                    backgroundImage: NetworkImage(profile.avatarUrl),
                    radius: 25,
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                              margin: EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 1,
                                    child: Text(profile.remarkName ?? profile.nickname, style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),),
                                  ),
                                  Text('开通黑胶VIP', style: TextStyle(
                                      color: Color.fromRGBO(255, 255, 255, 0.6),
                                      fontSize: 11
                                  ),),
                                  Icon(Icons.arrow_forward_ios, color: Color.fromRGBO(255, 255, 255, 0.6), size: 11,)
                                ],
                              )
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(255, 255, 255, 0.4),
                                borderRadius: BorderRadius.all(Radius.circular(12))
                            ),
                            child: Text('Lv.6', style: TextStyle(
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                              color: Colors.white,
                            ),),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _buildMyTabItem(assets: 'images/icon_my_local.png', text: '本地音乐'),
                  _buildMyTabItem(assets: 'images/icon_my_download.png', text: '下载管理'),
                  _buildMyTabItem(assets: 'images/icon_my_radio.png', text: '我的电台'),
                  _buildMyTabItem(assets: 'images/icon_my_collected.png', text: '我的收藏'),
                  _buildMyTabItem(assets: 'images/icon_my_new.png', text: '关注新歌'),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  /// 构建单个Tab
  Widget _buildMyTabItem({ String assets, String text, Function onTap }) {
    return InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 6),
              child: Image.asset(assets, width: 22,),
            ),
            Text(text, style: TextStyle(color: Colors.white, fontSize: 13),)
          ],
        )
    );
  }
  /// 构建音乐卡片
  Widget _buildMusicCard(int index) {
    var item = _musicCards[index];
    return GestureDetector(
      onTap: () {
        switch (index) {
          case 0:
            if (_likedDetail != null) {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return PlayListPage(_likedDetail.id, liked: true,);
              }));
            }
            break;
          case 1:
            break;
          case 2:
            break;
          case 3:
            break;
          case 4:
            break;
        }
      },
      child: Container(
        height: 160,
        width: 120,
        margin: EdgeInsets.only(right: index == _musicCards.length - 1 ? 12 : 4, left: index == 0 ? 12 : 4),
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
            color: Color(0xffe6e6e6),
            borderRadius: BorderRadius.all(Radius.circular(5)),
            image: DecorationImage(
                image: AssetImage(item['background']),
                fit: BoxFit.cover
            )
        ),
        child: Column(
          children: <Widget>[
            Text(item['head'], style: TextStyle(fontSize: 12, color: Colors.grey),),
            Spacer(),
            item['hasBg'] == true
                ? Image.asset(item['icon'], height: 28)
                : Image.asset(item['icon'], height: 28, color: Colors.black),
            Text(item['title'], style: TextStyle(fontSize: 14, color: item['hasBg'] == true ? Colors.white : Colors.black87),),
            Spacer(),
            item['tail']
          ],
        ),
      )
    );
  }
  ///构建通用的标题栏
  Widget _buildTitle(String title, { String moreText = '更多', Function onTap, IconData icon, Widget content}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          content ?? Text(title, style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            height: 1
          ),),
          GestureDetector(
            onTap: onTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(moreText, style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  height: 1
                ),),
                Icon(icon ?? Icons.chevron_right, color: Colors.grey, size: icon == null ? 16 : 20,)
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _GridItemData {
  final String title;
  final String desc;
  final String picUrl;
  final bool showPic;
  final dynamic data;

  _GridItemData({@required this.title, this.picUrl, this.desc, this.showPic = true, this.data});

  @override
  String toString() {
    return 'title: $title, desc: $desc, picUrl: $picUrl, showPic: $showPic.';
  }
}

typedef GridItemTapCallback(_GridItemData item);

class _CommonGridView extends StatelessWidget {
  final List<_GridItemData> data;
  final GridItemTapCallback onItemTap;
  final Widget leftChild;

  _CommonGridView({
    @required this.data,
    this.onItemTap,
    this.leftChild
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 16,
        children: data.map((item) {
          List<Widget> rightChildren = [];
          rightChildren.add(Text(item.title, style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis,));
          if (item.desc != null && item.desc.isNotEmpty) {
            rightChildren.add(SizedBox(height: 3,));
            rightChildren.add(Text(item.desc, style: TextStyle(fontSize: 12, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis,));
          }
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              onItemTap(item);
            },
            child: SizedBox(
              width: (Application.screenWidth - 46) / 2,
              child: Row(
                children: <Widget>[
                  Container(
                    width: 56,
                    height: 56,
                    margin: EdgeInsets.only(right: 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(4),
                        image: item.showPic ? DecorationImage(
                            image: NetworkImage(item.picUrl),
                            fit: BoxFit.cover
                        ) : null
                    ),
                    child: leftChild,
                  ),
                  Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: rightChildren,
                      )
                  )
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
