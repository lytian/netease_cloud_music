import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:netease_cloud_music/application.dart';
import 'package:netease_cloud_music/models/play_list_detail.dart';
import 'package:netease_cloud_music/models/song.dart';
import 'package:netease_cloud_music/pages/discover/play_song_page.dart';
import 'package:netease_cloud_music/provider/play_songs_provider.dart';
import 'package:netease_cloud_music/provider/profile_provider.dart';
import 'package:netease_cloud_music/utils/dio_utils.dart';
import 'package:netease_cloud_music/utils/number_utils.dart';
import 'package:netease_cloud_music/widget/custom_future_builder.dart';
import 'package:netease_cloud_music/widget/flexible_detail_bar.dart';
import 'package:netease_cloud_music/widget/music_list_header.dart';
import 'package:netease_cloud_music/widget/play_bar.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

/// 歌单列表页面
class PlayListPage extends StatefulWidget {
  // 歌单ID
  final int id;
  final bool liked; // 是否喜欢的歌单，将使用智能模式播放

  PlayListPage(this.id, { this.liked = false });

  @override
  _PlayListPageState createState() => _PlayListPageState();
}

class _PlayListPageState extends State<PlayListPage> {

  String _title = '歌单';
  PlayListDetail _detail;
  ScrollController _scrollController;
  int pageNum = 1;
  bool noMore = false;

  Future _getPlayListDetail() async {
    var data = await DioUtils.get('/playlist/detail', queryParameters: {
      'id': widget.id
    });
    PlayListDetail detail = PlayListDetail.fromJson(data['playlist']);
    // 歌单接口，最多只返回20首歌曲。重新根据歌曲id列表获取数据
    // 最多去获取200条数据
    if (detail.trackCount >= 20) {
      List<TrackId> ids = detail.trackIds.sublist(0, math.min(200, detail.trackCount - 1));
      var playlistData = await DioUtils.get('/song/detail', queryParameters: {
        'ids': ids.map((e) => e.id).join(',')
      });
      data['playlist']['tracks'] = playlistData['songs'];
      detail.tracks = (playlistData['songs'] as List).map((e) => Track.fromJson(e)).toList();
    }
    if (widget.liked) {
      String username = Provider.of<ProfileProvider>(context, listen: false).profile.nickname;

      detail.name = detail.name.replaceAll(username, '我').trim();
      print(username + ' : ' + detail.name);
    }

    setState(() {
      _detail = detail;
      if (_detail.specialType == 100) {
        _title = '官方动态歌单';
      }
    });
    return data['playlist'];
  }
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(() {
      if (_detail == null || _detail.specialType == 100) return;

      if (_scrollController.offset < 45 && _title != '歌单') {
        setState(() {
          _title = '歌单';
        });
      } else if(_scrollController.offset >= 60 && _title != _detail.name) {
        setState(() {
          _title = _detail.name;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: <Widget>[
                _buildSliverAppBar(),
                SliverToBoxAdapter(
                  child: CustomFutureBuilder(
                    futureFunc: _getPlayListDetail,
                    builder: (context, data) {
                      PlayListDetail detail = PlayListDetail.fromJson(data);
                      return Consumer<PlaySongsProvider>(
                        builder: (context, model, child) {
                          return MediaQuery.removePadding(
                            removeTop: true,
                            context: context,
                            child: ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: detail.tracks.length,
                              itemBuilder: (context, index) {
                                Track track = detail.tracks[index];
                                return _buildMusicItem(track, index, model.curSong != null && model.curSong.id == track.id);
                              })
                          );
                        },
                      );
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildSubscribers(),
                ),
              ],
            ),
          ),
          PlayBar()
        ],
      ),
    );
  }

