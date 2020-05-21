import 'package:flutter/material.dart';
import 'package:netease_cloud_music/models/profile.dart';
import 'package:netease_cloud_music/provider/profile.dart';
import 'package:netease_cloud_music/widget/flexible_detail_bar.dart';
import 'package:netease_cloud_music/widget/music_list_header.dart';
import 'package:provider/provider.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> with SingleTickerProviderStateMixin {
  List _musicCards = [
    {
      'hasBg': true,
      'head':  '',
      'title': '我喜欢的音乐',
      'icon': 'images/icon_liked_full.png',
      'tail': Text('最懂你的推荐', style: TextStyle(fontSize: 12, color: Colors.grey),),
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

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(MyPage oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    Profile profile = Provider.of<ProfileProvider>(context).profile;
    return CustomScrollView (
      slivers: <Widget>[
        SliverAppBar(
          expandedHeight: 250,
          pinned: true,
          elevation: 0,
          bottom: MusicListHeader(
            content: Text('我的音乐', style: TextStyle(
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
              color: Colors.black87,
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
        SliverToBoxAdapter(
          child: Container(
            height: 160,
            color: Colors.white,
            margin: EdgeInsets.only(bottom: 8),
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _musicCards.length,
                itemBuilder: (context, index) {
                  return _buildMusicCard(index);
                }),
            ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: <Widget>[
                Text('最近播放', style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold
                ),),
                Spacer(),
                Text('更多', style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12
                ),),
                Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 13,)
              ],
            ),
          ),
        )
      ]
    );
  }
  // 构建个人信息
  Widget _buildProfileInfo(Profile profile) {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 48, left: 12, right: 12),
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
  // 构建单个Tab
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
  // 构建音乐卡片
  Widget _buildMusicCard(int index) {
    var item = _musicCards[index];
    return Container(
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
    );
  }
}