  /// 构建头部
  Widget _buildSliverAppBar() {
    Widget backgroundWidget;
    if (_detail == null) {
      backgroundWidget = Container(
        color: Colors.white,
      );
    } else if (_detail.backgroundCoverUrl == null) {
//      backgroundWidget = Stack(
//        children: <Widget>[
//          Image.network(
//            _detail.coverImgUrl,
//            width: double.infinity,
//            height: double.infinity,
//            fit: BoxFit.cover,
//            alignment: Alignment.bottomCenter,
//          ),
//          BackdropFilter(
//            filter: ImageFilter.blur(
//              sigmaY: 100,
//              sigmaX: 100,
//            ),
//            child: Container(
//              color: Colors.black38,
//              width: double.infinity,
//              height: double.infinity,
//            ),
//          )
//        ]
//      );
      backgroundWidget = Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xff778899),
              Color(0xffA9A9A9),
            ]
          )
        ),
      );
    } else {
      backgroundWidget = Container(
        decoration: BoxDecoration(
          color: Color(0xFFFFE4E1),
          image: DecorationImage(
            image: NetworkImage(_detail.backgroundCoverUrl),
            fit: BoxFit.cover,
            alignment: Alignment.bottomCenter,
          )
        ),
      );
    }

    int userId = Provider.of<ProfileProvider>(context, listen: false).profile.userId;

    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      elevation: 0,
      title: _title.length <=12
        ? Text(_title)
        : SizedBox(
          height: 36,
          child: Marquee(
            text: _title,
            startPadding: 16,
            blankSpace: 120,
          ),
        ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.search),
          iconSize: 26,
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.more_vert),
          iconSize: 26,
          onPressed: () {},
        )
      ],
      bottom: _detail != null ? MusicListHeader(
        onTap: () {
          _playSongs(all: true);
        },
        count: _detail.trackIds.length,
        tail: _detail.creator.userId != userId
          ?_detail.subscribed
            ? InkWell(
              onTap: () {
                _toggleSubscribe();
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(48)
                ),
                child:Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.add, size: 16, color: Colors.white,),
                    Text(' 收藏(${NumberUtils.amountConversion(_detail.subscribedCount)})',style: TextStyle(color: Colors.white, fontSize: 12),)
                  ],
                ),
            )
          )
            : InkWell(
              onTap: () {
                _toggleSubscribe();
              },
              child: Row(
                children: <Widget>[
                  Image.asset('images/icon_collected.png', height: 18,),
                  Text(' ${NumberUtils.amountConversion(_detail.subscribedCount)}', style: TextStyle(color: Colors.grey, fontSize: 12),)
                ],
              ),
            )
          : null
      ) : null,
      flexibleSpace: FlexibleDetailBar(
        titleBackground: backgroundWidget,
        background: backgroundWidget,
        collapseMode: CollapseMode.pin,
        content: Column(
          children: <Widget>[
            _detail != null && _detail.specialType == 100 ? _buildOfficialPlayList() : _buildCreatorPlayList(),
            _buildEntry(),
          ],
        ),
      ),
    );
  }
  /// 构建创建者歌单
  Widget _buildCreatorPlayList() {
    return Padding(
      padding: EdgeInsets.only(left: 16, top: 72 + Application.statusBarHeight, right: 16, bottom: 28),
      child: Row(
        children: <Widget>[
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Color(0xffd0d0d0),
              image: _detail != null ? DecorationImage(
                image: NetworkImage(
                  _detail.coverImgUrl
                ),
                fit: BoxFit.cover
              ) : null,
            ),
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Image.asset(
                    'images/icon_triangle.png',
                    width: 14,
                    height: 14,
                  ),
                  Text(_detail == null ? '0' : NumberUtils.amountConversion(_detail.playCount), style: TextStyle(
                    color: Colors.white,
                    fontSize: 11
                  ),)
                ],
              ),
            ),
          ),
          SizedBox(
            width: 12,
          ),
          Expanded(
            child: SizedBox(
              height: 120,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(_detail == null ? '' : _detail.name,
                    style: TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                        height: 1.4
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        CircleAvatar(
                          radius: 14,
                          backgroundImage: _detail != null ? NetworkImage(_detail.creator.avatarUrl + '?param=100y100') : null,
                          child: _detail == null ? Container(
                            decoration: BoxDecoration(
                              color: Color(0xffd0d0d0),
                              borderRadius: BorderRadius.circular(30)
                            ),
                          ) : null,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: Text(_detail == null ? '' : _detail.creator.nickname,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),),
                        ),
                        Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white70,)
                      ],
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Text(_detail == null ? '' : (_detail.description ?? ''),
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                            height: 1.4
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white54,)
                    ],
                  ),
                ],
              ),
            )
          ),
        ],
      ),
    );
  }
  /// 构建官方歌单
  Widget _buildOfficialPlayList() {
    return Padding(
      padding: EdgeInsets.only(left: 16, top: 72 + Application.statusBarHeight, right: 16, bottom: 24),
      child: SizedBox(
        height: 120,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(_detail == null ? '' : _detail.name,
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  height: 1.4
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(
              height: 6,
            ),
            _detail.updateFrequency == null
              ? Container()
              : Container(
                height: 18,
                padding: EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 255, 255, 0.2),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: Color.fromRGBO(255, 255, 255, 0.3),
                    width: 0.5
                  )
                ),
                child: Text(_detail.updateFrequency, style: TextStyle(color: Colors.white70, fontSize: 10),),
              ),
            SizedBox(
              height: 24,
            ),
            Expanded(
              flex: 1,
              child: Text(_detail == null ? '' : _detail.description,
                  style: TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                      height: 1.4
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis
              ),
            ),
          ],
        ),
      ),
    );
  }
  /// 构建功能入口
  Widget _buildEntry() {
    if (_detail == null) {
      return Container();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        GestureDetector(
          onTap: () {},
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset('images/icon_comment.png', width: 22, height: 22,),
              SizedBox(height: 4,),
              Text(NumberUtils.amountConversion(_detail.commentCount), style: TextStyle(
                fontSize: 13,
                color: Colors.white70
              ),)
            ],
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset('images/icon_share.png', width: 22, height: 22,),
              SizedBox(height: 4,),
              Text(_detail.shareCount.toString(), style: TextStyle(
                  fontSize: 13,
                  color: Colors.white70
              ),)
            ],
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset('images/icon_download.png', width: 22, height: 22,),
              SizedBox(height: 4,),
              Text('下载', style: TextStyle(
                  fontSize: 13,
                  color: Colors.white70
              ),)
            ],
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset('images/icon_mutil_select.png', width: 22, height: 22,),
              SizedBox(height: 4,),
              Text('多选', style: TextStyle(
                  fontSize: 13,
                  color: Colors.white70
              ),)
            ],
          ),
        ),
      ],
    );
  }
  /// 构建单行音乐
  Widget _buildMusicItem(Track track, int index, bool playing) {
    String artists = track.ar.map((e) => e['name']).toList().join('/');
    String album = track.al['name'];
    String titleSub = '';
    if (track.alia.isNotEmpty) {
      titleSub += ' (' + track.alia.join("/") + ')';
    }
    if (track.tns != null && track.tns.isNotEmpty) {
      titleSub += ' (' + track.tns.join("/") + ')';
    }
    List<Widget> desChildren = [];
    if (track.copyright == 0) {
      // 独家
      desChildren.add(Image.asset('images/text_dujia.png', height: 10));
      desChildren.add(SizedBox(width: 4,));
    }
    desChildren.add(Expanded(
      child: Text(artists + ' - ' + album,
        style: TextStyle(color: Colors.grey, fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      )
    ));

    return InkWell(
      onTap: () {
        if (playing) {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return PlaySongPage();
          }));
          return;
        }
        _playSongs(index: index);
      },
      child: Row(
        children: <Widget>[
          Container(
            width: 30,
            height: 30,
            margin: EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.center,
            child: playing
              ? Icon(Icons.volume_up, color: Colors.red, size: 20,)
              : Text((index + 1).toString(), style: TextStyle(
                color: Colors.grey,
                fontSize: 16
              ),),
          ),
          Expanded(
            child: Container(
              height: 50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      children: [
                        TextSpan(text: track.name, style: TextStyle(color: Colors.black87, fontSize: 15),),
                        TextSpan(text: titleSub, style: TextStyle(color: Colors.grey, fontSize: 15),)
                      ]
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 6),
                    child:Row(
                      children: desChildren,
                    ),
                  ),
                ],
              ),
            ),
          ),
          track.mv != 0
            ? InkWell(
              onTap: () {
                print('MV');
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                child: Image.asset('images/icon_video.png', height: 20,),
              ),
            )
          : Container(),
          InkWell(
            onTap: () {
              _showMusicTool();
            },
            child: Padding(
              padding: EdgeInsets.fromLTRB(6, 20, 12, 20),
              child: Image.asset('images/icon_more_vert.png', height: 18,),
            ),
          )
        ],
      ),
    );
  }
  /// 构建订阅者列表
  Widget _buildSubscribers() {
    if (_detail == null) {
      return Container();
    }
    // 最多显示5位
    _detail.subscribers = _detail.subscribers.take(5).toList();
    List<Widget> children = [];
    _detail.subscribers.forEach((user) {
      children.add(Container(
        width: 32,
        height: 32,
        margin: EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          image: DecorationImage(
            image: NetworkImage(user.avatarUrl + '?param=100y100'),
            fit: BoxFit.fill
          )
        ),
      ));
    });
    children.add(Expanded(
      child: Text(
        NumberUtils.amountConversion(_detail.subscribedCount) + '人收藏',
        maxLines: 1,
        textAlign: TextAlign.right,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.grey,
          fontSize: 14
        ),
      ),
    ));

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child:Row(
        children: children,
      )
    );
  }

  /// 播放音乐
  void _playSongs({int index, bool all = false }) {
    if (_detail == null) return;

    // 播放音乐
    List<Song> songs = _detail.tracks.map((track) => Song(
        track.id,
        name: track.name,
        artists: track.ar.map((e) => e['name']).toList().join('/'),
        picUrl: track.al['picUrl']
    )).toList();

    if (all) {
      Provider.of<PlaySongsProvider>(context, listen: false).playSongs(songs, index: 0);
    } else if (widget.liked) {
      Provider.of<PlaySongsProvider>(context, listen: false).playSong(songs[index], pid: widget.id);
    } else {
      Provider.of<PlaySongsProvider>(context, listen: false).playSongs(songs, index: index);
    }
  }
  /// 切换收藏歌单
  void _toggleSubscribe() {
    if (_detail == null) return;
    BotToast.showLoading();
    DioUtils.get('/playlist/subscribe', queryParameters: {
      'id': _detail.id,
      't': _detail.subscribed ? 2 : 1
    }).then((v) {
      setState(() {
        _detail.subscribed = !_detail.subscribed;
      });
    }).whenComplete(() => BotToast.closeAllLoading());
  }
  /// 展示音乐操作栏
  void _showMusicTool() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        )
      ),
      builder: (context) {
        return Container(
          height: 800,
          color: Colors.red,
        );
      }
    );
  }
}
